package com.adnan.springsqldemo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class CreditApplicationResponse {
  private Long id;
  private Long customerId;
  private String customerName;
  private Long vehicleId;
  private String plateNumber;
  private Long branchId;
  private BigDecimal loanAmount;
  private Integer tenorMonth;
  private String status;
}
