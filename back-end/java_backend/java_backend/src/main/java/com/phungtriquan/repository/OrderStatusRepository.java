package com.phungtriquan.repository;

import com.phungtriquan.model.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface OrderStatusRepository extends JpaRepository<OrderStatus, UUID> {
}
