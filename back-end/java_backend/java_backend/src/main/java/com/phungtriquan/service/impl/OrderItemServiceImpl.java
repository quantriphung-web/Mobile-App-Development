package com.phungtriquan.service.impl;

import com.phungtriquan.model.OrderItem;
import com.phungtriquan.repository.OrderItemRepository;
import com.phungtriquan.service.OrderItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class OrderItemServiceImpl implements OrderItemService {

    private final OrderItemRepository orderItemRepository;

    @Override
    public List<OrderItem> findAll() {
        return orderItemRepository.findAll();
    }

    @Override
    public Optional<OrderItem> findById(UUID id) {
        return orderItemRepository.findById(id);
    }

    @Override
    public OrderItem save(OrderItem orderItem) {
        return orderItemRepository.save(orderItem);
    }

    @Override
    public boolean existsById(UUID id) {
        return orderItemRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        orderItemRepository.deleteById(id);
    }
}
