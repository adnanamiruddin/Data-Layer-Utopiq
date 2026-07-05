package com.adnan.springsqldemo.controller;

import com.adnan.springsqldemo.dto.CreateCustomerRequest;
import com.adnan.springsqldemo.model.Customer;
import com.adnan.springsqldemo.service.CustomerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/customers")
@RequiredArgsConstructor
public class CustomerController {
  private final CustomerService customerService;

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  public Customer create(@RequestBody CreateCustomerRequest request) {
    return customerService.create(request);
  }

  @GetMapping
  public List<Customer> getAll() {
    return customerService.getAll();
  }

  @GetMapping("/{id}")
  public Customer getById(@PathVariable Long id) {
    return customerService.getById(id);
  }
}
