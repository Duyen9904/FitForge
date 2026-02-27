package com.dev.backend.repository;

import com.dev.backend.model.entity.CheatMealLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface CheatMealLogRepository extends JpaRepository<CheatMealLog, Long> {

    long countByUserUserIdAndCheatDateBetween(Long userId, LocalDate start, LocalDate end);

    List<CheatMealLog> findByUserUserIdAndIsCompensatedFalse(Long userId);

    List<CheatMealLog> findByUserUserIdOrderByCheatDateDesc(Long userId);

    long countByUserUserIdAndCheatDateAfter(Long userId, LocalDate date);
}
