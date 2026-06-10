package com.phungtriquan.service;

import com.phungtriquan.model.StaffAccount;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface StaffAccountService {
    List<StaffAccount> findAll();
    Optional<StaffAccount> findById(UUID id);
    StaffAccount save(StaffAccount staffAccount);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
