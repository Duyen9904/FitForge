package com.dev.backend.repository;

import com.dev.backend.model.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    //login
    @Query("SELECT u FROM User u WHERE u.email = :email")
    Optional<User> findByEmail(String email);

    // Find user by username (for authentication)
    Optional<User> findByUsername(String username);

    /**
     * Check if a goal is used as primary goal by any user (UC-16.2)
     */
    boolean existsByPrimaryGoalGoalId(Long goalId);

    /**
     * Count users who joined after a specific date (UC-16.3)
     */
    @Query("SELECT COUNT(u) FROM User u WHERE u.dateJoined >= :since")
    long countActiveUsersSince(@Param("since") LocalDate since);
}
