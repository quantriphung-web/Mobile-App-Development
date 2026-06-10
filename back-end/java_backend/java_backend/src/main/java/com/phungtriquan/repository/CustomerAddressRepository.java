package com.phungtriquan.repository;

import com.phungtriquan.model.CustomerAddress;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface CustomerAddressRepository extends JpaRepository<CustomerAddress, UUID> {
}
