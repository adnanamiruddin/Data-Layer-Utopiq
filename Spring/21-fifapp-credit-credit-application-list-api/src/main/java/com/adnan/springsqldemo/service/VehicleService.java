package com.adnan.springsqldemo.service;

import com.adnan.springsqldemo.dto.CreateVehicleRequest;
import com.adnan.springsqldemo.dto.VehicleResponse;

import java.util.List;

public interface VehicleService {
  VehicleResponse createVehicle(CreateVehicleRequest request);

  List<VehicleResponse> getAllVehicles();

  VehicleResponse getVehicleById(Long id);
}
