package com.adnan.springsqldemo.dao;

import com.adnan.springsqldemo.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface CustomerRepository extends JpaRepository<Customer, Long> {
  @Query("""
    SELECT customer
    FROM Customer customer
    WHERE customer.email = :email
    """)
  Optional<Customer> findByEmailUsingJpql(@Param("email") String email);
}
