package com.adnan.springsqldemo.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CreateCustomerRequest {
  @JsonProperty("full_name")
  @NotBlank(message = "Full name is required")
  private String fullName;

  @JsonProperty("identity_number")
  @NotBlank(message = "Identity number is required")
  @Size(min = 16, max = 16, message = "Identity number must be 16 characters")
  private String identityNumber;

  @JsonProperty("phone_number")
  @NotBlank(message = "Phone number is required")
  private String phoneNumber;
}
