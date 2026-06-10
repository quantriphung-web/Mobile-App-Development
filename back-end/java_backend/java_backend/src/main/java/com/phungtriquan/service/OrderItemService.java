package com.phungtriquan.service;

import com.phungtriquan.model.OrderItem;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface OrderItemService {
    List<OrderItem> findAll();
    Optional<OrderItem> findById(UUID id);
    OrderItem save(OrderItem orderItem);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
