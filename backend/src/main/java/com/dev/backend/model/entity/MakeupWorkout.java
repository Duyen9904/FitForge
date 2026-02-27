package com.dev.backend.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Entity
@Table(
    name = "makeup_workout",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_makeup_workout_compensation", columnNames = "compensation_action_id")
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class MakeupWorkout {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long makeupId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "compensation_action_id", nullable = false, unique = true)
    private CompensationAction compensationAction;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "original_session_id", nullable = false)
    private WorkoutSession originalSession;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "replacement_session_id")
    private WorkoutSession replacementSession;

    @Column(nullable = false)
    private LocalDate scheduledMakeupDate;

    @Column(length = 50)
    private String adjustmentType;

    @Column(length = 500)
    private String adjustmentNotes;

    @Column(nullable = false)
    private Boolean isCompleted = false;
}
