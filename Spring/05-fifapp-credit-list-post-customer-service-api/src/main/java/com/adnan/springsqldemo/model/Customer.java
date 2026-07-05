package com.adnan.springsqldemo.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Customer {
  private Long id;
  private String fullName;
  private String identityNumber;
  private String phoneNumber;
}
