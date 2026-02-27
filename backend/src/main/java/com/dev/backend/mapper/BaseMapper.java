package com.dev.backend.mapper;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Base mapper interface with common mapping operations
 * @param <E> Entity type
 * @param <REQ> Request DTO type
 * @param <RES> Response DTO type
 */
public interface BaseMapper<E, REQ, RES> {

    /**
     * Convert entity to response DTO
     */
    RES toResponse(E entity);

    /**
     * Convert request DTO to entity
     */
    E toEntity(REQ request);

    /**
     * Update existing entity from request DTO
     */
    void updateEntityFromRequest(E entity, REQ request);

    /**
     * Convert list of entities to list of response DTOs
     */
    default List<RES> toResponseList(List<E> entities) {
        if (entities == null || entities.isEmpty()) {
            return List.of();
        }
        return entities.stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * Convert list of request DTOs to list of entities
     */
    default List<E> toEntityList(List<REQ> requests) {
        if (requests == null || requests.isEmpty()) {
            return List.of();
        }
        return requests.stream()
                .map(this::toEntity)
                .collect(Collectors.toList());
    }
}
