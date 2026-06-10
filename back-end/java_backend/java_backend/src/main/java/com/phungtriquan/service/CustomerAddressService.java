package com.phungtriquan.service;

import com.phungtriquan.model.CustomerAddress;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CustomerAddressService {
    List<CustomerAddress> findAll();
    Optional<CustomerAddress> findById(UUID id);
    CustomerAddress save(CustomerAddress customerAddress);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
