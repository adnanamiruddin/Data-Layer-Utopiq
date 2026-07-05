package com.adnan.springsqldemo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class DashboardGroupResponse {
  private String label;
  private Long applicationCount;
  private BigDecimal totalLoanAmount;
}
