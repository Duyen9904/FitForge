package com.dev.backend.repository;

import com.dev.backend.model.entity.ProgressPhoto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProgressPhotoRepository extends JpaRepository<ProgressPhoto, Long> {

    List<ProgressPhoto> findByUserUserIdOrderByPhotoDateDesc(Long userId);

    List<ProgressPhoto> findByUserUserIdAndCategory(Long userId, String category);

    Optional<ProgressPhoto> findByPhotoIdAndUserUserId(Long photoId, Long userId);
}
