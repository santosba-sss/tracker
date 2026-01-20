package com.example.springbootsecuritythymeleaf.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDate;

@Entity
@Table(name = "ptl_record")
@Data
public class PtlRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "ptl_date")
    private LocalDate date;
    
    @Column(name = "ptl_time")
    private String time;
    
    @Column(name = "end_time")
    private String endTime;
    
    private Integer minutes;
    
    @ManyToOne
    @JoinColumn(name = "employee_id")
    private Employee employee;
}
