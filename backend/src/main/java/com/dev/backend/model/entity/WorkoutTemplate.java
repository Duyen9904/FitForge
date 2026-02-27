package com.dev.backend.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

/**
 * Reusable building block describing a parameterized workout structure.
 * Templates can be matched to user profiles and instantiated into WorkoutPlans.
 */
@Entity
@Table(name = "workout_template")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
public class WorkoutTemplate extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long templateId;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(length = 500)
    private String description;

    /**
     * Primary fitness goal this template targets.
     * E.g. "FAT_LOSS", "MUSCLE_GAIN", "STRENGTH", "ENDURANCE".
     */
    @Column(nullable = false, length = 50)
    private String goalType;

    /**
     * Target experience level: BEGINNER, INTERMEDIATE, ADVANCED.
     */
    @Column(nullable = false, length = 50)
    private String experienceLevel;

    /**
     * Comma-separated equipment tags required for this template.
     * E.g. "DUMBBELLS,BARBELL,BENCH".
     */
    @Column(length = 255)
    private String equipmentTags;

    /**
     * Number of training days per week this template is designed for.
     */
    @Column(nullable = false)
    private Integer daysPerWeek;

    /**
     * Relative intensity level (e.g. LOW, MODERATE, HIGH).
     */
    @Column(length = 50)
    private String intensityLevel;

    /**
     * Comma-separated primary muscle groups targeted.
     * E.g. "CHEST,BACK,LEGS".
     */
    @Column(length = 255)
    private String primaryMuscleGroups;

    /**
     * Comma-separated health constraints/contraindications this template avoids.
     * E.g. "LOWER_BACK_PAIN,SHOULDER_INJURY".
     */
    @Column(length = 255)
    private String contraindications;

    /**
     * Tags for future collaborative filtering or advanced matching.
     * JSON or comma-separated key-value pairs.
     */
    @Column(columnDefinition = "TEXT")
    private String metadata;

    @Column(nullable = false)
    private Boolean isActive = true;
}
