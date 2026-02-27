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
import com.dev.backend.model.enums.MeasurementSource;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@Component
public class MeasurementMapper {

    public UserMeasurement toEntity(RecordMeasurementRequest request, User user) {
        UserMeasurement measurement = new UserMeasurement();
        measurement.setUser(user);
        measurement.setMeasurementDate(request.getMeasurementDate());
        measurement.setWeightKg(request.getWeightKg());
        measurement.setBodyFatPercentage(request.getBodyFatPercentage());
        measurement.setChestCm(request.getChestCm());
        measurement.setWaistCm(request.getWaistCm());
        measurement.setHipsCm(request.getHipsCm());
        measurement.setBicepsCm(request.getBicepsCm());
        measurement.setThighsCm(request.getThighsCm());
        // InBody fields
        measurement.setSkeletalMuscleMass(request.getSkeletalMuscleMass());
        measurement.setBodyFatMass(request.getBodyFatMass());
        measurement.setBodyWaterLiters(request.getBodyWaterLiters());
        measurement.setBasalMetabolicRate(request.getBasalMetabolicRate());
        measurement.setVisceralFatLevel(request.getVisceralFatLevel());
        measurement.setWaistHipRatio(request.getWaistHipRatio());
        measurement.setInBodyScore(request.getInBodyScore());
        measurement.setSource(MeasurementSource.MANUAL);
        measurement.setNotes(request.getNotes());
        return measurement;
    }

    public MeasurementResponse toResponse(UserMeasurement entity) {
        return MeasurementResponse.builder()
                .measurementId(entity.getMeasurementId())
                .measurementDate(entity.getMeasurementDate())
                .weightKg(entity.getWeightKg())
                .bodyFatPercentage(entity.getBodyFatPercentage())
                .chestCm(entity.getChestCm())
                .waistCm(entity.getWaistCm())
                .hipsCm(entity.getHipsCm())
                .bicepsCm(entity.getBicepsCm())
                .thighsCm(entity.getThighsCm())
                // InBody fields
                .skeletalMuscleMass(entity.getSkeletalMuscleMass())
                .bodyFatMass(entity.getBodyFatMass())
                .bodyWaterLiters(entity.getBodyWaterLiters())
                .basalMetabolicRate(entity.getBasalMetabolicRate())
                .visceralFatLevel(entity.getVisceralFatLevel())
                .waistHipRatio(entity.getWaistHipRatio())
                .inBodyScore(entity.getInBodyScore())
                .source(entity.getSource() != null ? entity.getSource().name() : null)
                .notes(entity.getNotes())
                .build();
    }

    public MeasurementResponse toResponseWithChange(UserMeasurement current, UserMeasurement previous) {
        MeasurementResponse response = toResponse(current);
        if (previous != null) {
            if (current.getWeightKg() != null && previous.getWeightKg() != null) {
                response.setWeightChange(current.getWeightKg() - previous.getWeightKg());
            }
            if (current.getBodyFatPercentage() != null && previous.getBodyFatPercentage() != null) {
                response.setBodyFatChange(current.getBodyFatPercentage() - previous.getBodyFatPercentage());
            }
        }
        return response;
    }

    public UserMeasurement toEntity(InBodyImportRequest request, User user) {
        UserMeasurement measurement = new UserMeasurement();
        measurement.setUser(user);
        measurement.setMeasurementDate(request.getTestDate() != null ? request.getTestDate() : LocalDate.now());
        measurement.setWeightKg(request.getWeightKg());
        measurement.setBodyFatPercentage(request.getBodyFatPercentage());
        // InBody-specific fields
        measurement.setSkeletalMuscleMass(request.getSkeletalMuscleMass());
        measurement.setBodyFatMass(request.getBodyFatMass());
        measurement.setBodyWaterLiters(request.getBodyWaterLiters());
        measurement.setBasalMetabolicRate(request.getBasalMetabolicRate());
        measurement.setVisceralFatLevel(request.getVisceralFatLevel());
        measurement.setWaistHipRatio(request.getWaistHipRatio());
        measurement.setInBodyScore(request.getInBodyScore());
        measurement.setSource(MeasurementSource.INBODY_IMPORT);
        measurement.setNotes(request.getNotes());
        return measurement;
    }

    public MeasurementGoal toEntity(SetMeasurementGoalRequest request, User user) {
        MeasurementGoal goal = new MeasurementGoal();
        goal.setUser(user);
        goal.setTargetWeightKg(request.getTargetWeightKg());
        goal.setTargetBodyFatPercentage(request.getTargetBodyFatPercentage());
        goal.setTargetChestCm(request.getTargetChestCm());
        goal.setTargetWaistCm(request.getTargetWaistCm());
        goal.setTargetHipsCm(request.getTargetHipsCm());
        goal.setTargetBicepsCm(request.getTargetBicepsCm());
        goal.setTargetThighsCm(request.getTargetThighsCm());
        goal.setTargetDate(request.getTargetDate());
        goal.setNotes(request.getNotes());
        goal.setIsActive(true);
        return goal;
    }

    public MeasurementGoalResponse toResponse(MeasurementGoal entity, UserMeasurement currentMeasurement) {
        MeasurementGoalResponse.MeasurementGoalResponseBuilder builder = MeasurementGoalResponse.builder()
                .goalId(entity.getGoalId())
                .targetWeightKg(entity.getTargetWeightKg())
                .targetBodyFatPercentage(entity.getTargetBodyFatPercentage())
                .targetChestCm(entity.getTargetChestCm())
                .targetWaistCm(entity.getTargetWaistCm())
                .targetHipsCm(entity.getTargetHipsCm())
                .targetBicepsCm(entity.getTargetBicepsCm())
                .targetThighsCm(entity.getTargetThighsCm())
                .targetDate(entity.getTargetDate())
                .isActive(entity.getIsActive())
                .notes(entity.getNotes());

        // Calculate days remaining
        if (entity.getTargetDate() != null) {
            long daysRemaining = ChronoUnit.DAYS.between(LocalDate.now(), entity.getTargetDate());
            builder.daysRemaining(Math.max(0, daysRemaining));

            // Calculate required weekly changes
            if (currentMeasurement != null && daysRemaining > 0) {
                long weeksRemaining = Math.max(1, daysRemaining / 7);
                MeasurementGoalResponse.RequiredWeeklyChanges changes = 
                    calculateRequiredWeeklyChanges(entity, currentMeasurement, weeksRemaining);
                builder.requiredWeeklyChanges(changes);
            }
        }

        return builder.build();
    }

    private MeasurementGoalResponse.RequiredWeeklyChanges calculateRequiredWeeklyChanges(
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

    public ProgressPhotoResponse toResponse(ProgressPhoto entity) {
        return ProgressPhotoResponse.builder()
                .photoId(entity.getPhotoId())
                .photoDate(entity.getPhotoDate())
                .photoUrl(entity.getPhotoUrl())
                .category(entity.getCategory())
                .notes(entity.getNotes())
                .build();
    }
}
