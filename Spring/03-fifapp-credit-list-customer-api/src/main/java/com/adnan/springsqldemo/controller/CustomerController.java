package com.adnan.springsqldemo.controller;

import com.adnan.springsqldemo.model.Customer;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/customers")
public class CustomerController {
  @GetMapping("/{id}")
  private Customer getById(@PathVariable Long id) {
    return new Customer(id, "Budi Santoso", "3170101019000001", "081234567890");
  }

  @GetMapping
  private List<Customer> getAll() {
    List<Customer> customerList = new ArrayList<>();

    customerList.add(new Customer(1L, "Budi Santoso", "3170101019000001", "081234567890"));
    customerList.add(new Customer(2L, "Manusia Dua", "3170101019000002", "081234567891"));
    customerList.add(new Customer(3L, "Manusia Tiga", "3170101019000003", "081234567892"));
    customerList.add(new Customer(4L, "Manusia Empat", "3170101019000004", "081234567893"));
    customerList.add(new Customer(5L, "Manusia Lima", "3170101019000005", "081234567894"));

    return customerList;
  }
}
