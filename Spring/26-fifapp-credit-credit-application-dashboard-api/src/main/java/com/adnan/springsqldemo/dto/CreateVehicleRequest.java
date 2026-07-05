package com.adnan.springsqldemo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class CreateVehicleRequest {
  private String plateNumber;
  private String brand;
  private String model;
  private Integer manufacturingYear;
}
