package com.adnan.springsqldemo.dao;

import com.adnan.springsqldemo.entity.CreditApplication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

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

  @Query(value = """
    SELECT
        count(ca.id),
        coalesce(sum(ca.loan_amount), 0),
        coalesce(avg(ca.loan_amount), 0),
        coalesce(min(ca.loan_amount), 0),
        coalesce(max(ca.loan_amount), 0)
    FROM credit_applications ca
    WHERE ca.branch_id = :branchId
    """, nativeQuery = true)
  Object[] calculateDashboardSummary(@Param("branchId") Long branchId);

  @Query(value = """
    SELECT
        ca.status,
        count(ca.id),
        coalesce(sum(ca.loan_amount), 0)
    FROM credit_applications ca
    WHERE ca.branch_id = :branchId
    GROUP BY ca.status
    ORDER BY count(ca.id) desc
    """, nativeQuery = true)
  List<Object[]> calculateDashboardByStatus(@Param("branchId") Long branchId);

  @Query(value = """
    SELECT
        cast(ca.tenor_month as varchar),
        count(ca.id),
        coalesce(sum(ca.loan_amount), 0)
    FROM credit_applications ca
    WHERE ca.branch_id = :branchId
    GROUP BY ca.tenor_month
    ORDER BY ca.tenor_month
    """, nativeQuery = true)
  List<Object[]> calculateDashboardByTenorMonth(@Param("branchId") Long branchId);

  @Query(value = """
    SELECT
        v.brand,
        count(ca.id),
        coalesce(sum(ca.loan_amount), 0)
    FROM credit_applications ca
    join vehicles v on v.id = ca.vehicle_id
    WHERE ca.branch_id = :branchId
    GROUP BY v.brand
    ORDER BY count(ca.id) desc
    """, nativeQuery = true)
  List<Object[]> calculateDashboardByVehicleBrand(@Param("branchId") Long branchId);
}
