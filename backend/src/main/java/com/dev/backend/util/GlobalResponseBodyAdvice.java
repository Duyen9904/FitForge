package com.dev.backend.util;

import com.dev.backend.model.dto.response.ApiResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.MethodParameter;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice(basePackages = "com.dev.backend")
@Slf4j
public class GlobalResponseBodyAdvice implements org.springframework.web.servlet.mvc.method.annotation.ResponseBodyAdvice<Object> {
    @Override
    public boolean supports(MethodParameter returnType, Class<? extends HttpMessageConverter<?>> converterType) {
        Class<?> returnClass = returnType.getParameterType();
        return !ApiResponse.class.isAssignableFrom(returnClass);
    }

    @Override
    public Object beforeBodyWrite(Object body, MethodParameter returnType, MediaType selectedContentType,
                                  Class<? extends HttpMessageConverter<?>> selectedConverterType,
                                  ServerHttpRequest request, ServerHttpResponse response) {


        if (!selectedContentType.includes(MediaType.APPLICATION_JSON)) {
            return body;
        }

        Class<?> returnClass = returnType.getParameterType();

        if (returnClass == ApiResponse.class || returnClass == ResponseEntity.class) {
            return body;
        }

        return ApiResponse.success(body);
    }
}
