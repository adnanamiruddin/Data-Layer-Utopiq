package com.adnan.springsqldemo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreditApplicationDashboardResponse {
  private Long branchId;
  private Long totalApplications;
  private BigDecimal totalLoanAmount;
  private BigDecimal averageLoanAmount;
  private BigDecimal minimumLoanAmount;
  private BigDecimal maximumLoanAmount;
  private List<DashboardGroupResponse> applicationsByStatus;
  private List<DashboardGroupResponse> applicationsByTenorMonth;
  private List<DashboardGroupResponse> applicationsByVehicleBrand;
}
