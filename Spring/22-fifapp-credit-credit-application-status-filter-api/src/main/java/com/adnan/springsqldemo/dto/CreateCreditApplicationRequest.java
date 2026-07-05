package com.adnan.springsqldemo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class CreateCreditApplicationRequest {
  private Long customerId;
  private Long vehicleId;
  private BigDecimal loanAmount;
  private Integer tenorMonth;
}
