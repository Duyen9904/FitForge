package com.dev.backend.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(
    name = "exercise_alternative",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_exercise_alternative", columnNames = {"original_exercise_id", "alternative_exercise_id"})
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class ExerciseAlternative {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long alternativeId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "original_exercise_id", nullable = false)
    private Exercise originalExercise;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "alternative_exercise_id", nullable = false)
    private Exercise alternativeExercise;

    @Column(length = 500)
    private String reason;

    @Column(length = 50)
    private String substitutionType;
}
