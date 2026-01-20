package com.example.springbootsecuritythymeleaf.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class LeaveRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String startDate;
    private String endDate;
    private String leaveType;
    
    @ManyToOne
    @JoinColumn(name = "employee_id")
    private Employee employee;
}
