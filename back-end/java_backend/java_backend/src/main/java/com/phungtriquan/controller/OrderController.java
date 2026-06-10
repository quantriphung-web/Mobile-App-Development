package com.phungtriquan.controller;

import com.phungtriquan.model.Order;
import com.phungtriquan.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @GetMapping
    public List<Order> getAll() {
        return orderService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Order> getById(@PathVariable String id) {
        return orderService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Order> create(@RequestBody Order order) {
        Order saved = orderService.save(order);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Order> update(@PathVariable String id, @RequestBody Order order) {
        if (!orderService.existsById(id)) return ResponseEntity.notFound().build();
        order.setId(id);
        return ResponseEntity.ok(orderService.save(order));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable String id) {
        if (!orderService.existsById(id)) return ResponseEntity.notFound().build();
        orderService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
