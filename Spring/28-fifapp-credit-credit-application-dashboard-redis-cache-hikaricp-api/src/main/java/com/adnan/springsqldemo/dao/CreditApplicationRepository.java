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
        COUNT(ca.id),
        COALESCE(SUM(ca.loan_amount), 0),
        COALESCE(AVG(ca.loan_amount), 0),
        COALESCE(MIN(ca.loan_amount), 0),
        COALESCE(MAX(ca.loan_amount), 0)
    FROM credit_applications ca
    WHERE ca.branch_id = :branchId
    """, nativeQuery = true)
  Object[] calculateDashboardSummary(@Param("branchId") Long branchId);

  @Query(value = """
    SELECT
        ca.status,
        COUNT(ca.id),
        COALESCE(SUM(ca.loan_amount), 0)
    FROM credit_applications ca
    WHERE ca.branch_id = :branchId
    GROUP BY ca.status
    ORDER BY COUNT(ca.id) DESC
    """, nativeQuery = true)
  List<Object[]> calculateDashboardByStatus(@Param("branchId") Long branchId);

  @Query(value = """
    SELECT
        CAST(ca.tenor_month as varchar),
        COUNT(ca.id),
        COALESCE(SUM(ca.loan_amount), 0)
    FROM credit_applications ca
    WHERE ca.branch_id = :branchId
    GROUP BY ca.tenor_month
    ORDER BY ca.tenor_month
    """, nativeQuery = true)
  List<Object[]> calculateDashboardByTenorMonth(@Param("branchId") Long branchId);

  @Query(value = """
    SELECT
        v.brand,
        COUNT(ca.id),
        COALESCE(SUM(ca.loan_amount), 0)
    FROM credit_applications ca
    JOIN vehicles v ON v.id = ca.vehicle_id
    WHERE ca.branch_id = :branchId
    GROUP BY v.brand
    ORDER BY COUNT(ca.id) DESC
    """, nativeQuery = true)
  List<Object[]> calculateDashboardByVehicleBrand(@Param("branchId") Long branchId);
}
