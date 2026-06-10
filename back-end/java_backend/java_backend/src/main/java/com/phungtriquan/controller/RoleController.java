package com.phungtriquan.controller;

import com.phungtriquan.model.Role;
import com.phungtriquan.service.RoleService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/roles")
@RequiredArgsConstructor
public class RoleController {

    private final RoleService roleService;

    @GetMapping
    public List<Role> getAll() {
        return roleService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Role> getById(@PathVariable UUID id) {
        return roleService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Role> create(@RequestBody Role role) {
        Role saved = roleService.save(role);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Role> update(@PathVariable UUID id, @RequestBody Role role) {
        if (!roleService.existsById(id)) return ResponseEntity.notFound().build();
        role.setId(id);
        return ResponseEntity.ok(roleService.save(role));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!roleService.existsById(id)) return ResponseEntity.notFound().build();
        roleService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
