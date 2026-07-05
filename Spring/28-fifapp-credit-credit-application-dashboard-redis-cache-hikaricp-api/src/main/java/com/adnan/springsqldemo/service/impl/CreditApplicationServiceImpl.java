package com.adnan.springsqldemo.service.impl;

import com.adnan.springsqldemo.common.NotFoundException;
import com.adnan.springsqldemo.dao.CreditApplicationRepository;
import com.adnan.springsqldemo.dao.CustomerRepository;
import com.adnan.springsqldemo.dao.VehicleRepository;
import com.adnan.springsqldemo.dto.*;
import com.adnan.springsqldemo.entity.CreditApplication;
import com.adnan.springsqldemo.entity.Customer;
import com.adnan.springsqldemo.entity.Vehicle;
import com.adnan.springsqldemo.service.CreditApplicationService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.time.Duration;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CreditApplicationServiceImpl implements CreditApplicationService {
  private final CreditApplicationRepository creditApplicationRepository;
  private final CustomerRepository customerRepository;
  private final VehicleRepository vehicleRepository;
  private final DashboardCacheService dashboardCacheService;

  private static final String SUBMITTED_STATUS = "SUBMITTED";
  private static final Long DEFAULT_BRANCH_ID = 10L;
  private static final Logger log = LoggerFactory.getLogger(CreditApplicationServiceImpl.class);

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
      getBranchIdOrDefault(request.getBranchId()),
      request.getLoanAmount(),
      request.getTenorMonth(),
      SUBMITTED_STATUS
    );
    CreditApplication savedCreditApplication = creditApplicationRepository.save(newCreditApplication);
    return mapToResponse(savedCreditApplication);
  }

  @Override
  public List<CreditApplicationResponse> getAllCreditApplications(String status) {
    List<CreditApplication> creditApplications;
    if (status == null || status.isBlank()) {
      creditApplications = creditApplicationRepository.findAllWithCustomerAndVehicle();
    } else {
      creditApplications = creditApplicationRepository.findByStatusWithCustomerAndVehicle(status);
    }
    return creditApplications
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

  @Override
  public CreditApplicationSummaryResponse getCreditApplicationSummary(Long id) {
    return creditApplicationRepository.findById(id)
      .map(this::toSummaryResponse)
      .orElse(null);
  }

  @Override
  public CreditApplicationDashboardResponse getDashboard(Long branchId) {
    long startTime = System.nanoTime();

    CreditApplicationDashboardResponse cachedDashboard = dashboardCacheService.get(branchId);
    if (cachedDashboard != null) {
      log.info("[DASHBOARD SERVICE] branchId={} source=redis elapsedMs={}",
        branchId,
        elapsedMs(startTime));
      return cachedDashboard;
    }

    CreditApplicationDashboardResponse dashboard = loadDashboardFromDatabase(branchId);
    dashboardCacheService.put(branchId, dashboard);
    log.info("[DASHBOARD SERVICE] branchId={} source=database elapsedMs={}",
      branchId,
      elapsedMs(startTime));

    return dashboard;
  }

  private CreditApplicationDashboardResponse loadDashboardFromDatabase(Long branchId) {
    long startTime = System.nanoTime();
    Object[] summary = unwrapSingleRow(creditApplicationRepository.calculateDashboardSummary(branchId));

    CreditApplicationDashboardResponse dashboard = new CreditApplicationDashboardResponse(
      branchId,
      toLong(summary[0]),
      toBigDecimal(summary[1]),
      toBigDecimal(summary[2]),
      toBigDecimal(summary[3]),
      toBigDecimal(summary[4]),
      toDashboardGroups(creditApplicationRepository.calculateDashboardByStatus(branchId)),
      toDashboardGroups(creditApplicationRepository.calculateDashboardByTenorMonth(branchId)),
      toDashboardGroups(creditApplicationRepository.calculateDashboardByVehicleBrand(branchId))
    );

    log.info("[DATABASE QUERY] dashboard aggregation branchId={} queryCount=4 elapsedMs={}",
      branchId,
      elapsedMs(startTime));
    return dashboard;
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
      creditApplication.getBranchId(),
      creditApplication.getLoanAmount(),
      creditApplication.getTenorMonth(),
      creditApplication.getStatus()
    );
  }

  private CreditApplicationSummaryResponse toSummaryResponse(CreditApplication creditApplication) {
    Customer customer = creditApplication.getCustomer();
    Vehicle vehicle = creditApplication.getVehicle();
    String vehicleName = vehicle.getBrand() + " " + vehicle.getModel();

    return new CreditApplicationSummaryResponse(
      creditApplication.getId(),
      creditApplication.getStatus(),
      customer.getFullName(),
      customer.getPhoneNumber(),
      vehicleName,
      vehicle.getPlateNumber(),
      creditApplication.getLoanAmount(),
      creditApplication.getTenorMonth()
    );
  }

  //  Helper for Dashboard
  private Long getBranchIdOrDefault(Long branchId) {
    if (branchId == null) {
      return DEFAULT_BRANCH_ID;
    }
    return branchId;
  }

  private List<DashboardGroupResponse> toDashboardGroups(List<Object[]> rows) {
    return rows.stream()
      .map(row -> new DashboardGroupResponse(
        String.valueOf(row[0]),
        toLong(row[1]),
        toBigDecimal(row[2])
      ))
      .toList();
  }

  private Object[] unwrapSingleRow(Object result) {
    if (result instanceof Object[] row && row.length == 1 && row[0] instanceof Object[] nestedRow) {
      return nestedRow;
    }
    return (Object[]) result;
  }

  private Long toLong(Object value) {
    if (value instanceof BigInteger bigInteger) {
      return bigInteger.longValue();
    }
    if (value instanceof Number number) {
      return number.longValue();
    }
    return Long.valueOf(String.valueOf(value));
  }

  private BigDecimal toBigDecimal(Object value) {
    if (value instanceof BigDecimal bigDecimal) {
      return bigDecimal;
    }
    if (value instanceof BigInteger bigInteger) {
      return new BigDecimal(bigInteger);
    }
    if (value instanceof Number number) {
      return BigDecimal.valueOf(number.doubleValue());
    }
    return new BigDecimal(String.valueOf(value));
  }

  private long elapsedMs(long startTime) {
    return Duration.ofNanos(System.nanoTime() - startTime).toMillis();
  }
}
