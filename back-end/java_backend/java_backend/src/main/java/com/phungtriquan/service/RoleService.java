package com.phungtriquan.service;

import com.phungtriquan.model.Role;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface RoleService {
    List<Role> findAll();
    Optional<Role> findById(UUID id);
    Role save(Role role);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
