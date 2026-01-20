package com.example.springbootsecuritythymeleaf.model;

import jakarta.persistence.*;
import lombok.Data;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "employee")
@Data
public class Employee {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    
    @Column(unique = true)
    private String username; // Links employee to user account
    
    // Lunch break configuration
    @Column(name = "lunch_break_start")
    private String lunchBreakStart = "12:00";
    
    @Column(name = "lunch_break_end")
    private String lunchBreakEnd = "13:00";
    
    @OneToMany(mappedBy = "employee", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OvertimeRecord> overtimeRecords = new ArrayList<>();
    
    @OneToMany(mappedBy = "employee", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<PtlRecord> ptlRecords = new ArrayList<>();
    
    @OneToMany(mappedBy = "employee", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RenderRecord> renderRecords = new ArrayList<>();
    
    @OneToMany(mappedBy = "employee", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OffsetRecord> offsetRecords = new ArrayList<>();
    
    @OneToMany(mappedBy = "employee", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<LeaveRecord> leaveRecords = new ArrayList<>();
}
