package com.dev.backend.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

/**
 * Extended behavior tracking for workout sessions, beyond WorkoutProgress.
 * Stores completion rate, RPE, pain flags, skipped exercises, etc.
 * Used for plan adjustment logic.
 */
@Entity
@Table(name = "workout_session_log")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class WorkoutSessionLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long sessionLogId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "workout_plan_id")
    private WorkoutPlan workoutPlan;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "workout_progress_id")
    private WorkoutProgress workoutProgress;

    @Column(nullable = false)
    private Instant performedAt;

    /**
     * Completion rate (0.0 - 1.0): fraction of planned exercises/sets completed.
     */
    private Float completionRate;

    /**
     * Average Rate of Perceived Exertion for the session (1-10 scale).
     */
    private Float avgRPE;

    /**
     * Comma-separated list of exercise IDs that were skipped.
     */
    @Column(length = 255)
    private String skippedExercises;

    /**
     * Indicates if this session was automatically adjusted by the system.
     */
    @Column(nullable = false)
    private Boolean autoAdjusted = false;

    /**
     * Session-level rating (1-5) from the user.
     */
    private Integer sessionRating;

    @Column(length = 1000)
    private String notes;

    /** Optional GCS object path for proof photo uploaded on session completion */
    @Column(length = 500)
    private String proofPhotoUrl;

    @OneToMany(mappedBy = "sessionLog", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ExercisePerformanceLog> exercisePerformanceLogs = new ArrayList<>();
}
