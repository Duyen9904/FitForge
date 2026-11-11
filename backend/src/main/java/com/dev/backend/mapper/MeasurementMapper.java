package com.dev.backend.mapper;

import com.dev.backend.model.dto.request.InBodyImportRequest;
import com.dev.backend.model.dto.request.RecordMeasurementRequest;
import com.dev.backend.model.dto.request.SetMeasurementGoalRequest;
import com.dev.backend.model.dto.response.MeasurementGoalResponse;
import com.dev.backend.model.dto.response.MeasurementResponse;
import com.dev.backend.model.dto.response.ProgressPhotoResponse;
import com.dev.backend.model.entity.MeasurementGoal;
import com.dev.backend.model.entity.ProgressPhoto;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.entity.UserMeasurement;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface MeasurementMapper extends BaseMapper<UserMeasurement, RecordMeasurementRequest, MeasurementResponse> {

    @Override
    @Mapping(target = "source", expression = "java(entity.getSource() != null ? entity.getSource().name() : null)")
    MeasurementResponse toResponse(UserMeasurement entity);

    @Override
    @Mapping(target = "source", constant = "MANUAL")
    UserMeasurement toEntity(RecordMeasurementRequest request);

    @Override
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntityFromRequest(@MappingTarget UserMeasurement entity, RecordMeasurementRequest request);

    @Mapping(target = "user", source = "user")
    @Mapping(target = "source", constant = "MANUAL")
    @Mapping(target = "notes", source = "request.notes")
    UserMeasurement toEntity(RecordMeasurementRequest request, User user);

    default MeasurementResponse toResponseWithChange(UserMeasurement current, UserMeasurement previous) {
        MeasurementResponse response = toResponse(current);
        if (response != null && previous != null) {
            if (current.getWeightKg() != null && previous.getWeightKg() != null) {
                response.setWeightChange(current.getWeightKg() - previous.getWeightKg());
            }
            if (current.getBodyFatPercentage() != null && previous.getBodyFatPercentage() != null) {
                response.setBodyFatChange(current.getBodyFatPercentage() - previous.getBodyFatPercentage());
            }
        }
        return response;
    }

    @Mapping(target = "user", source = "user")
    @Mapping(target = "measurementDate", expression = "java(request.getTestDate() != null ? request.getTestDate() : java.time.LocalDate.now())")
    @Mapping(target = "source", constant = "INBODY_IMPORT")
    @Mapping(target = "notes", source = "request.notes")
    UserMeasurement toEntity(InBodyImportRequest request, User user);

    @Mapping(target = "user", source = "user")
    @Mapping(target = "targetWeightKg", source = "request.targetWeightKg")
    @Mapping(target = "notes", source = "request.notes")
    @Mapping(target = "isActive", constant = "true")
    MeasurementGoal toEntity(SetMeasurementGoalRequest request, User user);

    MeasurementGoalResponse toGoalResponse(MeasurementGoal entity);

    default MeasurementGoalResponse toResponse(MeasurementGoal entity, UserMeasurement currentMeasurement) {
        if (entity == null) {
            return null;
        }
        MeasurementGoalResponse response = toGoalResponse(entity);

        if (entity.getTargetDate() != null) {
            long daysRemaining = ChronoUnit.DAYS.between(LocalDate.now(), entity.getTargetDate());
            response.setDaysRemaining(Math.max(0, daysRemaining));

            if (currentMeasurement != null && daysRemaining > 0) {
                long weeksRemaining = Math.max(1, daysRemaining / 7);
                MeasurementGoalResponse.RequiredWeeklyChanges changes =
                        calculateRequiredWeeklyChanges(entity, currentMeasurement, weeksRemaining);
                response.setRequiredWeeklyChanges(changes);
            }
        }

        return response;
    }

    default MeasurementGoalResponse.RequiredWeeklyChanges calculateRequiredWeeklyChanges(
            MeasurementGoal goal, UserMeasurement current, long weeksRemaining) {

        Float weeklyWeight = null;
        Float weeklyBodyFat = null;
        String recommendation = "Stay consistent with your plan.";

        if (goal.getTargetWeightKg() != null && current.getWeightKg() != null) {
            float weightDiff = goal.getTargetWeightKg() - current.getWeightKg();
            weeklyWeight = weightDiff / weeksRemaining;

            if (Math.abs(weeklyWeight) > 1.0f) {
                recommendation = "Warning: Required weekly change exceeds healthy limit (0.5-1kg/week). Consider adjusting your target date.";
            } else if (Math.abs(weeklyWeight) > 0.5f) {
                recommendation = "Aggressive but achievable goal. Maintain strict discipline.";
            }
        }

        if (goal.getTargetBodyFatPercentage() != null && current.getBodyFatPercentage() != null) {
            float bodyFatDiff = goal.getTargetBodyFatPercentage() - current.getBodyFatPercentage();
            weeklyBodyFat = bodyFatDiff / weeksRemaining;
        }

        return MeasurementGoalResponse.RequiredWeeklyChanges.builder()
                .weeklyWeightChange(weeklyWeight)
                .weeklyBodyFatChange(weeklyBodyFat)
                .recommendation(recommendation)
                .build();
    }

    ProgressPhotoResponse toResponse(ProgressPhoto entity);
}
