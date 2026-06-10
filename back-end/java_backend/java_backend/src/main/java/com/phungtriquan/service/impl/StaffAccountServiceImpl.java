package com.phungtriquan.service.impl;

import com.phungtriquan.model.StaffAccount;
import com.phungtriquan.repository.StaffAccountRepository;
import com.phungtriquan.service.StaffAccountService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class StaffAccountServiceImpl implements StaffAccountService {

    private final StaffAccountRepository staffAccountRepository;
    private final AuditDefaultsService auditDefaultsService;

    @Override
    public List<StaffAccount> findAll() {
        return staffAccountRepository.findAll();
    }

    @Override
    public Optional<StaffAccount> findById(UUID id) {
        return staffAccountRepository.findById(id);
    }

    @Override
    public StaffAccount save(StaffAccount staffAccount) {
        LocalDateTime now = LocalDateTime.now();
        if (staffAccount.getId() == null) {
            if (staffAccount.getCreatedAt() == null) {
                staffAccount.setCreatedAt(now);
            }
            if (staffAccount.getCreatedBy() == null) {
                staffAccount.setCreatedBy(staffAccountRepository.findById(auditDefaultsService.getDefaultStaffAccountId()).orElse(null));
            }
            if (staffAccount.getUpdatedBy() == null) {
                staffAccount.setUpdatedBy(staffAccountRepository.findById(auditDefaultsService.getDefaultStaffAccountId()).orElse(null));
            }
        }
        staffAccount.setUpdatedAt(now);
        return staffAccountRepository.save(staffAccount);
    }

    @Override
    public boolean existsById(UUID id) {
        return staffAccountRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        staffAccountRepository.deleteById(id);
    }
}
