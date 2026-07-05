package com.adnan.springsqldemo.controller;

import com.adnan.springsqldemo.dto.CreateCustomerRequest;
import com.adnan.springsqldemo.dto.CustomerResponse;
import com.adnan.springsqldemo.dto.api.ApiResponse;
import com.adnan.springsqldemo.model.Customer;
import com.adnan.springsqldemo.service.CustomerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/customers")
@RequiredArgsConstructor
public class CustomerController {
  private final CustomerService customerService;

  @PostMapping
  public ResponseEntity<ApiResponse<CustomerResponse>> create(@RequestBody @Valid CreateCustomerRequest request) {
    CustomerResponse response = customerService.create(request);
    return ResponseEntity
      .status(HttpStatus.CREATED)
      .body(ApiResponse.success(
        "Customer created successfully",
        response));
  }

  @GetMapping
  public ResponseEntity<ApiResponse<List<CustomerResponse>>> getAll() {
    return ResponseEntity.ok(
      ApiResponse.success(
        "Customers retrieved successfully",
        customerService.getAll()
      )
    );
  }

  @GetMapping("/{id}")
  public ResponseEntity<ApiResponse<CustomerResponse>> getById(@PathVariable Long id) {
    return ResponseEntity.ok(
      ApiResponse.success(
        "Customers retrieved successfully",
        customerService.getById(id)
      )
    );
  }
}
