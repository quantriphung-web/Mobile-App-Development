package com.phungtriquan.controller;

import com.phungtriquan.model.OrderStatus;
import com.phungtriquan.service.OrderStatusService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/order-statuss")
@RequiredArgsConstructor
public class OrderStatusController {

    private final OrderStatusService orderStatusService;

    @GetMapping
    public List<OrderStatus> getAll() {
        return orderStatusService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<OrderStatus> getById(@PathVariable UUID id) {
        return orderStatusService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<OrderStatus> create(@RequestBody OrderStatus orderStatus) {
        OrderStatus saved = orderStatusService.save(orderStatus);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<OrderStatus> update(@PathVariable UUID id, @RequestBody OrderStatus orderStatus) {
        if (!orderStatusService.existsById(id)) return ResponseEntity.notFound().build();
        orderStatus.setId(id);
        return ResponseEntity.ok(orderStatusService.save(orderStatus));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!orderStatusService.existsById(id)) return ResponseEntity.notFound().build();
        orderStatusService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
