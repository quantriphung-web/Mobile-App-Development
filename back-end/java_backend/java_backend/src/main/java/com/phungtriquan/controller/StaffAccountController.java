package com.phungtriquan.controller;

import com.phungtriquan.model.StaffAccount;
import com.phungtriquan.service.StaffAccountService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/staff-accounts")
@RequiredArgsConstructor
public class StaffAccountController {

    private final StaffAccountService staffAccountService;

    @GetMapping
    public List<StaffAccount> getAll() {
        return staffAccountService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<StaffAccount> getById(@PathVariable UUID id) {
        return staffAccountService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<StaffAccount> create(@RequestBody StaffAccount staffAccount) {
        StaffAccount saved = staffAccountService.save(staffAccount);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<StaffAccount> update(@PathVariable UUID id, @RequestBody StaffAccount staffAccount) {
        if (!staffAccountService.existsById(id)) return ResponseEntity.notFound().build();
        staffAccount.setId(id);
        return ResponseEntity.ok(staffAccountService.save(staffAccount));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!staffAccountService.existsById(id)) return ResponseEntity.notFound().build();
        staffAccountService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
