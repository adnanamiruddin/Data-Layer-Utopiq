package com.adnan.springsqldemo.service.impl;

import com.adnan.springsqldemo.dao.CustomerDAO;
import com.adnan.springsqldemo.entity.Customer;
import com.adnan.springsqldemo.service.CustomerService;
import jakarta.transaction.Transactional;
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

  @Transactional
  @Override
  public Customer save(Customer customer) {
    return customerDAO.save(customer);
  }

  @Transactional
  @Override
  public void deleteById(Long id) {
    customerDAO.deleteById(id);
  }
}
