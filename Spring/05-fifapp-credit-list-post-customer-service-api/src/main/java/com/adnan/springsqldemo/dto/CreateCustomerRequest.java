package com.adnan.springsqldemo.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class CreateCustomerRequest {
  @JsonProperty("full_name")
  private String fullName;

  @JsonProperty("identity_number")
  private String identityNumber;

  @JsonProperty("phone_number")
  private String phoneNumber;
}
