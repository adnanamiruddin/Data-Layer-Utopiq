package com.adnan.springsqldemo.controller;

import com.adnan.springsqldemo.model.Customer;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/customers")
public class CustomerController {
  @GetMapping("/{id}")
  private Customer getById(@PathVariable Long id) {
    return new Customer(id, "Budi Santoso", "3170101019000001", "081234567890");
  }
}
