package com.adnan.springsqldemo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class VehicleResponse {
  private Long id;
  private String plateNumber;
  private String brand;
  private String model;
  private Integer manufacturingYear;
}
