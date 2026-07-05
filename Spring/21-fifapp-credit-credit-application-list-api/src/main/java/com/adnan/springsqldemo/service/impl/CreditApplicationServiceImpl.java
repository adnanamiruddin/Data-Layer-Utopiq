package com.adnan.springsqldemo.service.impl;

import com.adnan.springsqldemo.common.NotFoundException;
import com.adnan.springsqldemo.dao.CreditApplicationRepository;
import com.adnan.springsqldemo.dao.CustomerRepository;
import com.adnan.springsqldemo.dao.VehicleRepository;
import com.adnan.springsqldemo.dto.CreateCreditApplicationRequest;
import com.adnan.springsqldemo.dto.CreditApplicationResponse;
import com.adnan.springsqldemo.dto.VehicleResponse;
import com.adnan.springsqldemo.entity.CreditApplication;
import com.adnan.springsqldemo.entity.Customer;
import com.adnan.springsqldemo.entity.Vehicle;
import com.adnan.springsqldemo.service.CreditApplicationService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CreditApplicationServiceImpl implements CreditApplicationService {
  private static final String SUBMITTED_STATUS = "SUBMITTED";
  private final CreditApplicationRepository creditApplicationRepository;
  private final CustomerRepository customerRepository;
  private final VehicleRepository vehicleRepository;

  @Transactional
  @Override
  public CreditApplicationResponse createCreditApplication(CreateCreditApplicationRequest request) {
    Customer customer = customerRepository.findById(request.getCustomerId())
      .orElseThrow(() -> new NotFoundException(String.format("Customer not found with id: %s", request.getCustomerId())));
    Vehicle vehicle = vehicleRepository.findById(request.getVehicleId())
      .orElseThrow(() -> new NotFoundException(String.format("Vehicle not found with id: %s", request.getVehicleId())));

    CreditApplication newCreditApplication = new CreditApplication(
      customer,
      vehicle,
      request.getLoanAmount(),
      request.getTenorMonth(),
      SUBMITTED_STATUS
    );
    CreditApplication savedCreditApplication = creditApplicationRepository.save(newCreditApplication);
    return mapToResponse(savedCreditApplication);
  }

  @Override
  public List<CreditApplicationResponse> getAllCreditApplications() {
    return creditApplicationRepository.findAll()
      .stream()
      .map(this::mapToResponse)
      .toList();
  }

  @Override
  public CreditApplicationResponse getCreditApplicationById(Long id) {
    return creditApplicationRepository.findById(id)
      .map(this::mapToResponse)
      .orElse(null);
  }

  //  Helper
  private CreditApplicationResponse mapToResponse(CreditApplication creditApplication) {
    Customer customer = creditApplication.getCustomer();
    Vehicle vehicle = creditApplication.getVehicle();

    return new CreditApplicationResponse(
      creditApplication.getId(),
      customer.getId(),
      customer.getFullName(),
      vehicle.getId(),
      vehicle.getPlateNumber(),
      creditApplication.getLoanAmount(),
      creditApplication.getTenorMonth(),
      creditApplication.getStatus()
    );
  }
}
