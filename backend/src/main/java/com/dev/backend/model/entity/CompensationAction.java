package com.dev.backend.model.entity;

import com.dev.backend.model.enums.CompensationStatus;
import com.dev.backend.model.enums.RescheduleReason;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(
    name = "compensation_action",
    indexes = {
        @Index(name = "idx_compensation_action_cheat_meal", columnList = "cheat_meal_log_id"),
        @Index(name = "idx_compensation_action_missed_workout", columnList = "missed_workout_id"),
        @Index(name = "idx_compensation_action_status", columnList = "status"),
        @Index(name = "idx_compensation_action_scheduled", columnList = "scheduled_date")
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
public class CompensationAction extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long compensationId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cheat_meal_log_id")
    private CheatMealLog cheatMealLog;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "missed_workout_id")
    private MissedWorkout missedWorkout;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private CompensationStatus status = CompensationStatus.PENDING;

    @Column(nullable = false, length = 50)
    private String actionType;

    @Column(length = 1000)
    private String actionDescription;

    private LocalDate scheduledDate;

    private LocalDate validUntilDate;

    @Column(nullable = false)
    private Boolean isCompleted = false;

    private Integer calorieAdjustment;

    @Column(length = 500)
    private String details;

    private Instant activatedAt;

    private Instant completedAt;

    @Column
    private Integer effectivenessRating; // 1-5 user feedback

    @Column(length = 500)
    private String userFeedback;

    @Enumerated(EnumType.STRING)
    @Column(name = "reschedule_reason", length = 30)
    private RescheduleReason rescheduleReason;

    @OneToMany(mappedBy = "compensationAction", cascade = CascadeType.ALL)
    private List<NutritionAdjustment> nutritionAdjustments = new ArrayList<>();

    @OneToOne(mappedBy = "compensationAction", cascade = CascadeType.ALL)
    private MakeupWorkout makeupWorkout;
}

