package com.phungtriquan.repository;

import com.phungtriquan.model.StaffAccount;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface StaffAccountRepository extends JpaRepository<StaffAccount, UUID> {
    Optional<StaffAccount> findByEmail(String email);
    Boolean existsByEmail(String email);
    Optional<StaffAccount> findFirstByOrderByCreatedAtAsc();
}
