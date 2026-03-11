package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.CompensationMapper;
import com.dev.backend.mapper.MissedWorkoutMapper;
import com.dev.backend.model.dto.request.RescheduleMissedWorkoutRequest;
import com.dev.backend.model.dto.request.SelectMakeupOptionRequest;
import com.dev.backend.model.dto.response.MakeupWorkoutOptionResponse;
import com.dev.backend.model.dto.response.MakeupWorkoutResponse;
import com.dev.backend.model.dto.response.MissedWorkoutReportResponse;
import com.dev.backend.model.dto.response.MissedWorkoutReportResponse.MissedWorkoutPatterns;
import com.dev.backend.model.dto.response.MissedWorkoutResponse;
import com.dev.backend.model.entity.*;
import com.dev.backend.model.enums.MakeupOption;
import com.dev.backend.model.enums.RescheduleReason;
import com.dev.backend.repository.*;
import com.dev.backend.service.MissedWorkoutService;
import com.dev.backend.service.NotificationService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional
public class MissedWorkoutServiceImpl implements MissedWorkoutService {

    private final MissedWorkoutRepository missedWorkoutRepository;
    private final WorkoutSessionRepository sessionRepository;
    private final WorkoutPlanRepository planRepository;
    private final WorkoutProgressRepository progressRepository;
    private final CompensationActionRepository compensationRepository;
    private final MakeupWorkoutRepository makeupRepository;
    private final UserRepository userRepository;
    private final MissedWorkoutMapper mapper;
    private final CompensationMapper compensationMapper;
    private final NotificationService notificationService;

    public MissedWorkoutServiceImpl(
            MissedWorkoutRepository missedWorkoutRepository,
            WorkoutSessionRepository sessionRepository,
            WorkoutPlanRepository planRepository,
            WorkoutProgressRepository progressRepository,
            CompensationActionRepository compensationRepository,
            MakeupWorkoutRepository makeupRepository,
            UserRepository userRepository,
            MissedWorkoutMapper mapper,
            CompensationMapper compensationMapper,
            NotificationService notificationService) {
        this.missedWorkoutRepository = missedWorkoutRepository;
        this.sessionRepository = sessionRepository;
        this.planRepository = planRepository;
        this.progressRepository = progressRepository;
        this.compensationRepository = compensationRepository;
        this.makeupRepository = makeupRepository;
        this.userRepository = userRepository;
        this.mapper = mapper;
        this.compensationMapper = compensationMapper;
        this.notificationService = notificationService;
    }

    @Override
    @Transactional(readOnly = true)
    public List<MakeupWorkoutOptionResponse> generateMakeupOptions(Long userId, Long missedWorkoutId) {
        MissedWorkout missedWorkout = findMissedWorkoutOrThrow(userId, missedWorkoutId);
        WorkoutSession session = missedWorkout.getWorkoutSession();
        WorkoutPlan plan = missedWorkout.getWorkoutPlan();

        List<MakeupWorkoutOptionResponse> options = new ArrayList<>();
        LocalDate today = LocalDate.now();

        // Option A: Reschedule to next available day
        LocalDate nextAvailable = findNextAvailableDate(userId, today);
        options.add(MakeupWorkoutOptionResponse.builder()
                .option(MakeupOption.RESCHEDULE_NEXT_DAY)
                .description("Reschedule entire session to " + nextAvailable)
                .detailedExplanation("Move the complete workout session \"" + session.getSessionName() + 
                        "\" to " + nextAvailable + ". All exercises will be performed as originally planned.")
                .affectedDates(List.of(nextAvailable))
                .estimatedRecoveryDays(1)
                .recommendation(missedWorkout.getScheduledDate().plusDays(2).isAfter(today) ? 
                        "Recommended - workout was recently missed" : null)
                .build());

        // Option B: Distribute exercises across upcoming sessions
        int upcomingSessions = Math.min(3, getUpcomingSessionCount(plan));
        options.add(MakeupWorkoutOptionResponse.builder()
                .option(MakeupOption.DISTRIBUTE_EXERCISES)
                .description("Distribute missed exercises across next " + upcomingSessions + " sessions")
                .detailedExplanation("Add the missed exercises from \"" + session.getSessionName() + 
                        "\" to your upcoming workout sessions. This spreads the load to avoid overtraining.")
                .affectedDates(getNextSessionDates(userId, upcomingSessions))
                .estimatedRecoveryDays(upcomingSessions)
                .recommendation(null)
                .build());

        // Option C: Weekend makeup session
        LocalDate nextWeekend = getNextWeekendDate(today);
        options.add(MakeupWorkoutOptionResponse.builder()
                .option(MakeupOption.WEEKEND_MAKEUP)
                .description("Add weekend makeup session on " + nextWeekend)
                .detailedExplanation("Create a special makeup session on " + nextWeekend + 
                        " dedicated to completing the missed workout \"" + session.getSessionName() + "\".")
                .affectedDates(List.of(nextWeekend))
                .estimatedRecoveryDays(1)
                .recommendation(today.getDayOfWeek().getValue() <= 4 ? 
                        "Good option if you have weekend availability" : null)
                .build());

        // Option D: Extend program by one week
        options.add(MakeupWorkoutOptionResponse.builder()
                .option(MakeupOption.EXTEND_PROGRAM)
                .description("Extend program by one week")
                .detailedExplanation("Add an extra week to your \"" + plan.getPlanName() + 
                        "\" program to accommodate the missed workout without disrupting your schedule.")
                .affectedDates(List.of())
                .estimatedRecoveryDays(7)
                .recommendation("Best for maintaining workout quality without rushing")
                .build());

        return options;
    }

    @Override
    public MissedWorkoutResponse selectMakeupOption(Long userId, Long missedWorkoutId, SelectMakeupOptionRequest request) {
        MissedWorkout missedWorkout = findMissedWorkoutOrThrow(userId, missedWorkoutId);

        if (missedWorkout.getIsReplanned()) {
            throw new IllegalStateException("This missed workout has already been replanned");
        }

        // Create compensation action based on selected option
        CompensationAction action = new CompensationAction();
        action.setMissedWorkout(missedWorkout);
        action.setActionType(request.getSelectedOption().name());
        action.setIsCompleted(false);
        action.setRescheduleReason(RescheduleReason.MISSED_WORKOUT);

        LocalDate scheduledDate;
        String description;

        switch (request.getSelectedOption()) {
            case RESCHEDULE_NEXT_DAY:
                scheduledDate = findNextAvailableDate(userId, LocalDate.now());
                description = "Reschedule \"" + missedWorkout.getWorkoutSession().getSessionName() + 
                        "\" to " + scheduledDate;
                break;
            case DISTRIBUTE_EXERCISES:
                scheduledDate = LocalDate.now().plusDays(1);
                description = "Distribute exercises from \"" + missedWorkout.getWorkoutSession().getSessionName() + 
                        "\" across upcoming sessions";
                break;
            case WEEKEND_MAKEUP:
                scheduledDate = getNextWeekendDate(LocalDate.now());
                description = "Weekend makeup session for \"" + missedWorkout.getWorkoutSession().getSessionName() + "\"";
                break;
            case EXTEND_PROGRAM:
                scheduledDate = null;
                description = "Extend program \"" + missedWorkout.getWorkoutPlan().getPlanName() + "\" by one week";
                break;
            default:
                throw new IllegalArgumentException("Unknown makeup option");
        }

        action.setScheduledDate(scheduledDate);
        action.setActionDescription(description);
        compensationRepository.save(action);

        // Create makeup workout if applicable
        if (request.getSelectedOption() == MakeupOption.RESCHEDULE_NEXT_DAY ||
            request.getSelectedOption() == MakeupOption.WEEKEND_MAKEUP) {
            MakeupWorkout makeup = new MakeupWorkout();
            makeup.setCompensationAction(action);
            makeup.setOriginalSession(missedWorkout.getWorkoutSession());
            makeup.setScheduledMakeupDate(scheduledDate);
            makeup.setAdjustmentType(request.getSelectedOption().name());
            makeup.setIsCompleted(false);
            makeupRepository.save(makeup);
        }

        // Update missed workout
        missedWorkout.setIsReplanned(true);
        missedWorkout.setReplanStrategy(request.getSelectedOption().name());
        missedWorkout = missedWorkoutRepository.save(missedWorkout);

        return mapper.toResponse(missedWorkout);
    }

    @Override
    public MissedWorkoutResponse rescheduleMissedWorkout(Long userId, Long missedWorkoutId, 
            RescheduleMissedWorkoutRequest request) {
        return rescheduleMissedWorkoutInternal(userId, missedWorkoutId, request, RescheduleReason.MISSED_WORKOUT);
    }

    private MissedWorkoutResponse rescheduleMissedWorkoutInternal(Long userId, Long missedWorkoutId,
            RescheduleMissedWorkoutRequest request, RescheduleReason reason) {
        MissedWorkout missedWorkout = findMissedWorkoutOrThrow(userId, missedWorkoutId);

        // Create compensation action for manual reschedule
        CompensationAction action = new CompensationAction();
        action.setMissedWorkout(missedWorkout);
        action.setActionType("MANUAL_RESCHEDULE");
        action.setScheduledDate(request.getNewDate());
        action.setActionDescription("Manually rescheduled to " + request.getNewDate());
        action.setDetails(request.getNotes());
        action.setIsCompleted(false);
        action.setRescheduleReason(reason);
        compensationRepository.save(action);

        // Create makeup workout
        MakeupWorkout makeup = new MakeupWorkout();
        makeup.setCompensationAction(action);
        makeup.setOriginalSession(missedWorkout.getWorkoutSession());
        makeup.setScheduledMakeupDate(request.getNewDate());
        makeup.setAdjustmentType("MANUAL_RESCHEDULE");
        makeup.setAdjustmentNotes(request.getNotes());
        makeup.setIsCompleted(false);
        makeupRepository.save(makeup);

        // Update missed workout
        missedWorkout.setIsReplanned(true);
        missedWorkout.setReplanStrategy("MANUAL_RESCHEDULE");
        missedWorkout = missedWorkoutRepository.save(missedWorkout);

        return mapper.toResponse(missedWorkout);
    }

    @Override
    @Transactional(readOnly = true)
    public MissedWorkoutResponse getMissedWorkout(Long userId, Long missedWorkoutId) {
        MissedWorkout missedWorkout = findMissedWorkoutOrThrow(userId, missedWorkoutId);
        return mapper.toResponse(missedWorkout);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<MissedWorkoutResponse> getMissedWorkouts(Long userId, Pageable pageable) {
        return missedWorkoutRepository.findByUserUserId(userId, pageable)
                .map(mapper::toResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public List<MissedWorkoutResponse> getUnaddressedMissedWorkouts(Long userId) {
        return missedWorkoutRepository.findByUserUserIdAndIsReplannedFalse(userId)
                .stream()
                .map(mapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public MissedWorkoutReportResponse getMissedWorkoutReport(Long userId, LocalDate startDate, LocalDate endDate) {
        LocalDate start = startDate != null ? startDate : LocalDate.now().minusDays(90);
        LocalDate end = endDate != null ? endDate : LocalDate.now();

        // Get missed workout counts
        long totalMissed = missedWorkoutRepository.countByUserUserIdAndScheduledDateBetween(userId, start, end);
        
        // Get completed workouts count (approximate based on progress records)
        long totalCompleted = progressRepository.countByUserUserIdAndWorkoutDateBetween(userId, 
                start.atStartOfDay().toInstant(java.time.ZoneOffset.UTC), 
                end.atStartOfDay().toInstant(java.time.ZoneOffset.UTC));

        // Calculate adherence
        long totalScheduled = totalMissed + totalCompleted;
        float adherence = totalScheduled > 0 ? (totalCompleted * 100f / totalScheduled) : 100f;

        // Get compensation completion rate
        long compensated = missedWorkoutRepository.countByUserUserIdAndIsReplannedTrue(userId);
        int compensationRate = totalMissed > 0 ? (int) (compensated * 100 / totalMissed) : 100;

        // Get patterns
        MissedWorkoutPatterns patterns = buildPatterns(userId, start, end);

        // Generate recommendations
        List<String> recommendations = generateRecommendations(patterns, adherence);

        return MissedWorkoutReportResponse.builder()
                .totalMissedWorkouts((int) totalMissed)
                .totalCompletedWorkouts((int) totalCompleted)
                .adherencePercentage(adherence)
                .compensationCompletionRate(compensationRate)
                .patterns(patterns)
                .recommendations(recommendations)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public List<MakeupWorkoutResponse> getActiveMakeupWorkouts(Long userId) {
        return makeupRepository.findByOriginalSessionWorkoutPlanUserUserIdAndIsCompletedFalse(userId)
                .stream()
                .map(compensationMapper::toMakeupWorkoutResponse)
                .collect(Collectors.toList());
    }

    @Override
    public void detectAndLogMissedWorkoutsForDate(LocalDate date) {
        LocalDate targetDate = date != null ? date : LocalDate.now().minusDays(1);

        List<WorkoutSession> sessions = sessionRepository.findScheduledSessionsByDate(targetDate);
        if (sessions.isEmpty()) {
            return;
        }

        ZoneId zoneId = ZoneId.systemDefault();
        Instant startOfDay = targetDate.atStartOfDay(zoneId).toInstant();
        Instant endOfDay = targetDate.plusDays(1).atStartOfDay(zoneId).toInstant();

        for (WorkoutSession session : sessions) {
            WorkoutPlan plan = session.getWorkoutPlan();
            if (plan == null || plan.getUser() == null) {
                continue;
            }

            User user = plan.getUser();
            Long userId = user.getUserId();
            Long sessionId = session.getSessionId();

            long completedCount = progressRepository.countCompletedWorkoutsForSessionOnDate(
                    userId, sessionId, startOfDay, endOfDay);
            if (completedCount > 0) {
                continue;
            }

            Optional<MissedWorkout> existing = missedWorkoutRepository
                    .findByUserUserIdAndWorkoutSessionSessionId(userId, sessionId);
            if (existing.isPresent()) {
                continue;
            }

            MissedWorkout missedWorkout = new MissedWorkout();
            missedWorkout.setUser(user);
            missedWorkout.setWorkoutPlan(plan);
            missedWorkout.setWorkoutSession(session);
            missedWorkout.setScheduledDate(targetDate);
            missedWorkout.setMissedDate(LocalDate.now());
            missedWorkout.setIsReplanned(false);
            missedWorkout.setReason("AUTO_DETECTED");

            missedWorkoutRepository.save(missedWorkout);

            // Send push notification for missed workout
            try {
                notificationService.createMissedWorkoutNotification(
                        userId, session.getSessionName(), sessionId, targetDate.toString());
            } catch (Exception e) {
                // Don't let notification failure break missed workout detection
                org.slf4j.LoggerFactory.getLogger(MissedWorkoutServiceImpl.class)
                        .error("Failed to send missed workout notification for user {}: {}", userId, e.getMessage());
            }
        }
    }

    // ========== Helper Methods ==========

    private User findUserOrThrow(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    private MissedWorkout findMissedWorkoutOrThrow(Long userId, Long missedWorkoutId) {
        return missedWorkoutRepository.findById(missedWorkoutId)
                .filter(m -> m.getUser().getUserId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("Missed workout not found"));
    }

    private LocalDate findNextAvailableDate(Long userId, LocalDate after) {
        // Simple logic: return next day that's not today
        // In production, you'd check against existing scheduled workouts
        return after.plusDays(1);
    }

    private int getUpcomingSessionCount(WorkoutPlan plan) {
        if (plan.getWorkoutSessions() != null) {
            return (int) plan.getWorkoutSessions().stream()
                    .filter(s -> !s.getIsRestDay())
                    .count();
        }
        return 3; // Default
    }

    private List<LocalDate> getNextSessionDates(Long userId, int count) {
        List<LocalDate> dates = new ArrayList<>();
        LocalDate date = LocalDate.now();
        for (int i = 0; i < count; i++) {
            date = date.plusDays(1);
            // Skip weekends for simplicity
            while (date.getDayOfWeek() == DayOfWeek.SATURDAY || date.getDayOfWeek() == DayOfWeek.SUNDAY) {
                date = date.plusDays(1);
            }
            dates.add(date);
        }
        return dates;
    }

    private LocalDate getNextWeekendDate(LocalDate from) {
        LocalDate date = from;
        while (date.getDayOfWeek() != DayOfWeek.SATURDAY && date.getDayOfWeek() != DayOfWeek.SUNDAY) {
            date = date.plusDays(1);
        }
        return date;
    }

    private MissedWorkoutPatterns buildPatterns(Long userId, LocalDate start, LocalDate end) {
        Map<String, Integer> byDayOfWeek = new LinkedHashMap<>();
        Map<String, Integer> byReason = new HashMap<>();

        // Get counts by day of week
        List<Object[]> dayResults = missedWorkoutRepository.countByDayOfWeekForUser(userId, start, end);
        String[] dayNames = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
        for (Object[] row : dayResults) {
            int dayNum = ((Number) row[0]).intValue();
            int count = ((Number) row[1]).intValue();
            if (dayNum >= 1 && dayNum <= 7) {
                byDayOfWeek.put(dayNames[dayNum - 1], count);
            }
        }

        // Get counts by reason
        List<Object[]> reasonResults = missedWorkoutRepository.countByReasonForUser(userId, start, end);
        for (Object[] row : reasonResults) {
            String reason = (String) row[0];
            int count = ((Number) row[1]).intValue();
            // Handle custom reasons (format: "OTHER:custom text")
            if (reason != null && reason.contains(":")) {
                reason = reason.split(":")[0];
            }
            byReason.merge(reason != null ? reason : "UNKNOWN", count, Integer::sum);
        }

        // Find most common
        String mostMissedDay = byDayOfWeek.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(null);

        String mostCommonReason = byReason.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(null);

        return MissedWorkoutPatterns.builder()
                .byDayOfWeek(byDayOfWeek)
                .byReason(byReason)
                .mostMissedDay(mostMissedDay)
                .mostCommonReason(mostCommonReason)
                .build();
    }

    private List<String> generateRecommendations(MissedWorkoutPatterns patterns, float adherence) {
        List<String> recommendations = new ArrayList<>();

        if (adherence < 70) {
            recommendations.add("Your adherence is below 70%. Consider simplifying your workout schedule or reducing workout frequency.");
        } else if (adherence < 85) {
            recommendations.add("Good consistency! Try to identify and address the main causes of missed workouts.");
        } else {
            recommendations.add("Excellent consistency! Keep up the great work.");
        }

        if (patterns.getMostMissedDay() != null) {
            recommendations.add("You tend to miss workouts most on " + patterns.getMostMissedDay() + 
                    ". Consider scheduling rest days or lighter workouts on this day.");
        }

        if ("TOO_BUSY".equals(patterns.getMostCommonReason())) {
            recommendations.add("Time seems to be your biggest challenge. Try shorter, more intense workouts or schedule workouts at a fixed time.");
        } else if ("NO_MOTIVATION".equals(patterns.getMostCommonReason())) {
            recommendations.add("Motivation is a challenge. Consider finding a workout partner or setting small, achievable goals.");
        } else if ("SICK_INJURED".equals(patterns.getMostCommonReason())) {
            recommendations.add("Health issues are affecting your workouts. Ensure proper rest, nutrition, and consider consulting a healthcare professional.");
        }

        return recommendations;
    }
}
