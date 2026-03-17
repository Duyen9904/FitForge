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
    name = "user",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_user_username", columnNames = "username"),
        @UniqueConstraint(name = "uk_user_email", columnNames = "email")
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long userId;

    @Column(nullable = false, unique = true, length = 50)
    private String username;

    @Column(nullable = false, unique = true, length = 100)
    private String email;

    @Column(nullable = false)
    private String passwordHash;

    private LocalDate dateOfBirth;

    @Column(length = 20)
    private String gender;

    private Float heightCm;

    private Float currentWeightKg;

    private Float targetWeightKg;

    @Column(nullable = false)
    private LocalDate dateJoined;

    @Column(length = 50)
    private String fitnessLevel;

    private String profileImageUrl;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    // Primary fitness goal for recommendations (UC-12.2)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "primary_goal_id")
    private Goal primaryGoal;

    // One-to-One Relationships
    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private UserPreference userPreference;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private NutritionPlan nutritionPlan;

    // One-to-Many Relationships
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<WorkoutPlan> workoutPlans = new ArrayList<>();

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<WorkoutProgress> workoutProgressList = new ArrayList<>();

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<UserMeasurement> userMeasurements = new ArrayList<>();

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<PlanMeal> planMeals = new ArrayList<>();



    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<MissedWorkout> missedWorkouts = new ArrayList<>();

    // Onboarding tracking (UC-17)
    @Column(nullable = false)
    private Boolean onboardingCompleted = false;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<UserOnboardingProgress> onboardingProgress = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        if (dateJoined == null) {
            dateJoined = LocalDate.now();
        }
    }

    public enum Role {
        USER,
        ADMIN
    }
}
