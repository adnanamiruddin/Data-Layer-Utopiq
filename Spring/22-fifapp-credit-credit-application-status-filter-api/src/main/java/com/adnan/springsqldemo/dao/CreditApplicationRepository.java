package com.adnan.springsqldemo.dao;

import com.adnan.springsqldemo.entity.CreditApplication;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CreditApplicationRepository extends JpaRepository<CreditApplication, Long> {
  List<CreditApplication> findByStatus(String status);
}
