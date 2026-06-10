package com.phungtriquan.repository;

import com.phungtriquan.model.CardItem;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface CardItemRepository extends JpaRepository<CardItem, UUID> {
}
