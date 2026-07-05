package com.adnan.springsqldemo.dao;

import com.adnan.springsqldemo.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CustomerRepository extends JpaRepository<Customer, Long> {
}
