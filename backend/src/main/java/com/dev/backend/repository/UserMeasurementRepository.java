package com.dev.backend.repository;

import com.dev.backend.model.entity.UserMeasurement;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserMeasurementRepository extends JpaRepository<UserMeasurement, Long> {

    List<UserMeasurement> findByUserUserIdOrderByMeasurementDateDesc(Long userId);

    Page<UserMeasurement> findByUserUserId(Long userId, Pageable pageable);

    Optional<UserMeasurement> findTopByUserUserIdOrderByMeasurementDateDesc(Long userId);

    List<UserMeasurement> findByUserUserIdAndMeasurementDateBetween(Long userId, LocalDate start, LocalDate end);

    Optional<UserMeasurement> findByUserUserIdAndMeasurementDate(Long userId, LocalDate date);

    long countByUserUserId(Long userId);
}
