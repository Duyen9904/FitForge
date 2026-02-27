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
    name = "muscle_group",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_muscle_group_name", columnNames = "group_name")
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class MuscleGroup {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long muscleGroupId;

    @Column(nullable = false, length = 100)
    private String groupName;

    @Column(length = 50)
    private String category;

    @Column(length = 500)
    private String description;

    private Integer recoveryDaysNeeded;

    @OneToMany(mappedBy = "muscleGroup", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ExerciseMuscleGroup> exerciseMuscleGroups = new ArrayList<>();
}
