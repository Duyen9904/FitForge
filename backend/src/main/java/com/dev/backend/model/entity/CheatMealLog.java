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
@Table(
    name = "cheat_meal_log",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_cheat_meal_log_nutrition_log", columnNames = "nutrition_log_id")
    },
    indexes = {
        @Index(name = "idx_cheat_meal_log_user", columnList = "user_id"),
        @Index(name = "idx_cheat_meal_log_date", columnList = "cheat_date"),
        @Index(name = "idx_cheat_meal_log_user_date", columnList = "user_id, cheat_date")
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
public class CheatMealLog extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long cheatMealLogId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "nutrition_log_id", nullable = false, unique = true)
    private NutritionLog nutritionLog;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private LocalDate cheatDate;

    private Integer excessCalories;

    @Column(length = 500)
    private String compensationStrategy;

    @Column(nullable = false)
    private Boolean isCompensated = false;

    @OneToMany(mappedBy = "cheatMealLog", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<CompensationAction> compensationActions = new ArrayList<>();
}

