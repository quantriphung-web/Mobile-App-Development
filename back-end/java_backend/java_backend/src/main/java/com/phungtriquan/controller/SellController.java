package com.phungtriquan.controller;

import com.phungtriquan.model.Sell;
import com.phungtriquan.service.SellService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/api/sells")
@RequiredArgsConstructor
public class SellController {

    private final SellService sellService;

    @GetMapping
    public List<Sell> getAll() {
        return sellService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Sell> getById(@PathVariable Long id) {
        return sellService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Sell> create(@RequestBody Sell sell) {
        Sell saved = sellService.save(sell);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Sell> update(@PathVariable Long id, @RequestBody Sell sell) {
        if (!sellService.existsById(id)) return ResponseEntity.notFound().build();
        sell.setId(id);
        return ResponseEntity.ok(sellService.save(sell));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (!sellService.existsById(id)) return ResponseEntity.notFound().build();
        sellService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
