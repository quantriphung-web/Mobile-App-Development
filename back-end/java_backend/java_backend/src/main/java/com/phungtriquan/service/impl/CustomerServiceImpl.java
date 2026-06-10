package com.phungtriquan.service.impl;

import com.phungtriquan.model.Customer;
import com.phungtriquan.repository.CustomerRepository;
import com.phungtriquan.service.CustomerService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CustomerServiceImpl implements CustomerService {

    private final CustomerRepository customerRepository;

    @Override
    public List<Customer> findAll() {
        return customerRepository.findAll();
    }

    @Override
    public Optional<Customer> findById(UUID id) {
        return customerRepository.findById(id);
    }

    @Override
    public Customer save(Customer customer) {
        customer.setUpdatedAt(Instant.now());
        return customerRepository.save(customer);
    }

    @Override
    public boolean existsById(UUID id) {
        return customerRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        customerRepository.deleteById(id);
    }
}
