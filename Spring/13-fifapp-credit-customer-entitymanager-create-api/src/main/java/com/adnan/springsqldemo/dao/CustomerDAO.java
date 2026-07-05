package com.adnan.springsqldemo.dao;

import com.adnan.springsqldemo.entity.Customer;

import java.util.List;

public interface CustomerDAO {
  List<Customer> findAll();

  Customer findById(Long id);

  Customer save(Customer customer);
}
