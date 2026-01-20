package com.example.springbootsecuritythymeleaf.repository;

import com.example.springbootsecuritythymeleaf.model.PtlRecord;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PtlRecordRepository extends JpaRepository<PtlRecord, Long> {
}
