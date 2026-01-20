package com.example.springbootsecuritythymeleaf.repository;

import com.example.springbootsecuritythymeleaf.model.OffsetRecord;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OffsetRecordRepository extends JpaRepository<OffsetRecord, Long> {
}
