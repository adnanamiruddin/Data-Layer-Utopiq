package com.adnan.springsqldemo.service.impl;

import com.adnan.springsqldemo.dao.VehicleRepository;
import com.adnan.springsqldemo.dto.CreateVehicleRequest;
import com.adnan.springsqldemo.dto.VehicleResponse;
import com.adnan.springsqldemo.entity.Vehicle;
import com.adnan.springsqldemo.service.VehicleService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class VehicleServiceImpl implements VehicleService {
  private final VehicleRepository vehicleRepository;

  @Transactional
  @Override
  public VehicleResponse createVehicle(CreateVehicleRequest request) {
    Vehicle newVehicle = new Vehicle(
      request.getPlateNumber(),
      request.getBrand(),
      request.getModel(),
      request.getManufacturingYear()
    );
    Vehicle savedVehicle = vehicleRepository.save(newVehicle);
    return mapToResponse(savedVehicle);
  }

  @Override
  public List<VehicleResponse> getAllVehicles() {
    return vehicleRepository.findAll()
      .stream()
      .map(this::mapToResponse)
      .toList();
  }

  @Override
  public VehicleResponse getVehicleById(Long id) {
    return vehicleRepository.findById(id)
      .map(this::mapToResponse)
      .orElse(null);
  }

  //  Helper
  private VehicleResponse mapToResponse(Vehicle vehicle) {
    return new VehicleResponse(
      vehicle.getId(),
      vehicle.getPlateNumber(),
      vehicle.getBrand(),
      vehicle.getModel(),
      vehicle.getManufacturingYear()
    );
  }
}
