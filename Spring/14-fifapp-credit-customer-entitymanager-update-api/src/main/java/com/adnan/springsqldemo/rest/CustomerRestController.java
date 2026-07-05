package com.adnan.springsqldemo.rest;

import com.adnan.springsqldemo.common.NotFoundException;
import com.adnan.springsqldemo.entity.Customer;
import com.adnan.springsqldemo.service.CustomerService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/customers")
@RequiredArgsConstructor
public class CustomerRestController {
  private final CustomerService customerService;

  @GetMapping
  public List<Customer> getAllCustomer() {
    return customerService.findAll();
  }

  @GetMapping("/{id}")
  public Customer getCustomerById(@PathVariable Long id) {
    Customer customer = customerService.findById(id);
    if (customer == null) {
      throw new NotFoundException(String.format("Customer not found with id: %s", id));
    }
    return customer;
  }

  @PostMapping
  public Customer createCustomer(@RequestBody Customer customerRequest) {
    customerRequest.setId(null);
    return customerService.save(customerRequest);
  }

  @PutMapping
  public Customer updateCustomer(@RequestBody Customer customerRequest) {
    Customer existingCustomer = customerService.findById(customerRequest.getId());
    if (existingCustomer == null) {
      throw new NotFoundException(String.format("Customer not found with id: %s", customerRequest.getId()));
    }
    return customerService.save(customerRequest);
  }
}
