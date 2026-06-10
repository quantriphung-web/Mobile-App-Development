package com.phungtriquan.service.impl;

import com.phungtriquan.model.CardItem;
import com.phungtriquan.repository.CardItemRepository;
import com.phungtriquan.service.CardItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CardItemServiceImpl implements CardItemService {

    private final CardItemRepository cardItemRepository;

    @Override
    public List<CardItem> findAll() {
        return cardItemRepository.findAll();
    }

    @Override
    public Optional<CardItem> findById(UUID id) {
        return cardItemRepository.findById(id);
    }

    @Override
    public CardItem save(CardItem cardItem) {
        return cardItemRepository.save(cardItem);
    }

    @Override
    public boolean existsById(UUID id) {
        return cardItemRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        cardItemRepository.deleteById(id);
    }
}
