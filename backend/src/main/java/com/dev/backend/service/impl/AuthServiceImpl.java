package com.dev.backend.service.impl;

import com.dev.backend.exception.BadRequestException;
import com.dev.backend.exception.DuplicateResourceException;
import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.exception.UnauthorizedException;
import com.dev.backend.mapper.AccountMapper;
import com.dev.backend.model.dto.request.LoginRequestDto;
import com.dev.backend.model.dto.request.RegisterRequestDto;
import com.dev.backend.model.dto.response.AuthResponseDto;
import com.dev.backend.model.entity.RefreshToken;
import com.dev.backend.model.entity.User;
import com.dev.backend.repository.UserRepository;
import com.dev.backend.service.AuthService;
import com.dev.backend.service.JwtService;
import com.dev.backend.service.RefreshTokenService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Service
@Slf4j
public class AuthServiceImpl implements AuthService {

    private final JwtService jwtService;
    private final RefreshTokenService refreshTokenService;
    private final AccountMapper accountMapper;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${jwt.access-token.expiration:900}")
    private long accessTokenExpiration;

    public AuthServiceImpl(JwtService jwtService,
                           RefreshTokenService refreshTokenService,
                           AccountMapper accountMapper,
                           UserRepository userRepository,
                           PasswordEncoder passwordEncoder) {
        this.jwtService = jwtService;
        this.refreshTokenService = refreshTokenService;
        this.accountMapper = accountMapper;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public AuthResponseDto loginWithEmailPassword(LoginRequestDto loginRequestDto) {
        var userOptional = userRepository.findByEmail(loginRequestDto.getEmail());
        
        if (userOptional.isEmpty()) {
            log.error("Email not found: {}", loginRequestDto.getEmail());
            throw new UnauthorizedException("Invalid email or password");
        }

        var userEntity = userOptional.get();
        
        if (!passwordEncoder.matches(loginRequestDto.getPassword(), userEntity.getPasswordHash())) {
            log.error("Invalid password for email: {}", loginRequestDto.getEmail());
            throw new UnauthorizedException("Invalid email or password");
        }

        // Generate access token
        String accessToken = jwtService.generateToken(
                userEntity.getUserId(), 
                userEntity.getEmail(), 
                userEntity.getRole()
        );
        
        // Create refresh token
        RefreshToken refreshToken = refreshTokenService.createRefreshToken(userEntity.getEmail());
        
        log.info("User logged in successfully: {}", loginRequestDto.getEmail());
        
        return AuthResponseDto.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken.getToken())
                .tokenType("Bearer")
                .expiresAt(Instant.now().plusSeconds(accessTokenExpiration).toEpochMilli())
                .user(accountMapper.toResponse(userEntity))
                .build();
    }

    @Override
    public AuthResponseDto loginWithGoogle(String googleToken) {
        log.warn("Google login not yet implemented");
        throw new UnsupportedOperationException("Google login not yet implemented");
    }

    @Override
    @Transactional
    public AuthResponseDto refreshAccessToken(String refreshToken) {
        // Use JwtService to create new access token from refresh token
        String accessToken = jwtService.createJwtFromRefreshToken(refreshToken);
        
        // Get user from refresh token
        RefreshToken storedToken = refreshTokenService.findByToken(refreshToken);
        if (storedToken == null) {
            throw new UnauthorizedException("Invalid refresh token");
        }
        
        User user = storedToken.getUser();
        
        log.info("Token refreshed for user: {}", user.getEmail());
        
        return AuthResponseDto.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)  // Keep same refresh token
                .tokenType("Bearer")
                .expiresAt(Instant.now().plusSeconds(accessTokenExpiration).toEpochMilli())
                .user(accountMapper.toResponse(user))
                .build();
    }

    @Override
    @Transactional
    public boolean registerUser(RegisterRequestDto registerRequestDto) {
        // Check for duplicate email
        if (userRepository.findByEmail(registerRequestDto.getEmail()).isPresent()) {
            log.error("Email already exists: {}", registerRequestDto.getEmail());
            throw new DuplicateResourceException("User", "email", registerRequestDto.getEmail());
        }

        // Check for duplicate username
        if (userRepository.findByUsername(registerRequestDto.getUsername()).isPresent()) {
            log.error("Username already exists: {}", registerRequestDto.getUsername());
            throw new DuplicateResourceException("User", "username", registerRequestDto.getUsername());
        }

        // Validate password confirmation
        if (!registerRequestDto.getPassword().equals(registerRequestDto.getConfirmPassword())) {
            log.error("Password and Confirm Password do not match");
            throw new BadRequestException("Password and Confirm Password do not match");
        }

        var userEntity = accountMapper.toEntity(registerRequestDto);
        userEntity.setPasswordHash(passwordEncoder.encode(registerRequestDto.getPassword()));
        userEntity.setRole(User.Role.USER);
        
        userRepository.save(userEntity);
        
        log.info("User registered successfully: {}", registerRequestDto.getEmail());
        return true;
    }

    @Override
    @Transactional
    public boolean registerWithGoogle(String googleToken) {
        log.warn("Google registration not yet implemented");
        throw new UnsupportedOperationException("Google registration not yet implemented");
    }

    @Override
    @Transactional
    public boolean logout(String email) {
        var userOptional = userRepository.findByEmail(email);
        if (userOptional.isEmpty()) {
            log.error("User not found for logout: {}", email);
            throw new ResourceNotFoundException("User", "email", email);
        }
        
        // Revoke all refresh tokens for user
        refreshTokenService.revokeRefreshTokenByAccountEmail(email);
        
        log.info("User logged out and all tokens revoked: {}", email);
        return true;
    }
}
