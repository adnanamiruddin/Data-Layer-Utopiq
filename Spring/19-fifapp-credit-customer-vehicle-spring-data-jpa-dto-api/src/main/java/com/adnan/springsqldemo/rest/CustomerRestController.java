package com.adnan.springsqldemo.rest;

import com.adnan.springsqldemo.common.NotFoundException;
import com.adnan.springsqldemo.dto.CreateCustomerRequest;
import com.adnan.springsqldemo.dto.CustomerResponse;
import com.adnan.springsqldemo.service.CustomerService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/customers")
@RequiredArgsConstructor
public class CustomerRestController {
  private final CustomerService customerService;

  @PostMapping
  public CustomerResponse createCustomer(@RequestBody CreateCustomerRequest request) {
    return customerService.createCustomer(request);
  }

  @GetMapping
  public List<CustomerResponse> getAllCustomers() {
    return customerService.getAllCustomers();
  }

  @GetMapping("/{customerId}")
  public CustomerResponse getCustomerById(@PathVariable Long customerId) {
    CustomerResponse customer = customerService.getCustomerById(customerId);
    if (customer == null) {
      throw new NotFoundException(String.format("Customer not found with id: %s", customerId));
    }
    return customer;
  }
}
