package com.adnan.springsqldemo.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Entity
@Table(name = "credit_applications")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreditApplication {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id")
  private Long id;

  @ManyToOne
  @JoinColumn(name = "customer_id")
  private Customer customer;

  @ManyToOne
  @JoinColumn(name = "vehicle_id")
  private Vehicle vehicle;

  @Column(name = "branch_id")
  private Long branchId;

  @Column(name = "loan_amount")
  private BigDecimal loanAmount;

  @Column(name = "tenor_month")
  private Integer tenorMonth;

  @Column(name = "status")
  private String status;

  public CreditApplication(Customer customer, Vehicle vehicle, Long branchId, BigDecimal loanAmount, Integer tenorMonth, String status) {
    this.customer = customer;
    this.vehicle = vehicle;
    this.branchId = branchId;
    this.loanAmount = loanAmount;
    this.tenorMonth = tenorMonth;
    this.status = status;
  }
}
