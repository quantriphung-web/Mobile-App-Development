package com.phungtriquan.service.impl;

import com.phungtriquan.model.Card;
import com.phungtriquan.repository.CardRepository;
import com.phungtriquan.service.CardService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CardServiceImpl implements CardService {

    private final CardRepository cardRepository;

    @Override
    public List<Card> findAll() {
        return cardRepository.findAll();
    }

    @Override
    public Optional<Card> findById(UUID id) {
        return cardRepository.findById(id);
    }

    @Override
    public Card save(Card card) {
        return cardRepository.save(card);
    }

    @Override
    public boolean existsById(UUID id) {
        return cardRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        cardRepository.deleteById(id);
    }
}
