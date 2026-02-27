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
    name = "goal",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_goal_name", columnNames = "goal_name")
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class Goal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long goalId;

    @Column(nullable = false, length = 100)
    private String goalName;

    @Column(length = 500)
    private String description;

    @Column(length = 50)
    private String recommendedRepRange;

    @Column(length = 50)
    private String recommendedRestTime;

    @Column(length = 50)
    private String recommendedFrequency;

    private Integer targetCalorieAdjustment;

    @OneToMany(mappedBy = "goal", cascade = CascadeType.ALL)
    private List<WorkoutPlan> workoutPlans = new ArrayList<>();

    @OneToMany(mappedBy = "goal", cascade = CascadeType.ALL)
    private List<NutritionPlan> nutritionPlans = new ArrayList<>();
}
