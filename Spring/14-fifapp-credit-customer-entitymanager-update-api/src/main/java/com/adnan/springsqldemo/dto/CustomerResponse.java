package com.adnan.springsqldemo.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class CustomerResponse {
  private Long id;

  @JsonProperty("full_name")
  private String fullName;

  @JsonProperty("identity_number")
  private String identityNumber;

  @JsonProperty("phone_number")
  private String phoneNumber;
}
