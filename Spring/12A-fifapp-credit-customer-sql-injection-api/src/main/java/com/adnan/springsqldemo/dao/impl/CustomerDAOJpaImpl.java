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

  /**
   * Intentionally unsafe: used only to demonstrate SQL injection in a local lab.
   * Never construct SQL by concatenating data received from a request.
   */
  @Override
  @SuppressWarnings("unchecked")
  public List<Customer> findByFullNameBefore(String fullName) {
    String sql = "SELECT * FROM customers WHERE full_name = '" + fullName + "'";
    return entityManager.createNativeQuery(sql, Customer.class).getResultList();
  }

  /**
   * Safe version: the value is bound as data, so it cannot alter the SQL syntax.
   */
  @Override
  @SuppressWarnings("unchecked")
  public List<Customer> findByFullNameAfter(String fullName) {
    String sql = "SELECT * FROM customers WHERE full_name = :fullName";
    return entityManager.createNativeQuery(sql, Customer.class)
      .setParameter("fullName", fullName)
      .getResultList();
  }
}
