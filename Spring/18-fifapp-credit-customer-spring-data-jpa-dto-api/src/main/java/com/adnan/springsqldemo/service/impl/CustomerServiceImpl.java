package com.adnan.springsqldemo.service.impl;

import com.adnan.springsqldemo.dao.CustomerRepository;
import com.adnan.springsqldemo.dto.CreateCustomerRequest;
import com.adnan.springsqldemo.dto.CustomerResponse;
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

  @Transactional
  @Override
  public CustomerResponse createCustomer(CreateCustomerRequest request) {
    Customer customer = new Customer(
      request.getFullName(),
      request.getPhoneNumber(),
      request.getEmail()
    );
    Customer savedCustomer = customerRepository.save(customer);
    return mapToResponse(savedCustomer);
  }

  @Override
  public List<CustomerResponse> getAllCustomers() {
    return customerRepository.findAll()
      .stream()
      .map(this::mapToResponse)
      .toList();
  }

  @Override
  public CustomerResponse getCustomerById(Long id) {
    return customerRepository.findById(id)
      .map(this::mapToResponse)
      .orElse(null);
  }

  //  Helper
  private CustomerResponse mapToResponse(Customer customer) {
    return new CustomerResponse(
      customer.getId(),
      customer.getFullName(),
      customer.getPhoneNumber(),
      customer.getEmail()
    );
  }
}
