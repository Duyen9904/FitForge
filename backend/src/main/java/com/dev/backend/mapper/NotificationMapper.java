package com.dev.backend.mapper;

import com.dev.backend.model.dto.request.RegisterDeviceTokenRequest;
import com.dev.backend.model.dto.response.NotificationResponse;
import com.dev.backend.model.entity.Notification;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;

/**
 * Mapper for Notification entity to DTO conversions (UC-15)
 */
@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface NotificationMapper extends BaseMapper<Notification, RegisterDeviceTokenRequest, NotificationResponse> {

    @Override
    NotificationResponse toResponse(Notification notification);

    @Override
    Notification toEntity(RegisterDeviceTokenRequest request);

    @Override
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntityFromRequest(@MappingTarget Notification entity, RegisterDeviceTokenRequest request);
}
