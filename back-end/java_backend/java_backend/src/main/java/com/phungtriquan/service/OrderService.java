package com.phungtriquan.service;

import com.phungtriquan.model.Order;
import java.util.List;
import java.util.Optional;


public interface OrderService {
    List<Order> findAll();
    Optional<Order> findById(String id);
    Order save(Order order);
    boolean existsById(String id);
    void deleteById(String id);
}
