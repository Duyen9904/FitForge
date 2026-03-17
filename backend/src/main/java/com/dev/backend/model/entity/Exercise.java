package com.dev.backend.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(
    name = "exercise",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_exercise_name", columnNames = "exercise_name")
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class Exercise {

    @Id
    @EqualsAndHashCode.Include
    @Column(length = 50)
    private String exerciseId;

    @Column(nullable = false, length = 100)
    private String exerciseName;

    @Column(length = 1000)
    private String description;

    @Column(length = 50)
    private String difficultyLevel;

    @Column(length = 50)
    private String exerciseType;

    @Column(length = 2000)
    private String instructions;

    private String videoUrl;

    private String imageUrl;

    private Integer caloriesBurnedPerMin;

    @Column(length = 2000)
    private String tips;

    @Column(nullable = false)
    private Boolean requiresSpotter = false;

    @Column(length = 50)
    private String equipmentCategory;

    @OneToMany(mappedBy = "exercise", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ExerciseMuscleGroup> exerciseMuscleGroups = new ArrayList<>();

    @OneToMany(mappedBy = "exercise", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ExerciseEquipment> exerciseEquipments = new ArrayList<>();

    @OneToMany(mappedBy = "originalExercise", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ExerciseAlternative> alternatives = new ArrayList<>();

    @OneToMany(mappedBy = "exercise", cascade = CascadeType.ALL)
    private List<SessionExercise> sessionExercises = new ArrayList<>();

    @OneToMany(mappedBy = "exercise", cascade = CascadeType.ALL)
    private List<ExerciseLog> exerciseLogs = new ArrayList<>();
}
