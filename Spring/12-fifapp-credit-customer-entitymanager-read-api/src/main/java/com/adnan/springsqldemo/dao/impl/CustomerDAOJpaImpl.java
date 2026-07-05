package com.adnan.springsqldemo.dao.impl;

import com.adnan.springsqldemo.dao.CustomerDAO;
import com.adnan.springsqldemo.entity.Customer;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class CustomerDAOJpaImpl implements CustomerDAO {
  private final EntityManager entityManager;

  @Override
  public List<Customer> findAll() {
    TypedQuery<Customer> query = entityManager.createQuery("from Customer", Customer.class);
    return query.getResultList();
  }

  @Override
  public Customer findById(Long id) {
    return entityManager.find(Customer.class, id);
  }
}
