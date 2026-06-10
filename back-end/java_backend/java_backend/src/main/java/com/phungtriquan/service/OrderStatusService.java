package com.phungtriquan.service;

import com.phungtriquan.model.OrderStatus;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface OrderStatusService {
    List<OrderStatus> findAll();
    Optional<OrderStatus> findById(UUID id);
    OrderStatus save(OrderStatus orderStatus);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
