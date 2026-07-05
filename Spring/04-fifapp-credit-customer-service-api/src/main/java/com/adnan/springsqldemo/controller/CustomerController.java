package com.adnan.springsqldemo.controller;

import com.adnan.springsqldemo.model.Customer;
import com.adnan.springsqldemo.service.CustomerService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/customers")
@RequiredArgsConstructor
public class CustomerController {
  private final CustomerService customerService;

  @GetMapping("/{id}")
  private Customer getById(@PathVariable Long id) {
    return customerService.getById(id);
  }

  @GetMapping
  private List<Customer> getAll() {
    return customerService.getAll();
  }
}
