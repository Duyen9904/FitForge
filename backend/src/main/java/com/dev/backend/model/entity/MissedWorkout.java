package com.dev.backend.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "missed_workout")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
public class MissedWorkout extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long missedWorkoutId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "plan_id", nullable = false)
    private WorkoutPlan workoutPlan;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false)
    private WorkoutSession workoutSession;

    @Column(nullable = false)
    private LocalDate scheduledDate;

    private LocalDate missedDate;

    @Column(length = 500)
    private String reason;

    @Column(length = 500)
    private String replanStrategy;

    @Column(nullable = false)
    private Boolean isReplanned = false;

    @OneToMany(mappedBy = "missedWorkout", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<CompensationAction> compensationActions = new ArrayList<>();
}
