package com.dev.backend.service.impl;

import com.dev.backend.exception.BadRequestException;
import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.WorkoutExecutionMapper;
import com.dev.backend.model.dto.request.CompleteWorkoutRequest;
import com.dev.backend.model.dto.request.LogExerciseRequest;
import com.dev.backend.model.dto.request.SkipExerciseRequest;
import com.dev.backend.model.dto.request.StartWorkoutRequest;
import com.dev.backend.model.dto.response.HomeDashboardResponse;
import com.dev.backend.model.dto.response.ProgressChartResponse;
import com.dev.backend.model.dto.response.WeeklyWorkoutProgressResponse;
import com.dev.backend.model.dto.response.WorkoutHistoryResponse;
import com.dev.backend.model.dto.response.WorkoutProgressResponse;
import com.dev.backend.model.entity.*;
import com.dev.backend.model.projection.DailyWorkoutAggregate;
import com.dev.backend.repository.*;
import com.dev.backend.service.WorkoutExecutionService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@Slf4j
public class WorkoutExecutionServiceImpl implements WorkoutExecutionService {

    private final WorkoutProgressRepository workoutProgressRepository;
    private final ExerciseLogRepository exerciseLogRepository;
    private final WorkoutSessionRepository workoutSessionRepository;
    private final WorkoutPlanRepository workoutPlanRepository;
    private final ExerciseRepository exerciseRepository;
    private final UserRepository userRepository;
    private final WorkoutExecutionMapper mapper;

    public WorkoutExecutionServiceImpl(WorkoutProgressRepository workoutProgressRepository,
                                       ExerciseLogRepository exerciseLogRepository,
                                       WorkoutSessionRepository workoutSessionRepository,
                                       WorkoutPlanRepository workoutPlanRepository,
                                       ExerciseRepository exerciseRepository,
                                       UserRepository userRepository,
                                       WorkoutExecutionMapper mapper) {
        this.workoutProgressRepository = workoutProgressRepository;
        this.exerciseLogRepository = exerciseLogRepository;
        this.workoutSessionRepository = workoutSessionRepository;
        this.workoutPlanRepository = workoutPlanRepository;
        this.exerciseRepository = exerciseRepository;
        this.userRepository = userRepository;
        this.mapper = mapper;
    }

    @Override
    @Transactional
    public WorkoutProgressResponse startWorkout(Long userId, StartWorkoutRequest request) {
        log.info("Starting workout for user {} with session {}", userId, request.getSessionId());

        // Check if user already has an in-progress workout
        if (workoutProgressRepository.existsByUserUserIdAndCompletedFalse(userId)) {
            throw new BadRequestException("You already have a workout in progress. Complete or cancel it first.");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        WorkoutSession session = workoutSessionRepository.findByIdWithExercises(request.getSessionId())
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutSession", "id", request.getSessionId()));

        WorkoutPlan plan = session.getWorkoutPlan();

        // Verify user owns this plan
        if (!plan.getUser().getUserId().equals(userId)) {
            throw new BadRequestException("You do not have access to this workout session");
        }

        // Create workout progress
        WorkoutProgress progress = new WorkoutProgress();
        progress.setUser(user);
        progress.setWorkoutPlan(plan);
        progress.setWorkoutSession(session);
        progress.setWorkoutDate(Instant.now());
        progress.setStartTime(Instant.now());
        progress.setCompleted(false);

        progress = workoutProgressRepository.save(progress);

        log.info("Started workout with progress ID: {}", progress.getProgressId());
        return mapper.toProgressResponse(progress);
    }

    @Override
    @Transactional
    public WorkoutProgressResponse logExercise(Long userId, Long progressId, LogExerciseRequest request) {
        log.info("Logging exercise {} for progress {} by user {}", request.getExerciseId(), progressId, userId);

        WorkoutProgress progress = workoutProgressRepository.findByProgressIdAndUserUserId(progressId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutProgress", "id", progressId));

        if (Boolean.TRUE.equals(progress.getCompleted())) {
            throw new BadRequestException("This workout has already been completed");
        }

        Exercise exercise = exerciseRepository.findById(request.getExerciseId())
                .orElseThrow(() -> new ResourceNotFoundException("Exercise", "id", request.getExerciseId()));

        ExerciseLog exerciseLog = new ExerciseLog();
        exerciseLog.setWorkoutProgress(progress);
        exerciseLog.setExercise(exercise);
        exerciseLog.setSetNumber(request.getSetNumber());
        exerciseLog.setRepetitionsCompleted(request.getRepetitionsCompleted());
        exerciseLog.setWeightUsedKg(request.getWeightUsedKg());
        exerciseLog.setRestTimeSeconds(request.getRestTimeSeconds());
        exerciseLog.setCompleted(request.getCompleted() != null ? request.getCompleted() : true);
        exerciseLog.setNotes(request.getNotes());

        exerciseLogRepository.save(exerciseLog);

        // Reload with logs
        progress = workoutProgressRepository.findByIdWithExerciseLogs(progressId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutProgress", "id", progressId));

        log.info("Logged exercise set {} for exercise {}", request.getSetNumber(), request.getExerciseId());
        return mapper.toProgressResponse(progress);
    }

    @Override
    @Transactional
    public WorkoutProgressResponse completeWorkout(Long userId, Long progressId, CompleteWorkoutRequest request) {
        log.info("Completing workout {} for user {}", progressId, userId);

        WorkoutProgress progress = workoutProgressRepository.findByIdWithExerciseLogs(progressId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutProgress", "id", progressId));

        if (Boolean.TRUE.equals(progress.getCompleted())) {
            throw new BadRequestException("This workout has already been completed");
        }

        Instant endTime = Instant.now();
        int durationMinutes = (int) Duration.between(progress.getStartTime(), endTime).toMinutes();

        progress.setEndTime(endTime);
        progress.setDurationMinutes(durationMinutes);
        progress.setCompleted(true);
        progress.setDifficultyRating(request.getDifficultyRating());
        progress.setPerformanceNotes(request.getPerformanceNotes());
        if (request.getMoodRating() != null) {
            progress.setMoodRating(request.getMoodRating().name());
        }

        // Calculate calories burned (simplified estimation)
        int caloriesBurned = calculateCaloriesBurned(progress);
        progress.setCaloriesBurned(caloriesBurned);

        progress = workoutProgressRepository.save(progress);

        log.info("Completed workout {} with duration {} minutes", progressId, durationMinutes);
        return mapper.toProgressResponse(progress);
    }

    private int calculateCaloriesBurned(WorkoutProgress progress) {
        // Simplified calculation: ~5-8 calories per minute of workout
        int durationMinutes = progress.getDurationMinutes() != null ? progress.getDurationMinutes() : 0;
        int baseCalories = durationMinutes * 6; // Average 6 cal/min

        // Add calories from exercise logs if exercise has caloriesBurnedPerMin
        if (progress.getExerciseLogs() != null) {
            for (ExerciseLog log : progress.getExerciseLogs()) {
                if (log.getExercise() != null && log.getExercise().getCaloriesBurnedPerMin() != null) {
                    // Estimate ~1 min per set
                    baseCalories += log.getExercise().getCaloriesBurnedPerMin();
                }
            }
        }

        return baseCalories;
    }

    @Override
    @Transactional
    public WorkoutProgressResponse skipExercise(Long userId, Long progressId, SkipExerciseRequest request) {
        log.info("Skipping exercise {} for progress {} by user {}", request.getExerciseId(), progressId, userId);

        WorkoutProgress progress = workoutProgressRepository.findByProgressIdAndUserUserId(progressId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutProgress", "id", progressId));

        if (Boolean.TRUE.equals(progress.getCompleted())) {
            throw new BadRequestException("This workout has already been completed");
        }

        Exercise exercise = exerciseRepository.findById(request.getExerciseId())
                .orElseThrow(() -> new ResourceNotFoundException("Exercise", "id", request.getExerciseId()));

        // Log a skipped entry
        ExerciseLog exerciseLog = new ExerciseLog();
        exerciseLog.setWorkoutProgress(progress);
        exerciseLog.setExercise(exercise);
        exerciseLog.setSetNumber(0); // 0 indicates skipped
        exerciseLog.setCompleted(false);
        exerciseLog.setNotes("Skipped: " + request.getReason().name() + 
                            (request.getNotes() != null ? " - " + request.getNotes() : ""));

        exerciseLogRepository.save(exerciseLog);

        // Reload with logs
        progress = workoutProgressRepository.findByIdWithExerciseLogs(progressId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutProgress", "id", progressId));

        log.info("Skipped exercise {} with reason: {}", request.getExerciseId(), request.getReason());
        return mapper.toProgressResponse(progress);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<WorkoutHistoryResponse> getWorkoutHistory(Long userId, Instant startDate, Instant endDate, Pageable pageable) {
        log.info("Getting workout history for user {} from {} to {}", userId, startDate, endDate);

        if (startDate == null) {
            startDate = Instant.now().minus(java.time.Duration.ofDays(30));
        }
        if (endDate == null) {
            endDate = Instant.now();
        }

        List<WorkoutProgress> progressList = workoutProgressRepository.findByUserIdAndDateRange(userId, startDate, endDate);

        List<WorkoutHistoryResponse> responses = progressList.stream()
                .map(mapper::toHistoryResponse)
                .collect(Collectors.toList());

        // Apply pagination manually (for simplicity)
        int start = (int) pageable.getOffset();
        int end = Math.min(start + pageable.getPageSize(), responses.size());
        List<WorkoutHistoryResponse> pageContent = start < end ? responses.subList(start, end) : new ArrayList<>();

        return new PageImpl<>(pageContent, pageable, responses.size());
    }

    @Override
    @Transactional(readOnly = true)
    public ProgressChartResponse getProgressCharts(Long userId, Instant startDate, Instant endDate, Long exerciseId) {
        log.info("Getting progress charts for user {} from {} to {}", userId, startDate, endDate);

        if (startDate == null) {
            startDate = Instant.now().minus(java.time.Duration.ofDays(90));
        }
        if (endDate == null) {
            endDate = Instant.now();
        }

        // TODO: Implement comprehensive progress chart data calculation
        // This would involve aggregating data from exercise logs and workout progress
        // For now, return a basic structure

        return ProgressChartResponse.builder()
                .fromDate(startDate)
                .toDate(endDate)
                .weightProgression(new ArrayList<>())
                .volumeByMuscleGroup(new java.util.HashMap<>())
                .workoutFrequency(new ArrayList<>())
                .caloriesTrend(new ArrayList<>())
                .strengthEstimates(new ArrayList<>())
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public WorkoutProgressResponse getCurrentWorkout(Long userId) {
        log.info("Getting current in-progress workout for user {}", userId);

        return workoutProgressRepository.findInProgressWorkout(userId)
                .map(mapper::toProgressResponse)
                .orElse(null);
    }

    @Override
    @Transactional(readOnly = true)
    public WorkoutProgressResponse getWorkoutById(Long userId, Long progressId) {
        log.info("Getting workout {} for user {}", progressId, userId);

        WorkoutProgress progress = workoutProgressRepository.findByIdWithExerciseLogs(progressId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutProgress", "id", progressId));

        return mapper.toProgressResponse(progress);
    }

    @Override
    @Transactional
    public void cancelWorkout(Long userId, Long progressId) {
        log.info("Canceling workout {} for user {}", progressId, userId);

        WorkoutProgress progress = workoutProgressRepository.findByProgressIdAndUserUserId(progressId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutProgress", "id", progressId));

        if (Boolean.TRUE.equals(progress.getCompleted())) {
            throw new BadRequestException("Cannot cancel a completed workout");
        }

        // Delete exercise logs and progress
        exerciseLogRepository.deleteByWorkoutProgressProgressId(progressId);
        workoutProgressRepository.delete(progress);

        log.info("Canceled workout {}", progressId);
    }

    @Override
    @Transactional(readOnly = true)
    public WeeklyWorkoutProgressResponse getWeeklyProgress(Long userId, LocalDate startDate) {
        log.info("Getting weekly workout progress for user {} starting from {}", userId, startDate);
        
        LocalDate endDate = startDate.plusDays(6);
        
        // Fetch daily workout aggregates
        List<DailyWorkoutAggregate> workoutData = 
            workoutProgressRepository.getDailyWorkoutTotals(userId, startDate, endDate);
        
        // Build daily data for all 7 days (fill missing days with zeros)
        List<WeeklyWorkoutProgressResponse.DailyWorkoutData> dailyDataList = new ArrayList<>();
        Map<LocalDate, DailyWorkoutAggregate> dataMap = workoutData.stream()
            .collect(Collectors.toMap(DailyWorkoutAggregate::getWorkoutDate, d -> d));
        
        for (int i = 0; i < 7; i++) {
            LocalDate date = startDate.plusDays(i);
            DailyWorkoutAggregate data = dataMap.get(date);
            
            dailyDataList.add(WeeklyWorkoutProgressResponse.DailyWorkoutData.builder()
                .date(date)
                .dayOfWeek(date.getDayOfWeek().getDisplayName(TextStyle.SHORT, Locale.ENGLISH))
                .isToday(date.equals(LocalDate.now()))
                .workoutsCompleted(data != null ? data.getTotalWorkouts().intValue() : 0)
                .minutesExercised(data != null ? data.getTotalMinutes().intValue() : 0)
                .caloriesBurned(data != null ? data.getTotalCalories() : 0)
                .build());
        }
        
        // Calculate summary
        WeeklyWorkoutProgressResponse.WeeklySummary summary = calculateWeeklySummary(dailyDataList);
        
        return WeeklyWorkoutProgressResponse.builder()
            .weekLabel(formatWeekLabel(startDate, endDate))
            .startDate(startDate)
            .endDate(endDate)
            .dailyData(dailyDataList)
            .summary(summary)
            .build();
    }
    
    private WeeklyWorkoutProgressResponse.WeeklySummary calculateWeeklySummary(
            List<WeeklyWorkoutProgressResponse.DailyWorkoutData> dailyData) {
        int totalWorkouts = dailyData.stream()
            .mapToInt(WeeklyWorkoutProgressResponse.DailyWorkoutData::getWorkoutsCompleted)
            .sum();
        int totalMinutes = dailyData.stream()
            .mapToInt(WeeklyWorkoutProgressResponse.DailyWorkoutData::getMinutesExercised)
            .sum();
        int totalCalories = dailyData.stream()
            .mapToInt(WeeklyWorkoutProgressResponse.DailyWorkoutData::getCaloriesBurned)
            .sum();
        float avgDuration = totalWorkouts > 0 ? (float) totalMinutes / totalWorkouts : 0.0f;
        
        return WeeklyWorkoutProgressResponse.WeeklySummary.builder()
            .totalWorkoutsCompleted(totalWorkouts)
            .totalMinutesExercised(totalMinutes)
            .totalCaloriesBurned(totalCalories)
            .averageWorkoutDuration(avgDuration)
            .build();
    }
    
    private String formatWeekLabel(LocalDate startDate, LocalDate endDate) {
        String startMonth = startDate.getMonth().getDisplayName(TextStyle.SHORT, Locale.ENGLISH);
        String endMonth = endDate.getMonth().getDisplayName(TextStyle.SHORT, Locale.ENGLISH);
        
        if (startMonth.equals(endMonth)) {
            return String.format("%s %d-%d", startMonth, startDate.getDayOfMonth(), endDate.getDayOfMonth());
        } else {
            return String.format("%s %d-%s %d", startMonth, startDate.getDayOfMonth(), 
                               endMonth, endDate.getDayOfMonth());
        }
    }

    @Override
    @Transactional(readOnly = true)
    public HomeDashboardResponse getDashboard(Long userId, LocalDate referenceDate) {
        log.info("Getting home dashboard for user {} on date {}", userId, referenceDate);

        // 1. Weekly progress (reuse existing logic)
        LocalDate weekStart = referenceDate.with(java.time.DayOfWeek.MONDAY);
        WeeklyWorkoutProgressResponse weeklyProgress = getWeeklyProgress(userId, weekStart);

        // 2. Weekly quick stats (derive from weekly progress summary)
        HomeDashboardResponse.WeeklyQuickStats weeklyStats = buildWeeklyQuickStats(
                weeklyProgress, userId, referenceDate);

        // 3. Today's session
        HomeDashboardResponse.TodaySessionInfo todaySession = findTodaySession(userId, referenceDate);

        // 4. Active plans
        List<HomeDashboardResponse.ActivePlanInfo> activePlans = buildActivePlans(userId, referenceDate);

        return HomeDashboardResponse.builder()
                .todaySession(todaySession)
                .weeklyStats(weeklyStats)
                .weeklyProgress(weeklyProgress)
                .activePlans(activePlans)
                .build();
    }

    private HomeDashboardResponse.WeeklyQuickStats buildWeeklyQuickStats(
            WeeklyWorkoutProgressResponse weeklyProgress, Long userId, LocalDate referenceDate) {
        WeeklyWorkoutProgressResponse.WeeklySummary summary = weeklyProgress.getSummary();

        int caloriesBurned = summary != null ? summary.getTotalCaloriesBurned() : 0;
        int workoutsCompleted = summary != null ? summary.getTotalWorkoutsCompleted() : 0;
        int totalMinutes = summary != null ? summary.getTotalMinutesExercised() : 0;

        // Count planned workouts for this week from active plans
        int workoutsPlanned = 0;
        List<WorkoutPlan> activePlans = workoutPlanRepository.findByUserUserIdAndIsActiveTrue(userId);
        for (WorkoutPlan plan : activePlans) {
            workoutsPlanned += plan.getFrequencyPerWeek() != null ? plan.getFrequencyPerWeek() : 0;
        }

        // Calculate streak
        int currentStreak = calculateStreak(userId, referenceDate);

        return HomeDashboardResponse.WeeklyQuickStats.builder()
                .caloriesBurned(caloriesBurned)
                .workoutsCompleted(workoutsCompleted)
                .workoutsPlanned(workoutsPlanned)
                .totalMinutes(totalMinutes)
                .currentStreak(currentStreak)
                .build();
    }

    private HomeDashboardResponse.TodaySessionInfo findTodaySession(Long userId, LocalDate date) {
        // Find sessions scheduled for today from active plans belonging to this user
        List<WorkoutSession> scheduledSessions = workoutSessionRepository.findScheduledSessionsByDate(date);

        // Filter to only this user's sessions
        WorkoutSession todaySession = scheduledSessions.stream()
                .filter(s -> s.getWorkoutPlan().getUser().getUserId().equals(userId))
                .findFirst()
                .orElse(null);

        if (todaySession == null) return null;

        // Check if already completed today
        boolean alreadyCompleted = workoutProgressRepository
                .existsByUserUserIdAndWorkoutSessionSessionIdAndCompletedTrue(userId, todaySession.getSessionId());

        // Build target muscle groups from focus area
        List<String> targetMuscleGroups = new ArrayList<>();
        if (todaySession.getFocusArea() != null && !todaySession.getFocusArea().isEmpty()) {
            targetMuscleGroups.add(todaySession.getFocusArea());
        }

        return HomeDashboardResponse.TodaySessionInfo.builder()
                .planId(todaySession.getWorkoutPlan().getPlanId())
                .sessionId(todaySession.getSessionId())
                .planName(todaySession.getWorkoutPlan().getPlanName())
                .sessionName(todaySession.getSessionName())
                .exerciseCount(todaySession.getSessionExercises() != null ? todaySession.getSessionExercises().size() : 0)
                .estimatedMinutes(todaySession.getEstimatedDuration())
                .scheduledDate(date)
                .targetMuscleGroups(targetMuscleGroups)
                .alreadyCompleted(alreadyCompleted)
                .build();
    }

    private List<HomeDashboardResponse.ActivePlanInfo> buildActivePlans(Long userId, LocalDate referenceDate) {
        List<WorkoutPlan> activePlans = workoutPlanRepository.findByUserUserIdAndIsActiveTrue(userId);
        List<HomeDashboardResponse.ActivePlanInfo> result = new ArrayList<>();

        for (WorkoutPlan plan : activePlans) {
            // Calculate current week
            int currentWeek = 1;
            if (plan.getStartDate() != null) {
                long daysSinceStart = java.time.temporal.ChronoUnit.DAYS.between(plan.getStartDate(), referenceDate);
                currentWeek = Math.max(1, (int) (daysSinceStart / 7) + 1);
                if (plan.getDurationWeeks() != null) {
                    currentWeek = Math.min(currentWeek, plan.getDurationWeeks());
                }
            }

            // Count sessions and completed sessions
            List<WorkoutSession> sessions = workoutSessionRepository
                    .findByWorkoutPlanPlanIdOrderByDayNumber(plan.getPlanId());
            int totalSessions = (int) sessions.stream().filter(s -> !Boolean.TRUE.equals(s.getIsRestDay())).count();

            // Count completed workout progress entries for this plan
            long sessionsCompleted = workoutProgressRepository
                    .countByUserUserIdAndWorkoutPlanPlanIdAndCompletedTrue(userId, plan.getPlanId());

            result.add(HomeDashboardResponse.ActivePlanInfo.builder()
                    .planId(plan.getPlanId())
                    .planName(plan.getPlanName())
                    .frequencyPerWeek(plan.getFrequencyPerWeek())
                    .durationWeeks(plan.getDurationWeeks())
                    .currentWeek(currentWeek)
                    .sessionsCompleted((int) sessionsCompleted)
                    .totalSessions(totalSessions)
                    .isActive(plan.getIsActive())
                    .build());
        }

        return result;
    }

    private int calculateStreak(Long userId, LocalDate referenceDate) {
        int streak = 0;
        LocalDate checkDate = referenceDate;

        // Check backwards from today — streak is consecutive days with completed workouts
        for (int i = 0; i < 365; i++) {
            boolean hasWorkout = workoutProgressRepository
                    .existsByUserUserIdAndWorkoutDateBetweenAndCompletedTrue(
                            userId,
                            checkDate.atStartOfDay(java.time.ZoneOffset.UTC).toInstant(),
                            checkDate.plusDays(1).atStartOfDay(java.time.ZoneOffset.UTC).toInstant());
            if (hasWorkout) {
                streak++;
                checkDate = checkDate.minusDays(1);
            } else {
                break;
            }
        }

        return streak;
    }
}
