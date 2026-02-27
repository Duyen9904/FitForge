package com.dev.backend.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Table(name = "workout_plan")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
public class WorkoutPlan extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long planId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "goal_id", nullable = false)
    private Goal goal;

    @Column(nullable = false, length = 100)
    private String planName;

    @Column(length = 500)
    private String description;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "muscle_group_id", nullable = false)
    private MuscleGroup muscleGroup;

    @Column(nullable = false)
    private Integer frequencyPerWeek;

    @Column(nullable = false)
    private Integer durationWeeks;

    @Column(nullable = false)
    private String difficultyLevel;

    /**
     * Indicates which algorithm generated or last adjusted this plan.
     * Example values: "RULE_BASED_V1", "AI_V1".
     */
    @Column(length = 50)
    private String algorithmVersion;

    /**
     * High-level source of this plan, used for analytics and explainability.
     * Example values:
     * - "MANUAL"
     * - "ONBOARDING_ONLY"
     * - "ONBOARDING_PLUS_BEHAVIOR"
     */
    @Column(length = 50)
    private String generatedFrom;

    /**
     * Semantic version of the plan. Incremented whenever the system
     * applies a significant automatic adjustment based on user behavior.
     */
    @Column(nullable = false)
    private Integer version = 1;

    /**
     * Short human-readable explanation of why this plan was generated
     * or last adjusted (e.g. low adherence, high RPE, etc.).
     */
    @Column(length = 500)
    private String recommendationReason;

    @Column(nullable = false)
    private Boolean aiGenerated = false;

    @Column(nullable = false)
    private Boolean allowWorkoutSwaps = true;

    @Column(nullable = false)
    private Boolean isActive = true;

    /**
     * The date when the user intends to start this workout plan.
     */
    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    /**
     * User-chosen specific workout dates. When set at plan creation or update,
     * these dates define when workouts are scheduled. Sessions added later
     * can be assigned to these dates.
     */
    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "workout_plan_scheduled_date", joinColumns = @JoinColumn(name = "plan_id"))
    @Column(name = "scheduled_date")
    @OrderColumn(name = "list_order")
    private List<LocalDate> scheduledWorkoutDates = new ArrayList<>();

    @OneToMany(mappedBy = "workoutPlan", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<WorkoutSession> workoutSessions = new HashSet<>();

    @OneToMany(mappedBy = "workoutPlan", cascade = CascadeType.ALL)
    private List<WorkoutProgress> workoutProgressList = new ArrayList<>();

    @OneToMany(mappedBy = "workoutPlan", cascade = CascadeType.ALL)
    private List<MissedWorkout> missedWorkouts = new ArrayList<>();
}
