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

@Entity
@Table(name = "workout_progress")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class WorkoutProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long progressId;

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
    private Instant workoutDate;

    private Instant startTime;

    private Instant endTime;

    private Integer durationMinutes;

    @Column(nullable = false)
    private Boolean completed = false;

    @Column(length = 1000)
    private String performanceNotes;

    private Integer difficultyRating;

    private Integer caloriesBurned;

    private Float averageHeartRate;

    @Column(length = 20)
    private String moodRating;

    @OneToMany(mappedBy = "workoutProgress", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ExerciseLog> exerciseLogs = new ArrayList<>();
}
