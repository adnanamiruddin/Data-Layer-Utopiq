package com.adnan.springsqldemo.service;

import com.adnan.springsqldemo.dto.CreateCustomerRequest;
import com.adnan.springsqldemo.dto.CustomerResponse;
import com.adnan.springsqldemo.exception.BadRequestException;
import com.adnan.springsqldemo.exception.NotFoundException;
import com.adnan.springsqldemo.model.Customer;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class CustomerService {
  private final Map<Long, Customer> customerRepository = new HashMap<>();
  private Long sequenceId = 6L;

  public CustomerService() {
    customerRepository.put(1L, new Customer(1L, "Budi Santoso", "3170101019000001", "081234567890"));
    customerRepository.put(2L, new Customer(2L, "Manusia Dua", "3170101019000002", "081234567891"));
    customerRepository.put(3L, new Customer(3L, "Manusia Tiga", "3170101019000003", "081234567892"));
    customerRepository.put(4L, new Customer(4L, "Manusia Empat", "3170101019000004", "081234567893"));
    customerRepository.put(5L, new Customer(5L, "Manusia Lima", "3170101019000005", "081234567894"));
  }

  public CustomerResponse create(CreateCustomerRequest request) {
    for (Customer customer : customerRepository.values()) {
      if (customer.getIdentityNumber().equals(request.getIdentityNumber())) {
        throw new BadRequestException("Identity number already used");
      }
    }

    Customer newCustomer = new Customer(
      sequenceId,
      request.getFullName(),
      request.getIdentityNumber(),
      request.getPhoneNumber()
    );
    customerRepository.put(sequenceId++, newCustomer);
    return mapToResponse(newCustomer);
  }

  public List<CustomerResponse> getAll() {
    List<CustomerResponse> customerList = new ArrayList<>();
    for (Customer customer : customerRepository.values()) {
      customerList.add(mapToResponse(customer));
    }
    return customerList;
  }

  public CustomerResponse getById(Long id) {
    Customer customer = customerRepository.get(id);
    if (customer == null) {
      throw new NotFoundException("Customer not found with id: " + id);
    }
    return mapToResponse(customer);
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
