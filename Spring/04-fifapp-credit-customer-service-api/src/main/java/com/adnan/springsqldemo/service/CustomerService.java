package com.adnan.springsqldemo.service;

import com.adnan.springsqldemo.model.Customer;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class CustomerService {
  private final Map<Long, Customer> customerRepository = new HashMap<>();

  public CustomerService() {
    customerRepository.put(1L, new Customer(1L, "Budi Santoso", "3170101019000001", "081234567890"));
    customerRepository.put(2L, new Customer(2L, "Manusia Dua", "3170101019000002", "081234567891"));
    customerRepository.put(3L, new Customer(3L, "Manusia Tiga", "3170101019000003", "081234567892"));
    customerRepository.put(4L, new Customer(4L, "Manusia Empat", "3170101019000004", "081234567893"));
    customerRepository.put(5L, new Customer(5L, "Manusia Lima", "3170101019000005", "081234567894"));
  }

  public Customer getById(Long id) {
    return  customerRepository.getOrDefault(id, null);
  }

  public List<Customer> getAll() {
    List<Customer> customerList = new ArrayList<>();
    for (Customer customer : customerRepository.values()) {
      customerList.add(customer);
    }
    return customerList;
  }
}
