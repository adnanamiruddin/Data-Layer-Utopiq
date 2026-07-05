package com.adnan.springsqldemo.service;

import com.adnan.springsqldemo.dto.CreateCustomerRequest;
import com.adnan.springsqldemo.dto.CustomerResponse;
import com.adnan.springsqldemo.exception.BadRequestException;
import com.adnan.springsqldemo.exception.NotFoundException;
import com.adnan.springsqldemo.model.Customer;
import com.adnan.springsqldemo.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@RequiredArgsConstructor
public class CustomerService {
  private final CustomerRepository customerRepository;

  public CustomerResponse create(CreateCustomerRequest request) {
    for (Customer customer : customerRepository.findAll()) {
      if (customer.getIdentityNumber().equals(request.getIdentityNumber())) {
        throw new BadRequestException("Identity number already used");
      }
    }
    Customer newCustomer = customerRepository.save(request);
    return mapToResponse(newCustomer);
  }

  public List<CustomerResponse> getAll() {
    List<CustomerResponse> customerList = new ArrayList<>();
    for (Customer customer : customerRepository.findAll()) {
      customerList.add(mapToResponse(customer));
    }
    return customerList;
  }

  public CustomerResponse getById(Long id) {
    Optional<Customer> customer = customerRepository.findById(id);
    if (customer.isEmpty()) {
      throw new NotFoundException("Customer not found with id: " + id);
    }
    return mapToResponse(customer.get());
  }

  // Helper
  private CustomerResponse mapToResponse(Customer customer) {
    return CustomerResponse.builder()
      .id(customer.getId())
      .fullName(customer.getFullName())
      .identityNumber(customer.getIdentityNumber())
      .phoneNumber(customer.getPhoneNumber())
      .build();
  }
}
