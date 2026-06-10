package com.phungtriquan.controller;

import com.phungtriquan.model.OrderItem;
import com.phungtriquan.service.OrderItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/order-items")
@RequiredArgsConstructor
public class OrderItemController {

    private final OrderItemService orderItemService;

    @GetMapping
    public List<OrderItem> getAll() {
        return orderItemService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<OrderItem> getById(@PathVariable UUID id) {
        return orderItemService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<OrderItem> create(@RequestBody OrderItem orderItem) {
        OrderItem saved = orderItemService.save(orderItem);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<OrderItem> update(@PathVariable UUID id, @RequestBody OrderItem orderItem) {
        if (!orderItemService.existsById(id)) return ResponseEntity.notFound().build();
        orderItem.setId(id);
        return ResponseEntity.ok(orderItemService.save(orderItem));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!orderItemService.existsById(id)) return ResponseEntity.notFound().build();
        orderItemService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
