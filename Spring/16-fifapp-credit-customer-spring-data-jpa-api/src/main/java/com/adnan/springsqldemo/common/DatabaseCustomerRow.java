package com.adnan.springsqldemo.common;

import lombok.AllArgsConstructor;
import lombok.Getter;

@AllArgsConstructor
@Getter
public class DatabaseCustomerRow {
  private Long id;
  private String fullName;
  private String phoneNumber;
  private String email;
}
