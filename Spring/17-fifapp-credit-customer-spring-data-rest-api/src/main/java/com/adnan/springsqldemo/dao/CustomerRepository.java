package com.adnan.springsqldemo.dao;

import com.adnan.springsqldemo.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

@RepositoryRestResource(path = "members")
public interface CustomerRepository extends JpaRepository<Customer, Long> {
}
