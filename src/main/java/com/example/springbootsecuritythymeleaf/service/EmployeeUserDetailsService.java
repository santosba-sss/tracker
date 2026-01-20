package com.example.springbootsecuritythymeleaf.service;

import com.example.springbootsecuritythymeleaf.model.Employee;
import com.example.springbootsecuritythymeleaf.repository.EmployeeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class EmployeeUserDetailsService implements UserDetailsService {

    private final EmployeeRepository employeeRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // Check if it's admin
        if ("admin".equals(username)) {
            return User.builder()
                .username("admin")
                .password("adminpass")
                .authorities(Collections.singletonList(new SimpleGrantedAuthority("ROLE_ADMIN")))
                .build();
        }
        
        // Look for employee by name (case-insensitive)
        Optional<Employee> employee = employeeRepository.findAll().stream()
            .filter(emp -> emp.getName().equalsIgnoreCase(username))
            .findFirst();
            
        if (employee.isPresent()) {
            return User.builder()
                .username(employee.get().getName())
                .password("") // No password required for employees
                .authorities(Collections.singletonList(new SimpleGrantedAuthority("ROLE_USER")))
                .build();
        }
        
        throw new UsernameNotFoundException("User not found: " + username);
    }
}