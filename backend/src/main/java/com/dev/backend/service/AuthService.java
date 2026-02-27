package com.dev.backend.service;


import com.dev.backend.model.dto.request.LoginRequestDto;
import com.dev.backend.model.dto.request.RegisterRequestDto;
import com.dev.backend.model.dto.response.AuthResponseDto;

public interface AuthService {
    AuthResponseDto loginWithEmailPassword(LoginRequestDto loginRequestDto);
    AuthResponseDto loginWithGoogle(String googleToken);
    AuthResponseDto refreshAccessToken(String refreshToken);
    boolean registerUser(RegisterRequestDto registerRequestDto);
    boolean registerWithGoogle(String googleToken);
    boolean logout(String email);
}
