package com.example.springbootsecuritythymeleaf.repository;

import com.example.springbootsecuritythymeleaf.model.OvertimeRecord;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OvertimeRecordRepository extends JpaRepository<OvertimeRecord, Long> {
}
