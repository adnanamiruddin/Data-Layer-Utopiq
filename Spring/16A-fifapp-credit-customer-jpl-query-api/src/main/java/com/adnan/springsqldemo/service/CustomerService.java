package com.adnan.springsqldemo.service;

import com.adnan.springsqldemo.entity.Customer;

import java.util.List;

public interface CustomerService {
  List<Customer> findAll();

  Customer findById(Long id);

  Customer findByEmail(String email);

  Customer save(Customer customer);

  void deleteById(Long id);
}
