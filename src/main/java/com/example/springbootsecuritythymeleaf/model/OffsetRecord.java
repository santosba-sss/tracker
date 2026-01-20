package com.example.springbootsecuritythymeleaf.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDate;

@Entity
@Table(name = "offset_record")
@Data
public class OffsetRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "offset_date")
    private LocalDate date;
    
    @Column(name = "offset_time")
    private String time;
    
    @Column(name = "end_time")
    private String endTime;
    
    private Integer minutes;
    
    @ManyToOne
    @JoinColumn(name = "employee_id")
    private Employee employee;
}
