package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.MeasurementMapper;
import com.dev.backend.model.dto.request.InBodyImportRequest;
import com.dev.backend.model.dto.request.RecordMeasurementRequest;
import com.dev.backend.model.dto.request.SetMeasurementGoalRequest;
import com.dev.backend.model.dto.request.UploadProgressPhotoRequest;
import com.dev.backend.model.dto.response.MeasurementGoalResponse;
import com.dev.backend.model.dto.response.MeasurementHistoryResponse;
import com.dev.backend.model.dto.response.MeasurementHistoryResponse.*;
import com.dev.backend.model.dto.response.MeasurementResponse;
import com.dev.backend.model.dto.response.ProgressPhotoResponse;
import com.dev.backend.model.entity.MeasurementGoal;
import com.dev.backend.model.entity.ProgressPhoto;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.entity.UserMeasurement;
import com.dev.backend.model.enums.MeasurementSource;
import com.dev.backend.repository.MeasurementGoalRepository;
import com.dev.backend.repository.ProgressPhotoRepository;
import com.dev.backend.repository.UserMeasurementRepository;
import com.dev.backend.repository.UserRepository;
import com.dev.backend.service.InBodyOcrService;
import com.dev.backend.service.MeasurementService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class MeasurementServiceImpl implements MeasurementService {

    private final UserMeasurementRepository measurementRepository;
    private final MeasurementGoalRepository goalRepository;
    private final ProgressPhotoRepository photoRepository;
    private final UserRepository userRepository;
    private final MeasurementMapper mapper;
    private final InBodyOcrService inBodyOcrService;

    @Value("${app.upload.photo-dir:uploads/photos}")
    private String photoUploadDir;

    @Value("${app.upload.base-url:/uploads/photos}")
    private String photoBaseUrl;

    public MeasurementServiceImpl(
            UserMeasurementRepository measurementRepository,
            MeasurementGoalRepository goalRepository,
            ProgressPhotoRepository photoRepository,
            UserRepository userRepository,
            MeasurementMapper mapper,
            InBodyOcrService inBodyOcrService) {
        this.measurementRepository = measurementRepository;
        this.goalRepository = goalRepository;
        this.photoRepository = photoRepository;
        this.userRepository = userRepository;
        this.mapper = mapper;
        this.inBodyOcrService = inBodyOcrService;
    }

    @Override
    public MeasurementResponse recordMeasurement(Long userId, RecordMeasurementRequest request) {
        User user = findUserOrThrow(userId);
        
        // Get previous measurement for change calculation
        UserMeasurement previous = measurementRepository
                .findTopByUserUserIdOrderByMeasurementDateDesc(userId)
                .orElse(null);

        // Check if measurement for this date already exists
        var existingMeasurement = measurementRepository
                .findByUserUserIdAndMeasurementDate(userId, request.getMeasurementDate());
        
        UserMeasurement measurement;
        if (existingMeasurement.isPresent()) {
            // Update existing measurement
            measurement = existingMeasurement.get();
            updateMeasurementFromRequest(measurement, request);
        } else {
            // Create new measurement
            measurement = mapper.toEntity(request, user);
        }

        measurement = measurementRepository.save(measurement);
        return mapper.toResponseWithChange(measurement, previous);
    }

    @Override
    @Transactional(readOnly = true)
    public MeasurementResponse getLatestMeasurement(Long userId) {
        UserMeasurement latest = measurementRepository
                .findTopByUserUserIdOrderByMeasurementDateDesc(userId)
                .orElseThrow(() -> new ResourceNotFoundException("No measurements found for user"));

        // Get the second-latest for comparison
        List<UserMeasurement> measurements = measurementRepository
                .findByUserUserIdOrderByMeasurementDateDesc(userId);
        
        UserMeasurement previous = measurements.size() > 1 ? measurements.get(1) : null;
        return mapper.toResponseWithChange(latest, previous);
    }

    @Override
    @Transactional(readOnly = true)
    public MeasurementResponse getMeasurementById(Long userId, Long measurementId) {
        UserMeasurement measurement = measurementRepository.findById(measurementId)
                .filter(m -> m.getUser().getUserId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("Measurement not found"));

        return mapper.toResponse(measurement);
    }

    @Override
    @Transactional(readOnly = true)
    public MeasurementHistoryResponse getMeasurementHistory(Long userId, LocalDate startDate, LocalDate endDate) {
        // Default to last 90 days if not specified
        LocalDate end = endDate != null ? endDate : LocalDate.now();
        LocalDate start = startDate != null ? startDate : end.minusDays(90);

        List<UserMeasurement> measurements = measurementRepository
                .findByUserUserIdAndMeasurementDateBetween(userId, start, end);

        if (measurements.isEmpty()) {
            return MeasurementHistoryResponse.builder()
                    .measurements(List.of())
                    .build();
        }

        // Convert to response DTOs with change indicators
        List<MeasurementResponse> measurementResponses = new ArrayList<>();
        for (int i = 0; i < measurements.size(); i++) {
            UserMeasurement current = measurements.get(i);
            UserMeasurement previous = i < measurements.size() - 1 ? measurements.get(i + 1) : null;
            measurementResponses.add(mapper.toResponseWithChange(current, previous));
        }

        // Build trend data
        MeasurementTrendResponse trends = buildTrends(measurements);

        // Calculate progress indicators
        ProgressIndicators progressIndicators = calculateProgressIndicators(measurements);

        // Get goal comparison if goal exists
        GoalComparison goalComparison = null;
        MeasurementGoal goal = goalRepository.findByUserUserIdAndIsActiveTrue(userId).orElse(null);
        if (goal != null && !measurements.isEmpty()) {
            UserMeasurement latest = measurements.get(0);
            goalComparison = buildGoalComparison(latest, goal);
        }

        return MeasurementHistoryResponse.builder()
                .measurements(measurementResponses)
                .trends(trends)
                .progressIndicators(progressIndicators)
                .goalComparison(goalComparison)
                .build();
    }

    @Override
    public MeasurementGoalResponse setMeasurementGoal(Long userId, SetMeasurementGoalRequest request) {
        User user = findUserOrThrow(userId);

        // Deactivate existing goal if any
        goalRepository.findByUserUserIdAndIsActiveTrue(userId)
                .ifPresent(existingGoal -> existingGoal.setIsActive(false));

        // Create new goal
        MeasurementGoal goal = mapper.toEntity(request, user);
        goal = goalRepository.save(goal);

        // Get current measurement for calculations
        UserMeasurement currentMeasurement = measurementRepository
                .findTopByUserUserIdOrderByMeasurementDateDesc(userId)
                .orElse(null);

        return mapper.toResponse(goal, currentMeasurement);
    }

    @Override
    @Transactional(readOnly = true)
    public MeasurementGoalResponse getMeasurementGoal(Long userId) {
        MeasurementGoal goal = goalRepository.findByUserUserIdAndIsActiveTrue(userId)
                .orElseThrow(() -> new ResourceNotFoundException("No active measurement goal found"));

        UserMeasurement currentMeasurement = measurementRepository
                .findTopByUserUserIdOrderByMeasurementDateDesc(userId)
                .orElse(null);

        return mapper.toResponse(goal, currentMeasurement);
    }

    @Override
    public ProgressPhotoResponse uploadProgressPhoto(Long userId, MultipartFile file, UploadProgressPhotoRequest request) {
        User user = findUserOrThrow(userId);

        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("Photo file is required");
        }

        // Validate file type
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IllegalArgumentException("Only image files are allowed");
        }

        // Generate unique filename
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename != null && originalFilename.contains(".") 
                ? originalFilename.substring(originalFilename.lastIndexOf("."))
                : ".jpg";
        String filename = UUID.randomUUID().toString() + extension;

        // Save file to filesystem
        try {
            Path uploadPath = Paths.get(photoUploadDir, userId.toString());
            Files.createDirectories(uploadPath);
            Path filePath = uploadPath.resolve(filename);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            throw new RuntimeException("Failed to save photo file", e);
        }

        // Create photo entity
        ProgressPhoto photo = new ProgressPhoto();
        photo.setUser(user);
        photo.setPhotoDate(request.getPhotoDate());
        photo.setPhotoUrl(photoBaseUrl + "/" + userId + "/" + filename);
        photo.setCategory(request.getCategory());
        photo.setNotes(request.getNotes());

        photo = photoRepository.save(photo);
        return mapper.toResponse(photo);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ProgressPhotoResponse> getProgressPhotos(Long userId) {
        return photoRepository.findByUserUserIdOrderByPhotoDateDesc(userId)
                .stream()
                .map(mapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<ProgressPhotoResponse> getProgressPhotosByCategory(Long userId, String category) {
        return photoRepository.findByUserUserIdAndCategory(userId, category)
                .stream()
                .map(mapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public void deleteProgressPhoto(Long userId, Long photoId) {
        ProgressPhoto photo = photoRepository.findByPhotoIdAndUserUserId(photoId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Photo not found"));

        // Delete file from filesystem (optional, based on your requirements)
        // For now, we just delete the database record
        photoRepository.delete(photo);
    }

    @Override
    public MeasurementResponse importInBodyReport(Long userId, MultipartFile file) {
        User user = findUserOrThrow(userId);
        
        // Parse InBody image using OCR
        InBodyImportRequest inBodyData = inBodyOcrService.parseInBodyImage(file);
        
        return saveInBodyMeasurement(user, inBodyData);
    }

    @Override
    public MeasurementResponse importInBodyManual(Long userId, InBodyImportRequest request) {
        User user = findUserOrThrow(userId);
        return saveInBodyMeasurement(user, request);
    }

    private MeasurementResponse saveInBodyMeasurement(User user, InBodyImportRequest request) {
        Long userId = user.getUserId();
        
        // Get previous measurement for change calculation
        UserMeasurement previous = measurementRepository
                .findTopByUserUserIdOrderByMeasurementDateDesc(userId)
                .orElse(null);
        
        // Check if measurement for this date already exists
        LocalDate measurementDate = request.getTestDate() != null ? request.getTestDate() : LocalDate.now();
        var existingMeasurement = measurementRepository
                .findByUserUserIdAndMeasurementDate(userId, measurementDate);
        
        UserMeasurement measurement;
        if (existingMeasurement.isPresent()) {
            measurement = existingMeasurement.get();
            updateMeasurementFromInBody(measurement, request);
        } else {
            measurement = mapper.toEntity(request, user);
        }
        
        measurement = measurementRepository.save(measurement);
        return mapper.toResponseWithChange(measurement, previous);
    }

    // ========== Helper Methods ==========

    private User findUserOrThrow(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    private void updateMeasurementFromRequest(UserMeasurement measurement, RecordMeasurementRequest request) {
        if (request.getWeightKg() != null) measurement.setWeightKg(request.getWeightKg());
        if (request.getBodyFatPercentage() != null) measurement.setBodyFatPercentage(request.getBodyFatPercentage());
        if (request.getChestCm() != null) measurement.setChestCm(request.getChestCm());
        if (request.getWaistCm() != null) measurement.setWaistCm(request.getWaistCm());
        if (request.getHipsCm() != null) measurement.setHipsCm(request.getHipsCm());
        if (request.getBicepsCm() != null) measurement.setBicepsCm(request.getBicepsCm());
        if (request.getThighsCm() != null) measurement.setThighsCm(request.getThighsCm());
        // InBody fields
        if (request.getSkeletalMuscleMass() != null) measurement.setSkeletalMuscleMass(request.getSkeletalMuscleMass());
        if (request.getBodyFatMass() != null) measurement.setBodyFatMass(request.getBodyFatMass());
        if (request.getBodyWaterLiters() != null) measurement.setBodyWaterLiters(request.getBodyWaterLiters());
        if (request.getBasalMetabolicRate() != null) measurement.setBasalMetabolicRate(request.getBasalMetabolicRate());
        if (request.getVisceralFatLevel() != null) measurement.setVisceralFatLevel(request.getVisceralFatLevel());
        if (request.getWaistHipRatio() != null) measurement.setWaistHipRatio(request.getWaistHipRatio());
        if (request.getInBodyScore() != null) measurement.setInBodyScore(request.getInBodyScore());
        if (request.getNotes() != null) measurement.setNotes(request.getNotes());
    }

    private void updateMeasurementFromInBody(UserMeasurement measurement, InBodyImportRequest request) {
        if (request.getWeightKg() != null) measurement.setWeightKg(request.getWeightKg());
        if (request.getBodyFatPercentage() != null) measurement.setBodyFatPercentage(request.getBodyFatPercentage());
        if (request.getSkeletalMuscleMass() != null) measurement.setSkeletalMuscleMass(request.getSkeletalMuscleMass());
        if (request.getBodyFatMass() != null) measurement.setBodyFatMass(request.getBodyFatMass());
        if (request.getBodyWaterLiters() != null) measurement.setBodyWaterLiters(request.getBodyWaterLiters());
        if (request.getBasalMetabolicRate() != null) measurement.setBasalMetabolicRate(request.getBasalMetabolicRate());
        if (request.getVisceralFatLevel() != null) measurement.setVisceralFatLevel(request.getVisceralFatLevel());
        if (request.getWaistHipRatio() != null) measurement.setWaistHipRatio(request.getWaistHipRatio());
        if (request.getInBodyScore() != null) measurement.setInBodyScore(request.getInBodyScore());
        if (request.getNotes() != null) measurement.setNotes(request.getNotes());
        measurement.setSource(MeasurementSource.INBODY_IMPORT);
    }

    private MeasurementTrendResponse buildTrends(List<UserMeasurement> measurements) {
        List<TrendPoint> weightTrend = measurements.stream()
                .filter(m -> m.getWeightKg() != null)
                .map(m -> TrendPoint.builder()
                        .date(m.getMeasurementDate())
                        .value(m.getWeightKg())
                        .build())
                .collect(Collectors.toList());

        List<TrendPoint> bodyFatTrend = measurements.stream()
                .filter(m -> m.getBodyFatPercentage() != null)
                .map(m -> TrendPoint.builder()
                        .date(m.getMeasurementDate())
                        .value(m.getBodyFatPercentage())
                        .build())
                .collect(Collectors.toList());

        List<TrendPoint> waistTrend = measurements.stream()
                .filter(m -> m.getWaistCm() != null)
                .map(m -> TrendPoint.builder()
                        .date(m.getMeasurementDate())
                        .value(m.getWaistCm())
                        .build())
                .collect(Collectors.toList());

        return MeasurementTrendResponse.builder()
                .weightTrend(weightTrend)
                .bodyFatTrend(bodyFatTrend)
                .waistTrend(waistTrend)
                .build();
    }

    private ProgressIndicators calculateProgressIndicators(List<UserMeasurement> measurements) {
        if (measurements.size() < 2) {
            return ProgressIndicators.builder()
                    .overallTrend("insufficient_data")
                    .build();
        }

        UserMeasurement latest = measurements.get(0);
        UserMeasurement earliest = measurements.get(measurements.size() - 1);

        Float totalWeightChange = null;
        Float totalBodyFatChange = null;
        String overallTrend = "maintaining";

        if (latest.getWeightKg() != null && earliest.getWeightKg() != null) {
            totalWeightChange = latest.getWeightKg() - earliest.getWeightKg();
            if (totalWeightChange > 0.5f) {
                overallTrend = "gaining";
            } else if (totalWeightChange < -0.5f) {
                overallTrend = "losing";
            }
        }

        if (latest.getBodyFatPercentage() != null && earliest.getBodyFatPercentage() != null) {
            totalBodyFatChange = latest.getBodyFatPercentage() - earliest.getBodyFatPercentage();
        }

        // Calculate average weekly change
        long daysBetween = java.time.temporal.ChronoUnit.DAYS.between(
                earliest.getMeasurementDate(), latest.getMeasurementDate());
        Float avgWeeklyChange = null;
        if (totalWeightChange != null && daysBetween > 0) {
            avgWeeklyChange = (totalWeightChange / daysBetween) * 7;
        }

        return ProgressIndicators.builder()
                .totalWeightChange(totalWeightChange)
                .totalBodyFatChange(totalBodyFatChange)
                .averageWeeklyWeightChange(avgWeeklyChange)
                .overallTrend(overallTrend)
                .build();
    }

    private GoalComparison buildGoalComparison(UserMeasurement current, MeasurementGoal goal) {
        Float currentWeight = current.getWeightKg();
        Float targetWeight = goal.getTargetWeightKg();

        if (currentWeight == null || targetWeight == null) {
            return null;
        }

        Float remaining = targetWeight - currentWeight;
        Float totalToLose = Math.abs(targetWeight - currentWeight);
        Float percentComplete = totalToLose > 0 ? Math.min(100f, (1 - Math.abs(remaining) / totalToLose) * 100) : 100f;

        return GoalComparison.builder()
                .currentWeight(currentWeight)
                .targetWeight(targetWeight)
                .remainingToTarget(remaining)
                .percentageComplete(percentComplete)
                .build();
    }
}
