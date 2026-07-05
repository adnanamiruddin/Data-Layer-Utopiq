package com.adnan.springsqldemo.rest;

import com.adnan.springsqldemo.common.NotFoundException;
import com.adnan.springsqldemo.dto.CreateVehicleRequest;
import com.adnan.springsqldemo.dto.VehicleResponse;
import com.adnan.springsqldemo.service.VehicleService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/vehicles")
@RequiredArgsConstructor
public class VehicleRestController {
  private final VehicleService vehicleService;

  @PostMapping
  public VehicleResponse createVehicle(@RequestBody CreateVehicleRequest request) {
    return vehicleService.createVehicle(request);
  }

  @GetMapping
  public List<VehicleResponse> getAllVehicles() {
    return vehicleService.getAllVehicles();
  }

  @GetMapping("/{vehicleId}")
  public VehicleResponse getVehicleById(@PathVariable Long vehicleId) {
    VehicleResponse vehicle = vehicleService.getVehicleById(vehicleId);
    if (vehicle == null) {
      throw new NotFoundException(String.format("Vehicle not found with id: %s", vehicleId));
    }
    return vehicle;
  }
}
