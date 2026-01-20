package com.example.springbootsecuritythymeleaf.config;

import com.example.springbootsecuritythymeleaf.model.Employee;
import com.example.springbootsecuritythymeleaf.repository.EmployeeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class EmployeeDataInitializer implements CommandLineRunner {

    private final EmployeeRepository employeeRepository;

    @Override
    public void run(String... args) throws Exception {
        // Create sample employees
        if (employeeRepository.count() == 0) {
            Employee emp1 = new Employee();
            emp1.setName("John Doe");
            employeeRepository.save(emp1);
            
            Employee emp2 = new Employee();
            emp2.setName("Jane Smith");
            employeeRepository.save(emp2);
        }
    }
}