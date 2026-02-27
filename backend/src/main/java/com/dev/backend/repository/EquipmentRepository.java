package com.dev.backend.repository;

import com.dev.backend.model.entity.Equipment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface EquipmentRepository extends JpaRepository<Equipment, Long> {

    Optional<Equipment> findByEquipmentName(String equipmentName);

    boolean existsByEquipmentName(String equipmentName);
}
