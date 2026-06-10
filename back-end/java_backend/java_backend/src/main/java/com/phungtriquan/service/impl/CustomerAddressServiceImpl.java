package com.phungtriquan.service.impl;

import com.phungtriquan.model.CustomerAddress;
import com.phungtriquan.repository.CustomerAddressRepository;
import com.phungtriquan.service.CustomerAddressService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CustomerAddressServiceImpl implements CustomerAddressService {

    private final CustomerAddressRepository customerAddressRepository;

    @Override
    public List<CustomerAddress> findAll() {
        return customerAddressRepository.findAll();
    }

    @Override
    public Optional<CustomerAddress> findById(UUID id) {
        return customerAddressRepository.findById(id);
    }

    @Override
    public CustomerAddress save(CustomerAddress customerAddress) {
        return customerAddressRepository.save(customerAddress);
    }

    @Override
    public boolean existsById(UUID id) {
        return customerAddressRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        customerAddressRepository.deleteById(id);
    }
}
