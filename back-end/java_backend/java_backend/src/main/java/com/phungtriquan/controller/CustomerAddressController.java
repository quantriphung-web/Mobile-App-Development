package com.phungtriquan.controller;

import com.phungtriquan.model.CustomerAddress;
import com.phungtriquan.service.CustomerAddressService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/customer-addresss")
@RequiredArgsConstructor
public class CustomerAddressController {

    private final CustomerAddressService customerAddressService;

    @GetMapping
    public List<CustomerAddress> getAll() {
        return customerAddressService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<CustomerAddress> getById(@PathVariable UUID id) {
        return customerAddressService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<CustomerAddress> create(@RequestBody CustomerAddress customerAddress) {
        CustomerAddress saved = customerAddressService.save(customerAddress);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<CustomerAddress> update(@PathVariable UUID id, @RequestBody CustomerAddress customerAddress) {
        if (!customerAddressService.existsById(id)) return ResponseEntity.notFound().build();
        customerAddress.setId(id);
        return ResponseEntity.ok(customerAddressService.save(customerAddress));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!customerAddressService.existsById(id)) return ResponseEntity.notFound().build();
        customerAddressService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
