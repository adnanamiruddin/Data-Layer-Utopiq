package com.adnan.springsqldemo.service;

import com.adnan.springsqldemo.dto.CreateCustomerRequest;
import com.adnan.springsqldemo.dto.CustomerResponse;
import com.adnan.springsqldemo.entity.Customer;

import java.util.List;

public interface CustomerService {
  CustomerResponse createCustomer(CreateCustomerRequest request);

  List<CustomerResponse> getAllCustomers();

  CustomerResponse getCustomerById(Long id);
}
