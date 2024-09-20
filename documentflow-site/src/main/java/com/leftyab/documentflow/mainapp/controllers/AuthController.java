package com.leftyab.documentflow.mainapp.controllers;

import com.leftyab.spring.security.jwt.JwtTools;
import com.leftyab.spring.security.jwt.RefreshTokenService;
import com.leftyab.spring.security.jwt.controller.JwtAuthControllerBase;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.web.bind.annotation.*;

//@CrossOrigin(origins = "*", maxAge = 3600)

@RestController
@RequestMapping("/api/auth")
public class AuthController extends JwtAuthControllerBase {
  public AuthController(AuthenticationManager authenticationManager, JwtTools jwtTools, RefreshTokenService refreshTokenService){
    super(authenticationManager, jwtTools, refreshTokenService);
  }

}
