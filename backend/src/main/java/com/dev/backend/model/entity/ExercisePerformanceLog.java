package com.dev.backend.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Per-exercise detail for finer adjustments.
 * Tracks sets completed, reps per set, weight, RPE, pain flags, etc.
 */
@Entity
@Table(name = "exercise_performance_log")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class ExercisePerformanceLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long performanceLogId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_log_id", nullable = false)
    private WorkoutSessionLog sessionLog;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "exercise_id", nullable = false)
    private Exercise exercise;

    private Integer setsCompleted;

    /**
     * Comma-separated reps per set (e.g. "10,10,8").
     */
    @Column(length = 100)
    private String repsPerSet;

    /**
     * Comma-separated weights per set (e.g. "50.0,50.0,45.0").
     */
    @Column(length = 100)
    private String weightPerSet;

    /**
     * Comma-separated RPE per set (e.g. "7,8,9").
     */
    @Column(length = 100)
    private String rpePerSet;

    /**
     * Indicates if the user reported pain during this exercise.
     */
    @Column(nullable = false)
    private Boolean painFlag = false;

    /**
     * Number of failed reps (couldn't complete) across all sets.
     */
    private Integer failedReps;

    @Column(length = 500)
    private String notes;
}
