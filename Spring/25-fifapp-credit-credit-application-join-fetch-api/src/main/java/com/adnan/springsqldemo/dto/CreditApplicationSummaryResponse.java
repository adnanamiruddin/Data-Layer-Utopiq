package com.adnan.springsqldemo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class CreditApplicationSummaryResponse {
  private Long id;
  private String status;
  private String customerName;
  private String customerPhoneNumber;
  private String vehicleName;
  private String plateNumber;
  private BigDecimal loanAmount;
  private Integer tenorMonth;
}
