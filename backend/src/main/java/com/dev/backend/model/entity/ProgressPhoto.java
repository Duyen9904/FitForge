package com.dev.backend.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

/**
 * Entity for storing progress/transformation photos (UC-8.4)
 */
@Entity
@Table(
    name = "progress_photo",
    indexes = {
        @Index(name = "idx_progress_photo_user", columnList = "user_id"),
        @Index(name = "idx_progress_photo_date", columnList = "photo_date")
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
public class ProgressPhoto extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long photoId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private LocalDate photoDate;

    @Column(nullable = false, length = 500)
    private String photoUrl;

    @Column(length = 50)
    private String category; // "front", "side", "back"

    @Column(length = 500)
    private String notes;
}
