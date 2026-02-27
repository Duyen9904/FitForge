package com.dev.backend.service.impl;

import com.dev.backend.model.dto.request.DataExportRequest;
import com.dev.backend.model.dto.response.NutritionReportResponse;
import com.dev.backend.model.dto.response.TransformationReportResponse;
import com.dev.backend.model.dto.response.WorkoutSummaryReportResponse;
import com.dev.backend.model.entity.*;
import com.dev.backend.model.projection.DailyNutritionTrendAggregate;
import com.dev.backend.repository.*;
import com.dev.backend.service.ReportService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class ReportServiceImpl implements ReportService {

    private final WorkoutProgressRepository workoutProgressRepository;
    private final NutritionLogRepository nutritionLogRepository;
    private final NutritionPlanRepository nutritionPlanRepository;
    private final UserMeasurementRepository userMeasurementRepository;
    private final ProgressPhotoRepository progressPhotoRepository;
    private final UserAchievementRepository userAchievementRepository;
    private final MissedWorkoutRepository missedWorkoutRepository;
    private final ExerciseLogRepository exerciseLogRepository;

    public ReportServiceImpl(
            WorkoutProgressRepository workoutProgressRepository,
            NutritionLogRepository nutritionLogRepository,
            NutritionPlanRepository nutritionPlanRepository,
            UserMeasurementRepository userMeasurementRepository,
            ProgressPhotoRepository progressPhotoRepository,
            UserAchievementRepository userAchievementRepository,
            MissedWorkoutRepository missedWorkoutRepository,
            ExerciseLogRepository exerciseLogRepository) {
        this.workoutProgressRepository = workoutProgressRepository;
        this.nutritionLogRepository = nutritionLogRepository;
        this.nutritionPlanRepository = nutritionPlanRepository;
        this.userMeasurementRepository = userMeasurementRepository;
        this.progressPhotoRepository = progressPhotoRepository;
        this.userAchievementRepository = userAchievementRepository;
        this.missedWorkoutRepository = missedWorkoutRepository;
        this.exerciseLogRepository = exerciseLogRepository;
    }

    @Override
    public WorkoutSummaryReportResponse generateWorkoutSummaryReport(Long userId, LocalDate startDate, LocalDate endDate) {
        Instant startInstant = startDate.atStartOfDay(ZoneId.systemDefault()).toInstant();
        Instant endInstant = endDate.plusDays(1).atStartOfDay(ZoneId.systemDefault()).toInstant();

        // Get completed workouts in range
        List<WorkoutProgress> workouts = workoutProgressRepository.findByUserIdAndDateRange(userId, startInstant, endInstant);
        long completedWorkouts = workouts.stream().filter(WorkoutProgress::getCompleted).count();

        // Calculate total duration and calories
        int totalDuration = workouts.stream()
                .filter(w -> w.getDurationMinutes() != null)
                .mapToInt(WorkoutProgress::getDurationMinutes)
                .sum();
        int totalCalories = workouts.stream()
                .filter(w -> w.getCaloriesBurned() != null)
                .mapToInt(WorkoutProgress::getCaloriesBurned)
                .sum();

        // Get missed workouts
        long missedCount = missedWorkoutRepository.countByUserUserIdAndScheduledDateBetween(
                userId, startDate, endDate);

        // Calculate adherence
        long totalPlanned = completedWorkouts + missedCount;
        double adherence = totalPlanned > 0 ? (completedWorkouts * 100.0 / totalPlanned) : 100.0;

        // Build recommendations
        List<String> recommendations = new ArrayList<>();
        if (adherence < 70) {
            recommendations.add("Consider reducing workout frequency to improve consistency");
        }
        if (completedWorkouts > 0 && totalDuration / completedWorkouts < 30) {
            recommendations.add("Try to extend workout duration for better results");
        }

        return WorkoutSummaryReportResponse.builder()
                .startDate(startDate)
                .endDate(endDate)
                .totalWorkoutsCompleted((int) completedWorkouts)
                .totalWorkoutsPlanned((int) totalPlanned)
                .adherencePercentage(Math.round(adherence * 10) / 10.0)
                .totalDurationMinutes(totalDuration)
                .totalCaloriesBurned(totalCalories)
                .missedWorkouts((int) missedCount)
                .recommendations(recommendations)
                .build();
    }

    @Override
    public NutritionReportResponse generateNutritionReport(Long userId, LocalDate startDate, LocalDate endDate) {
        // Get daily totals
        List<DailyNutritionTrendAggregate> dailyTotals = nutritionLogRepository.getDailyTotals(userId, startDate, endDate);

        if (dailyTotals.isEmpty()) {
            return NutritionReportResponse.builder()
                    .startDate(startDate)
                    .endDate(endDate)
                    .recommendations(List.of("Start logging your meals to get nutrition insights"))
                    .build();
        }

        // Calculate averages
        double totalCalories = 0, totalProtein = 0, totalCarbs = 0, totalFats = 0;
        List<NutritionReportResponse.DailyNutritionItem> dailyBreakdown = new ArrayList<>();

        for (DailyNutritionTrendAggregate row : dailyTotals) {
            LocalDate date = row.getLogDate();
            int calories = row.getTotalCalories().intValue();
            double protein = row.getTotalProtein().doubleValue();
            double carbs = row.getTotalCarbs().doubleValue();
            double fats = row.getTotalFats().doubleValue();

            totalCalories += calories;
            totalProtein += protein;
            totalCarbs += carbs;
            totalFats += fats;

            dailyBreakdown.add(NutritionReportResponse.DailyNutritionItem.builder()
                    .date(date)
                    .calories(calories)
                    .protein(protein)
                    .carbs(carbs)
                    .fats(fats)
                    .build());
        }

        int days = dailyTotals.size();
        double avgCalories = totalCalories / days;
        double avgProtein = totalProtein / days;
        double avgCarbs = totalCarbs / days;
        double avgFats = totalFats / days;

        // Calculate macro percentages
        double totalMacroCalories = (avgProtein * 4) + (avgCarbs * 4) + (avgFats * 9);
        double proteinPct = totalMacroCalories > 0 ? (avgProtein * 4 * 100 / totalMacroCalories) : 0;
        double carbsPct = totalMacroCalories > 0 ? (avgCarbs * 4 * 100 / totalMacroCalories) : 0;
        double fatsPct = totalMacroCalories > 0 ? (avgFats * 9 * 100 / totalMacroCalories) : 0;

        // Count cheat meal days
        long cheatDays = nutritionLogRepository.countCheatDaysBetween(userId, startDate, endDate);
        long totalDays = java.time.temporal.ChronoUnit.DAYS.between(startDate, endDate) + 1;
        double cheatFrequency = totalDays > 0 ? (cheatDays * 7.0 / totalDays) : 0;

        // Build recommendations
        List<String> recommendations = new ArrayList<>();
        if (proteinPct < 20) {
            recommendations.add("Consider increasing protein intake for better muscle recovery");
        }
        if (cheatFrequency > 2) {
            recommendations.add("Try to reduce cheat meal frequency for better results");
        }

        return NutritionReportResponse.builder()
                .startDate(startDate)
                .endDate(endDate)
                .averageDailyCalories(Math.round(avgCalories * 10) / 10.0)
                .averageDailyProtein(Math.round(avgProtein * 10) / 10.0)
                .averageDailyCarbs(Math.round(avgCarbs * 10) / 10.0)
                .averageDailyFats(Math.round(avgFats * 10) / 10.0)
                .proteinPercentage(Math.round(proteinPct * 10) / 10.0)
                .carbsPercentage(Math.round(carbsPct * 10) / 10.0)
                .fatsPercentage(Math.round(fatsPct * 10) / 10.0)
                .totalCheatMealDays((int) cheatDays)
                .cheatMealFrequencyPerWeek(Math.round(cheatFrequency * 10) / 10.0)
                .dailyBreakdown(dailyBreakdown)
                .recommendations(recommendations)
                .build();
    }

    @Override
    public TransformationReportResponse generateTransformationReport(Long userId, LocalDate startDate, LocalDate endDate) {
        // Get measurements
        List<UserMeasurement> measurements = userMeasurementRepository
                .findByUserUserIdAndMeasurementDateBetween(userId, startDate, endDate);

        if (measurements.isEmpty()) {
            return TransformationReportResponse.builder()
                    .startDate(startDate)
                    .endDate(endDate)
                    .milestones(List.of("Start tracking your measurements to see your transformation"))
                    .build();
        }

        // Sort by date
        measurements.sort(Comparator.comparing(UserMeasurement::getMeasurementDate));
        UserMeasurement first = measurements.get(0);
        UserMeasurement last = measurements.get(measurements.size() - 1);

        // Weight history
        List<TransformationReportResponse.WeightDataPoint> weightHistory = measurements.stream()
                .filter(m -> m.getWeightKg() != null)
                .map(m -> TransformationReportResponse.WeightDataPoint.builder()
                        .date(m.getMeasurementDate())
                        .weight(m.getWeightKg())
                        .build())
                .collect(Collectors.toList());

        // Calculate weight change
        Float startWeight = first.getWeightKg();
        Float currentWeight = last.getWeightKg();
        Float weightChange = (startWeight != null && currentWeight != null) 
                ? currentWeight - startWeight : null;

        // Get achievements in range
        List<UserAchievement> achievements = userAchievementRepository
                .findByUserUserIdOrderByEarnedDateDesc(userId).stream()
                .filter(a -> {
                    LocalDate awardDate = a.getEarnedDate().atZone(ZoneId.systemDefault()).toLocalDate();
                    return !awardDate.isBefore(startDate) && !awardDate.isAfter(endDate);
                })
                .collect(Collectors.toList());

        List<TransformationReportResponse.AchievementItem> achievementItems = achievements.stream()
                .map(a -> TransformationReportResponse.AchievementItem.builder()
                        .date(a.getEarnedDate().atZone(ZoneId.systemDefault()).toLocalDate())
                        .title(a.getAchievement().getAchievementName())
                        .description(a.getAchievement().getDescription())
                        .build())
                .collect(Collectors.toList());

        // Build milestones
        List<String> milestones = new ArrayList<>();
        if (weightChange != null && weightChange < 0) {
            milestones.add(String.format("Lost %.1f kg - Great progress!", Math.abs(weightChange)));
        } else if (weightChange != null && weightChange > 0) {
            milestones.add(String.format("Gained %.1f kg", weightChange));
        }
        if (!achievements.isEmpty()) {
            milestones.add(String.format("Earned %d achievements", achievements.size()));
        }

        return TransformationReportResponse.builder()
                .startDate(startDate)
                .endDate(endDate)
                .startingWeight(startWeight)
                .currentWeight(currentWeight)
                .weightChange(weightChange)
                .weightHistory(weightHistory)
                .achievements(achievementItems)
                .milestones(milestones)
                .build();
    }

    @Override
    public byte[] exportData(Long userId, DataExportRequest request) {
        // For now, return JSON format
        StringBuilder json = new StringBuilder();
        json.append("{\"userId\": ").append(userId).append(",");
        json.append("\"exportDate\": \"").append(LocalDate.now()).append("\",");
        json.append("\"data\": {");

        List<String> sections = new ArrayList<>();

        for (DataExportRequest.ExportDataType type : request.getDataTypes()) {
            switch (type) {
                case WORKOUT_HISTORY:
                    sections.add("\"workoutHistory\": []");
                    break;
                case EXERCISE_LOGS:
                    sections.add("\"exerciseLogs\": []");
                    break;
                case NUTRITION_LOGS:
                    sections.add("\"nutritionLogs\": []");
                    break;
                case MEASUREMENTS:
                    sections.add("\"measurements\": []");
                    break;
                case PROGRESS_PHOTOS:
                    sections.add("\"progressPhotos\": []");
                    break;
            }
        }

        json.append(String.join(",", sections));
        json.append("}}");

        return json.toString().getBytes();
    }
}
