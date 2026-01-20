package com.example.springbootsecuritythymeleaf.web;

import com.example.springbootsecuritythymeleaf.model.*;
import com.example.springbootsecuritythymeleaf.service.OvertimeService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDate;
import java.util.List;

@Controller
@RequestMapping("/overtime")
@RequiredArgsConstructor
public class OvertimeController {
    private final OvertimeService overtimeService;
    
    @GetMapping
    public String index(Model model, @RequestParam(required = false) Long selectedId, Authentication authentication) {
        List<Employee> employees = overtimeService.getAllEmployees();
        model.addAttribute("employees", employees);
        
        // If no employee is selected and user is not admin, auto-select their own record
        if (selectedId == null && !authentication.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"))) {
            Employee userEmployee = employees.stream()
                .filter(emp -> authentication.getName().equalsIgnoreCase(emp.getName()))
                .findFirst().orElse(null);
            if (userEmployee != null) {
                selectedId = userEmployee.getId();
            }
        }
        
        if (selectedId != null) {
            Employee emp = overtimeService.getEmployee(selectedId);
            if (emp != null) {
                model.addAttribute("selectedEmployee", emp);
                model.addAttribute("totalOT", overtimeService.calculateTotalOT(emp));
                model.addAttribute("totalPTL", overtimeService.calculateTotalPTL(emp));
                model.addAttribute("totalRender", overtimeService.calculateTotalRender(emp));
                model.addAttribute("totalOffsetUsed", overtimeService.calculateTotalOffset(emp));
                model.addAttribute("offset", overtimeService.calculateOffset(emp));
                model.addAttribute("renderBalance", overtimeService.calculateRenderBalance(emp));
                model.addAttribute("totalLeaves", overtimeService.calculateTotalLeaves(emp));
            }
        }
        return "overtime";
    }
    
    @GetMapping("/summary")
    public String summary(Model model, @RequestParam(required = false) String month) {
        model.addAttribute("employees", overtimeService.getAllEmployees());
        model.addAttribute("service", overtimeService);
        
        if (month != null && !month.isEmpty()) {
            java.time.YearMonth selectedMonth = java.time.YearMonth.parse(month);
            model.addAttribute("selectedMonth", month);
            model.addAttribute("selectedYearMonth", selectedMonth);
        }
        
        return "overtime-summary";
    }
    
    @GetMapping("/monthly")
    public String monthly(Model model, @RequestParam(required = false) Long selectedId, @RequestParam(required = false) String view, @RequestParam(required = false) String month) {
        model.addAttribute("employees", overtimeService.getAllEmployees());
        
        java.time.YearMonth selectedMonth = month != null ? java.time.YearMonth.parse(month) : java.time.YearMonth.now();
        model.addAttribute("selectedMonth", selectedMonth.toString());
        
        if ("all".equals(view) || (selectedId == null && view == null)) {
            model.addAttribute("allEmployeesData", overtimeService.getAllMonthlyData(selectedMonth));
            model.addAttribute("viewAll", true);
        } else if (selectedId != null) {
            Employee emp = overtimeService.getEmployee(selectedId);
            model.addAttribute("selectedEmployee", emp);
            model.addAttribute("monthlyData", overtimeService.getMonthlyData(emp, selectedMonth));
        }
        return "overtime-monthly";
    }
    
    @PostMapping("/employee/add")
    public String addEmployee(@RequestParam String name) {
        overtimeService.addEmployee(name);
        return "redirect:/overtime";
    }
    
    @PostMapping("/overtime/add")
    public String addOvertime(@RequestParam Long employeeId, 
                             @RequestParam String date,
                             @RequestParam String time,
                             @RequestParam String endTime) {
        OvertimeRecord record = new OvertimeRecord();
        record.setDate(LocalDate.parse(date));
        record.setTime(time);
        record.setEndTime(endTime);
        record.setMinutes(calculateMinutes(time, endTime));
        overtimeService.addOvertime(employeeId, record);
        return "redirect:/overtime?selectedId=" + employeeId;
    }
    
    @PostMapping("/ptl/add")
    public String addPtl(@RequestParam Long employeeId,
                        @RequestParam String date,
                        @RequestParam String time,
                        @RequestParam String endTime) {
        Employee employee = overtimeService.getEmployee(employeeId);
        PtlRecord record = new PtlRecord();
        record.setDate(LocalDate.parse(date));
        record.setTime(time);
        record.setEndTime(endTime);
        record.setMinutes(calculatePtlMinutes(time, endTime, employee));
        overtimeService.addPtl(employeeId, record);
        return "redirect:/overtime?selectedId=" + employeeId;
    }
    
    private int calculatePtlMinutes(String startTime, String endTime, Employee employee) {
        int totalMinutes = calculateMinutes(startTime, endTime);
        int lunchOverlap = calculateLunchBreakOverlap(startTime, endTime, 
            employee.getLunchBreakStart(), employee.getLunchBreakEnd());
        return totalMinutes - lunchOverlap;
    }
    
    private int calculateLunchBreakOverlap(String startTime, String endTime, String lunchStart, String lunchEnd) {
        if (lunchStart == null || lunchEnd == null) return 0;
        
        int start = timeToMinutes(startTime);
        int end = timeToMinutes(endTime);
        int lunchStartMin = timeToMinutes(lunchStart);
        int lunchEndMin = timeToMinutes(lunchEnd);
        
        int overlapStart = Math.max(start, lunchStartMin);
        int overlapEnd = Math.min(end, lunchEndMin);
        
        return Math.max(0, overlapEnd - overlapStart);
    }
    
    private int timeToMinutes(String time) {
        String[] parts = time.split(":");
        return Integer.parseInt(parts[0]) * 60 + Integer.parseInt(parts[1]);
    }
    
    private int calculateMinutes(String startTime, String endTime) {
        String[] start = startTime.split(":");
        String[] end = endTime.split(":");
        int startMinutes = Integer.parseInt(start[0]) * 60 + Integer.parseInt(start[1]);
        int endMinutes = Integer.parseInt(end[0]) * 60 + Integer.parseInt(end[1]);
        return endMinutes - startMinutes;
    }
    
    @PostMapping("/overtime/delete/{id}")
    public String deleteOvertime(@PathVariable Long id, @RequestParam Long employeeId) {
        overtimeService.deleteOvertime(id);
        return "redirect:/overtime?selectedId=" + employeeId;
    }
    
    @PostMapping("/ptl/delete/{id}")
    public String deletePtl(@PathVariable Long id, @RequestParam Long employeeId) {
        overtimeService.deletePtl(id);
        return "redirect:/overtime?selectedId=" + employeeId;
    }
    
    @PostMapping("/employee/delete/{id}")
    public String deleteEmployee(@PathVariable Long id) {
        overtimeService.deleteEmployee(id);
        return "redirect:/overtime";
    }
    
    @PostMapping("/render/add")
    public String addRender(@RequestParam Long employeeId,
                           @RequestParam String date,
                           @RequestParam String time,
                           @RequestParam String endTime) {
        RenderRecord record = new RenderRecord();
        record.setDate(LocalDate.parse(date));
        record.setTime(time);
        record.setEndTime(endTime);
        record.setMinutes(calculateMinutes(time, endTime));
        overtimeService.addRender(employeeId, record);
        return "redirect:/overtime?selectedId=" + employeeId;
    }
    
    @PostMapping("/render/delete/{id}")
    public String deleteRender(@PathVariable Long id, @RequestParam Long employeeId) {
        overtimeService.deleteRender(id);
        return "redirect:/overtime?selectedId=" + employeeId;
    }
    
    @PostMapping("/offset/add")
    public String addOffset(@RequestParam Long employeeId,
                           @RequestParam String date,
                           @RequestParam String time,
                           @RequestParam String endTime) {
        OffsetRecord record = new OffsetRecord();
        record.setDate(LocalDate.parse(date));
        record.setTime(time);
        record.setEndTime(endTime);
        record.setMinutes(calculateMinutes(time, endTime));
        overtimeService.addOffset(employeeId, record);
        return "redirect:/overtime?selectedId=" + employeeId;
    }
    
    @PostMapping("/offset/delete/{id}")
    public String deleteOffset(@PathVariable Long id, @RequestParam Long employeeId) {
        overtimeService.deleteOffset(id);
        return "redirect:/overtime?selectedId=" + employeeId;
    }
    
    @PostMapping("/leave/add")
    public String addLeave(@RequestParam Long employeeId, @RequestParam String startDate, @RequestParam String endDate, @RequestParam String leaveType) {
        LeaveRecord record = new LeaveRecord();
        record.setStartDate(startDate);
        record.setEndDate(endDate);
        record.setLeaveType(leaveType);
        overtimeService.addLeave(employeeId, record);
        return "redirect:/overtime?selectedId=" + employeeId;
    }
    
    @PostMapping("/leave/delete/{id}")
    public String deleteLeave(@PathVariable Long id, @RequestParam Long employeeId) {
        overtimeService.deleteLeave(id);
        return "redirect:/overtime?selectedId=" + employeeId;
    }
    
    @PostMapping("/employee/lunch-break/update")
    public String updateLunchBreak(@RequestParam Long employeeId,
                                  @RequestParam String lunchStart,
                                  @RequestParam String lunchEnd) {
        overtimeService.updateEmployeeLunchBreak(employeeId, lunchStart, lunchEnd);
        return "redirect:/overtime?selectedId=" + employeeId;
    }
}
