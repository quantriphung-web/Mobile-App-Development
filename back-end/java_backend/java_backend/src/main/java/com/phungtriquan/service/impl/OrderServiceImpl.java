package com.phungtriquan.service.impl;

import com.phungtriquan.model.Order;
import com.phungtriquan.repository.OrderRepository;
import com.phungtriquan.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;


@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;

    @Override
    public List<Order> findAll() {
        return orderRepository.findAll();
    }

    @Override
    public Optional<Order> findById(String id) {
        return orderRepository.findById(id);
    }

    @Override
    public Order save(Order order) {
        Instant now = Instant.now();
        if (order.getCreatedAt() == null) {
            order.setCreatedAt(now);
        }
        order.setUpdatedAt(now);
        return orderRepository.save(order);
    }

    @Override
    public boolean existsById(String id) {
        return orderRepository.existsById(id);
    }

    @Override
    public void deleteById(String id) {
        orderRepository.deleteById(id);
    }
}
