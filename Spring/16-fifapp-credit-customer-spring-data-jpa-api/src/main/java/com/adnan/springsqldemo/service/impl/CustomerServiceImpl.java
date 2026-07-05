package com.adnan.springsqldemo.service.impl;

import com.adnan.springsqldemo.dao.CustomerRepository;
import com.adnan.springsqldemo.entity.Customer;
import com.adnan.springsqldemo.service.CustomerService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CustomerServiceImpl implements CustomerService {
  private final CustomerRepository customerRepository;

  @Override
  public List<Customer> findAll() {
    return customerRepository.findAll();
  }

  @Override
  public Customer findById(Long id) {
    Optional<Customer> result = customerRepository.findById(id);
    if (result.isPresent()) {
      return result.get();
    }
    return null;
  }

  @Transactional
  @Override
  public Customer save(Customer customer) {
    return customerRepository.save(customer);
  }

  @Transactional
  @Override
  public void deleteById(Long id) {
    customerRepository.deleteById(id);
  }
}
