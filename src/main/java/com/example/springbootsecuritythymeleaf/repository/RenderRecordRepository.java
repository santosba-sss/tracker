package com.example.springbootsecuritythymeleaf.repository;

import com.example.springbootsecuritythymeleaf.model.RenderRecord;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RenderRecordRepository extends JpaRepository<RenderRecord, Long> {
}
