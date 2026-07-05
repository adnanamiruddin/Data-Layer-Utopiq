package com.adnan.springsqldemo.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "vehicles")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Vehicle {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id")
  private Long id;

  @Column(name = "plate_number")
  private String plateNumber;

  @Column(name = "brand")
  private String brand;

  @Column(name = "model")
  private String model;

  @Column(name = "manufacturing_year")
  private Integer manufacturingYear;

  public Vehicle(String plateNumber, String brand, String model, Integer manufacturingYear) {
    this.plateNumber = plateNumber;
    this.brand = brand;
    this.model = model;
    this.manufacturingYear = manufacturingYear;
  }
}
