package com.adnan.springsqldemo.repository;

import com.adnan.springsqldemo.dto.CreateCustomerRequest;
import com.adnan.springsqldemo.model.Customer;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Repository
public class CustomerRepository {
  private final List<Customer> customers = new ArrayList<>();
  private Long sequenceId = 6L;

  public CustomerRepository() {
    customers.add(new Customer(1L, "Budi Santoso", "3170101019000001", "081234567890"));
    customers.add(new Customer(2L, "Manusia Dua", "3170101019000002", "081234567891"));
    customers.add(new Customer(3L, "Manusia Tiga", "3170101019000003", "081234567892"));
    customers.add(new Customer(4L, "Manusia Empat", "3170101019000004", "081234567893"));
    customers.add(new Customer(5L, "Manusia Lima", "3170101019000005", "081234567894"));
  }

  public Customer save(CreateCustomerRequest request) {
    Customer newCustomer = new Customer(
      sequenceId,
      request.getFullName(),
      request.getIdentityNumber(),
      request.getPhoneNumber()
    );
    sequenceId++;
    customers.add(newCustomer);
    return newCustomer;
  }

  public List<Customer> findAll() {
    return customers;
  }

  public Optional<Customer> findById(Long id) {
    return customers.stream()
      .filter(customer -> customer.getId().equals(id))
      .findFirst();
  }
}
