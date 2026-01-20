package com.example.springbootsecuritythymeleaf.service;

import com.example.springbootsecuritythymeleaf.model.*;
import com.example.springbootsecuritythymeleaf.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OvertimeService {
    private final EmployeeRepository employeeRepository;
    private final OvertimeRecordRepository overtimeRecordRepository;
    private final PtlRecordRepository ptlRecordRepository;
    private final RenderRecordRepository renderRecordRepository;
    private final OffsetRecordRepository offsetRecordRepository;
    private final LeaveRecordRepository leaveRecordRepository;
    
    public List<Employee> getAllEmployees() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        boolean isAdmin = auth.getAuthorities().stream()
            .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
        
        if (isAdmin) {
            return employeeRepository.findAll().stream()
                .sorted((e1, e2) -> e1.getName().compareToIgnoreCase(e2.getName()))
                .collect(Collectors.toList());
        } else {
            // Regular users can only see their own employee record
            return employeeRepository.findAll().stream()
                .filter(emp -> auth.getName().equalsIgnoreCase(emp.getName()))
                .sorted((e1, e2) -> e1.getName().compareToIgnoreCase(e2.getName()))
                .collect(Collectors.toList());
        }
    }
    
    public Employee getEmployee(Long id) {
        Employee emp = employeeRepository.findById(id).orElse(null);
        if (emp != null && !canAccessEmployee(emp)) {
            return null; // User cannot access this employee
        }
        return emp;
    }
    
    private boolean canAccessEmployee(Employee emp) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        boolean isAdmin = auth.getAuthorities().stream()
            .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
        
        return isAdmin || auth.getName().equalsIgnoreCase(emp.getName());
    }
    
    @Transactional
    public Employee addEmployee(String name) {
        Employee emp = new Employee();
        emp.setName(name);
        return employeeRepository.save(emp);
    }
    
    @Transactional
    public Employee addEmployee(String name, String username) {
        Employee emp = new Employee();
        emp.setName(name);
        emp.setUsername(username);
        return employeeRepository.save(emp);
    }
    
    @Transactional
    public void addOvertime(Long employeeId, OvertimeRecord record) {
        Employee emp = employeeRepository.findById(employeeId).orElseThrow();
        record.setEmployee(emp);
        overtimeRecordRepository.save(record);
    }
    
    @Transactional
    public void addPtl(Long employeeId, PtlRecord record) {
        Employee emp = employeeRepository.findById(employeeId).orElseThrow();
        record.setEmployee(emp);
        ptlRecordRepository.save(record);
    }
    
    @Transactional
    public void addRender(Long employeeId, RenderRecord record) {
        Employee emp = employeeRepository.findById(employeeId).orElseThrow();
        record.setEmployee(emp);
        renderRecordRepository.save(record);
    }
    
    @Transactional
    public void deleteOvertime(Long id) {
        overtimeRecordRepository.deleteById(id);
    }
    
    @Transactional
    public void deletePtl(Long id) {
        ptlRecordRepository.deleteById(id);
    }
    
    @Transactional
    public void deleteRender(Long id) {
        renderRecordRepository.deleteById(id);
    }
    
    @Transactional
    public void addOffset(Long employeeId, OffsetRecord record) {
        Employee emp = employeeRepository.findById(employeeId).orElseThrow();
        record.setEmployee(emp);
        offsetRecordRepository.save(record);
    }
    
    @Transactional
    public void deleteOffset(Long id) {
        offsetRecordRepository.deleteById(id);
    }
    
    @Transactional
    public void deleteEmployee(Long id) {
        employeeRepository.deleteById(id);
    }
    
    public int calculateTotalOT(Employee emp) {
        return emp.getOvertimeRecords().stream().mapToInt(OvertimeRecord::getMinutes).sum();
    }
    
    public int calculateTotalPTL(Employee emp) {
        return emp.getPtlRecords().stream().mapToInt(PtlRecord::getMinutes).sum();
    }
    
    public int calculateTotalRender(Employee emp) {
        return emp.getRenderRecords().stream().mapToInt(RenderRecord::getMinutes).sum();
    }
    
    public int calculateTotalOffset(Employee emp) {
        return emp.getOffsetRecords().stream().mapToInt(OffsetRecord::getMinutes).sum();
    }
    
    public int calculateOffset(Employee emp) {
        return calculateTotalOT(emp) - calculateTotalOffset(emp);
    }
    
    public int calculateRenderBalance(Employee emp) {
        return calculateTotalPTL(emp) - calculateTotalRender(emp);
    }
    
    @Transactional
    public void addLeave(Long employeeId, LeaveRecord record) {
        Employee emp = employeeRepository.findById(employeeId).orElseThrow();
        record.setEmployee(emp);
        leaveRecordRepository.save(record);
    }
    
    @Transactional
    public void deleteLeave(Long id) {
        leaveRecordRepository.deleteById(id);
    }
    
    public int calculateTotalLeaves(Employee emp) {
        return emp.getLeaveRecords().stream()
            .mapToInt(r -> {
                LocalDate start = LocalDate.parse(r.getStartDate());
                LocalDate end = LocalDate.parse(r.getEndDate());
                return (int) start.datesUntil(end.plusDays(1))
                    .filter(date -> date.getDayOfWeek().getValue() <= 5)
                    .count();
            })
            .sum();
    }
    
    public int calculateMonthlyOT(Employee emp, java.time.YearMonth month) {
        return emp.getOvertimeRecords().stream()
            .filter(r -> java.time.YearMonth.from(r.getDate()).equals(month))
            .mapToInt(OvertimeRecord::getMinutes).sum();
    }
    
    public int calculateMonthlyPTL(Employee emp, java.time.YearMonth month) {
        return emp.getPtlRecords().stream()
            .filter(r -> java.time.YearMonth.from(r.getDate()).equals(month))
            .mapToInt(PtlRecord::getMinutes).sum();
    }
    
    public int calculateMonthlyRender(Employee emp, java.time.YearMonth month) {
        return emp.getRenderRecords().stream()
            .filter(r -> java.time.YearMonth.from(r.getDate()).equals(month))
            .mapToInt(RenderRecord::getMinutes).sum();
    }
    
    public int calculateMonthlyOffset(Employee emp, java.time.YearMonth month) {
        return emp.getOffsetRecords().stream()
            .filter(r -> java.time.YearMonth.from(r.getDate()).equals(month))
            .mapToInt(OffsetRecord::getMinutes).sum();
    }
    
    public int calculateMonthlyLeaves(Employee emp, java.time.YearMonth month) {
        return (int) emp.getLeaveRecords().stream()
            .mapToInt(r -> {
                LocalDate start = LocalDate.parse(r.getStartDate());
                LocalDate end = LocalDate.parse(r.getEndDate());
                LocalDate monthStart = month.atDay(1);
                LocalDate monthEnd = month.atEndOfMonth();
                
                LocalDate rangeStart = start.isBefore(monthStart) ? monthStart : start;
                LocalDate rangeEnd = end.isAfter(monthEnd) ? monthEnd : end;
                
                if (rangeStart.isAfter(rangeEnd)) return 0;
                return (int) rangeStart.datesUntil(rangeEnd.plusDays(1))
                    .filter(date -> date.getDayOfWeek().getValue() <= 5)
                    .count();
            })
            .sum();
    }
    
    public java.util.Map<String, Object> getMonthlyData(Employee emp, java.time.YearMonth selectedMonth) {
        java.util.Map<String, Object> data = new java.util.LinkedHashMap<>();
        
        java.util.List<String> allDates = new java.util.ArrayList<>();
        for (int day = 1; day <= selectedMonth.lengthOfMonth(); day++) {
            allDates.add(selectedMonth.atDay(day).toString());
        }
        data.put("dates", allDates);
        
        java.util.Map<String, String> otMap = new java.util.HashMap<>();
        emp.getOvertimeRecords().forEach(r -> otMap.put(r.getDate().toString(), r.getTime() + " - " + r.getEndTime()));
        data.put("overtime", otMap);
        
        java.util.Map<String, String> ptlMap = new java.util.HashMap<>();
        emp.getPtlRecords().forEach(r -> ptlMap.put(r.getDate().toString(), r.getTime() + " - " + r.getEndTime()));
        data.put("ptl", ptlMap);
        
        java.util.Map<String, String> offsetMap = new java.util.HashMap<>();
        emp.getOffsetRecords().forEach(r -> offsetMap.put(r.getDate().toString(), r.getTime() + " - " + r.getEndTime()));
        data.put("offset", offsetMap);
        
        java.util.Map<String, String> renderMap = new java.util.HashMap<>();
        emp.getRenderRecords().forEach(r -> renderMap.put(r.getDate().toString(), r.getTime() + " - " + r.getEndTime()));
        data.put("render", renderMap);
        
        java.util.Map<String, String> leaveMap = new java.util.HashMap<>();
        emp.getLeaveRecords().forEach(r -> {
            LocalDate start = LocalDate.parse(r.getStartDate());
            LocalDate end = LocalDate.parse(r.getEndDate());
            start.datesUntil(end.plusDays(1))
                .filter(date -> date.getDayOfWeek().getValue() <= 5)
                .forEach(date -> 
                    leaveMap.put(date.toString(), r.getLeaveType())
                );
        });
        data.put("leave", leaveMap);
        
        return data;
    }
    
    public java.util.List<java.util.Map<String, Object>> getAllMonthlyData(java.time.YearMonth selectedMonth) {
        java.util.List<java.util.Map<String, Object>> allData = new java.util.ArrayList<>();
        for (Employee emp : getAllEmployees()) {
            java.util.Map<String, Object> empData = getMonthlyData(emp, selectedMonth);
            empData.put("employeeName", emp.getName());
            allData.add(empData);
        }
        return allData;
    }
    
    @Transactional
    public void updateEmployeeLunchBreak(Long employeeId, String lunchStart, String lunchEnd) {
        Employee emp = employeeRepository.findById(employeeId).orElseThrow();
        emp.setLunchBreakStart(lunchStart);
        emp.setLunchBreakEnd(lunchEnd);
        employeeRepository.save(emp);
    }
}