package com.dev.backend.repository;

import com.dev.backend.model.entity.SessionExercise;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SessionExerciseRepository extends JpaRepository<SessionExercise, Long> {

    List<SessionExercise> findByWorkoutSessionSessionIdOrderByOrderIndex(Long sessionId);

    void deleteByWorkoutSessionSessionId(Long sessionId);
}
