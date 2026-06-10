package com.phungtriquan.service.impl;

import com.phungtriquan.repository.StaffAccountRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuditDefaultsService {

    private final StaffAccountRepository staffAccountRepository;

    public UUID getDefaultStaffAccountId() {
        return staffAccountRepository.findFirstByOrderByCreatedAtAsc()
                .map(staffAccount -> staffAccount.getId())
                .orElse(null);
    }
}
