package com.phungtriquan.service;

import com.phungtriquan.model.Customer;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CustomerService {
    List<Customer> findAll();
    Optional<Customer> findById(UUID id);
    Customer save(Customer customer);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
