package com.adnan.springsqldemo.dao;

import com.adnan.springsqldemo.entity.CreditApplication;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CreditApplicationRepository extends JpaRepository<CreditApplication, Long> {
}
