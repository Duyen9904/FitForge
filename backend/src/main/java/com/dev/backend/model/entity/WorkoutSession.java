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
@Table(name = "workout_session")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class WorkoutSession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long sessionId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "plan_id", nullable = false)
    private WorkoutPlan workoutPlan;

    @Column(nullable = false, length = 100)
    private String sessionName;

    @Column(nullable = false)
    private Integer dayNumber;

    @Column(length = 100)
    private String focusArea;

    private Integer estimatedDuration;

    @Column(length = 500)
    private String warmUpNotes;

    @Column(length = 500)
    private String coolDownNotes;

    @Column(nullable = false)
    private Boolean isRestDay = false;

    /**
     * The scheduled date for this workout session.
     * Calculated based on the plan's start date and frequency.
     */
    @Column(name = "scheduled_date")
    private LocalDate scheduledDate;

    @OneToMany(mappedBy = "workoutSession", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<SessionExercise> sessionExercises = new ArrayList<>();

    @OneToMany(mappedBy = "workoutSession", cascade = CascadeType.ALL)
    private List<WorkoutProgress> workoutProgressList = new ArrayList<>();

    @OneToMany(mappedBy = "workoutSession", cascade = CascadeType.ALL)
    private List<MissedWorkout> missedWorkouts = new ArrayList<>();
}
