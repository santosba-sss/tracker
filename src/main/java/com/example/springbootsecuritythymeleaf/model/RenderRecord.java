package com.example.springbootsecuritythymeleaf.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDate;

@Entity
@Table(name = "render_record")
@Data
public class RenderRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "render_date")
    private LocalDate date;
    
    @Column(name = "render_time")
    private String time;
    
    @Column(name = "end_time")
    private String endTime;
    
    private Integer minutes;
    
    @ManyToOne
    @JoinColumn(name = "employee_id")
    private Employee employee;
}
