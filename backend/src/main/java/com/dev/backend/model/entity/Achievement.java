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
    name = "achievement",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_achievement_name", columnNames = "achievement_name")
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class Achievement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long achievementId;

    @Column(nullable = false, length = 100)
    private String achievementName;

    @Column(length = 500)
    private String description;

    private String badgeIconUrl;

    @Column(length = 500)
    private String criteria;

    private Integer points;

    @Column(length = 50)
    private String category;

    @OneToMany(mappedBy = "achievement", cascade = CascadeType.ALL)
    private List<UserAchievement> userAchievements = new ArrayList<>();
}
