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

  @GetMapping("/{customerId}")
  public Customer getCustomerById(@PathVariable Long customerId) {
    Customer customer = customerService.findById(customerId);
    if (customer == null) {
      throw new NotFoundException(String.format("Customer not found with id: %s", customerId));
    }
    return customer;
  }

  @GetMapping("/search")
  public Customer searchCustomerByEmail(@RequestParam("email") String searchEmail) {
    Customer customer = customerService.findByEmail(searchEmail);
    if (customer == null) {
      throw new NotFoundException(String.format("Customer not found with email: %s", searchEmail));
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

  @DeleteMapping("/{customerId}")
  public String deleteCustomer(@PathVariable Long customerId) {
    Customer targetCustomer = customerService.findById(customerId);
    if (targetCustomer == null) {
      throw new NotFoundException(String.format("Customer not found with id: %s", customerId));
    }
    customerService.deleteById(customerId);
    return String.format("Deleted customer with id: %s", customerId);
  }
}
