// DISABLED - Using in-memory authentication instead
/*
package com.example.springbootsecuritythymeleaf.config;

import com.example.springbootsecuritythymeleaf.model.User;
import com.example.springbootsecuritythymeleaf.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
@RequiredArgsConstructor
public class DataInitializer {

    private final PasswordEncoder passwordEncoder;

    @Bean
    CommandLineRunner init(UserRepository repo) {
        return args -> {
            if (repo.findByUsername("user").isEmpty()) {
                User u = User.builder()
                        .username("user")
                        .password(passwordEncoder.encode("password"))
                        .role("ROLE_USER")
                        .build();
                repo.save(u);
            }
            if (repo.findByUsername("admin").isEmpty()) {
                User a = User.builder()
                        .username("admin")
                        .password(passwordEncoder.encode("adminpass"))
                        .role("ROLE_ADMIN")
                        .build();
                repo.save(a);
            }
        };
    }
}
*/
