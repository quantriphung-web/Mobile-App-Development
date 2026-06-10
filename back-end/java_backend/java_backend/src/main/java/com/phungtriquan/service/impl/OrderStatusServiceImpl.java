package com.phungtriquan.service.impl;

import com.phungtriquan.model.OrderStatus;
import com.phungtriquan.repository.OrderStatusRepository;
import com.phungtriquan.service.OrderStatusService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class OrderStatusServiceImpl implements OrderStatusService {

    private final OrderStatusRepository orderStatusRepository;
    private final AuditDefaultsService auditDefaultsService;

    @Override
    public List<OrderStatus> findAll() {
        return orderStatusRepository.findAll();
    }

    @Override
    public Optional<OrderStatus> findById(UUID id) {
        return orderStatusRepository.findById(id);
    }

    @Override
    public OrderStatus save(OrderStatus orderStatus) {
        Instant now = Instant.now();
        if (orderStatus.getId() == null) {
            if (orderStatus.getCreatedAt() == null) {
                orderStatus.setCreatedAt(now);
            }
            if (orderStatus.getCreatedBy() == null) {
                orderStatus.setCreatedBy(auditDefaultsService.getDefaultStaffAccountId());
            }
            if (orderStatus.getUpdatedBy() == null) {
                orderStatus.setUpdatedBy(auditDefaultsService.getDefaultStaffAccountId());
            }
        }
        orderStatus.setUpdatedAt(now);
        return orderStatusRepository.save(orderStatus);
    }

    @Override
    public boolean existsById(UUID id) {
        return orderStatusRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        orderStatusRepository.deleteById(id);
    }
}
