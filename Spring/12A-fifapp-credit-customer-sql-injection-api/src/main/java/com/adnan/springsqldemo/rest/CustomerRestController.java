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

  @GetMapping("/search/before")
  public List<Customer> searchBefore(@RequestParam String fullName) {
    return customerService.findByFullNameBefore(fullName);
  }

  @GetMapping("/search/after")
  public List<Customer> searchAfter(@RequestParam String fullName) {
    return customerService.findByFullNameAfter(fullName);
  }
}
