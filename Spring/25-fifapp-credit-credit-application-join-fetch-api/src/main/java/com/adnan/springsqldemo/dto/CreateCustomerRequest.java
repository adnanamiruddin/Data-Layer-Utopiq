package com.adnan.springsqldemo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class CreateCustomerRequest {
  private String fullName;
  private String phoneNumber;
  private String email;
}