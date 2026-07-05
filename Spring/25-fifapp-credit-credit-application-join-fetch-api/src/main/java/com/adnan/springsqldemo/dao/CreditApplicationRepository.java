package com.adnan.springsqldemo.dao;

import com.adnan.springsqldemo.entity.CreditApplication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface CreditApplicationRepository extends JpaRepository<CreditApplication, Long> {
  List<CreditApplication> findByStatus(String status);

  @Query("""
    SELECT creditApplication
    FROM CreditApplication creditApplication
    JOIN FETCH creditApplication.customer
    JOIN FETCH creditApplication.vehicle
    """)
  List<CreditApplication> findAllWithCustomerAndVehicle();

  @Query("""
    SELECT creditApplication
    FROM CreditApplication creditApplication
    JOIN FETCH creditApplication.customer
    JOIN FETCH creditApplication.vehicle
    WHERE creditApplication.status = :status
    """)
  List<CreditApplication> findByStatusWithCustomerAndVehicle(String status);
}
