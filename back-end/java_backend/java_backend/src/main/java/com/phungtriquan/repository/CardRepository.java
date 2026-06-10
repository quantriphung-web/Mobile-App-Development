package com.phungtriquan.repository;

import com.phungtriquan.model.Card;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface CardRepository extends JpaRepository<Card, UUID> {
}
