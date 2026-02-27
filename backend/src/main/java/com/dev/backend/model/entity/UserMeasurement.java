package com.dev.backend.model.entity;

import com.dev.backend.model.enums.MeasurementSource;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Entity
@Table(name = "user_measurement")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class UserMeasurement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long measurementId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private LocalDate measurementDate;

    private Float weightKg;

    private Float bodyFatPercentage;

    private Float chestCm;

    private Float waistCm;

    private Float hipsCm;

    private Float bicepsCm;

    private Float thighsCm;

    // ========== InBody-specific fields ==========
    
    /** Skeletal Muscle Mass (SMM) in kg */
    private Float skeletalMuscleMass;
    
    /** Body Fat Mass in kg */
    private Float bodyFatMass;
    
    /** Total Body Water in liters */
    private Float bodyWaterLiters;
    
    /** Basal Metabolic Rate in kcal */
    private Integer basalMetabolicRate;
    
    /** Visceral Fat Level (1-20 scale) */
    private Integer visceralFatLevel;
    
    /** Waist-Hip Ratio */
    private Float waistHipRatio;
    
    /** InBody Score (0-100) */
    private Integer inBodyScore;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private MeasurementSource source;

    @Column(length = 500)
    private String notes;
}
