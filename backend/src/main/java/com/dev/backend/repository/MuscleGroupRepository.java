package com.dev.backend.repository;

import com.dev.backend.model.entity.MuscleGroup;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MuscleGroupRepository extends JpaRepository<MuscleGroup, Long> {

    Optional<MuscleGroup> findByGroupName(String groupName);

    Optional<MuscleGroup> findFirstByCategory(String category);

    boolean existsByGroupName(String groupName);
}
