package com.adnan.springsqldemo.service.impl;

import com.adnan.springsqldemo.dao.CustomerDAO;
import com.adnan.springsqldemo.entity.Customer;
import com.adnan.springsqldemo.service.CustomerService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CustomerServiceImpl implements CustomerService {
  private final CustomerDAO customerDAO;

  @Override
  public List<Customer> findAll() {
    return customerDAO.findAll();
  }

  @Override
  public Customer findById(Long id) {
    return customerDAO.findById(id);
  }

  @Override
  public List<Customer> findByFullNameBefore(String fullName) {
    return customerDAO.findByFullNameBefore(fullName);
  }

  @Override
  public List<Customer> findByFullNameAfter(String fullName) {
    return customerDAO.findByFullNameAfter(fullName);
  }
}
