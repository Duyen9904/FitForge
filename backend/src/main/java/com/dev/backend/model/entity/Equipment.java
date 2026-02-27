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
    name = "equipment",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_equipment_name", columnNames = "equipment_name")
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class Equipment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long equipmentId;

    @Column(nullable = false, length = 100)
    private String equipmentName;

    @Column(length = 50)
    private String equipmentType;

    @Column(length = 500)
    private String description;

    @OneToMany(mappedBy = "equipment", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ExerciseEquipment> exerciseEquipments = new ArrayList<>();
}
