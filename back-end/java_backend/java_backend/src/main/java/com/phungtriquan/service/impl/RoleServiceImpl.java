package com.phungtriquan.service.impl;

import com.phungtriquan.model.Role;
import com.phungtriquan.repository.RoleRepository;
import com.phungtriquan.service.RoleService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RoleServiceImpl implements RoleService {

    private final RoleRepository roleRepository;

    @Override
    public List<Role> findAll() {
        return roleRepository.findAll();
    }

    @Override
    public Optional<Role> findById(UUID id) {
        return roleRepository.findById(id);
    }

    @Override
    public Role save(Role role) {
        return roleRepository.save(role);
    }

    @Override
    public boolean existsById(UUID id) {
        return roleRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        roleRepository.deleteById(id);
    }
}
