package com.phungtriquan.repository;

import com.phungtriquan.model.RefreshToken;
import com.phungtriquan.model.StaffAccount;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, java.util.UUID> {
    Optional<RefreshToken> findByToken(String token);
    Optional<RefreshToken> findByUser(StaffAccount user);

    @Modifying
    @Transactional
    int deleteByUser(StaffAccount user);
}
