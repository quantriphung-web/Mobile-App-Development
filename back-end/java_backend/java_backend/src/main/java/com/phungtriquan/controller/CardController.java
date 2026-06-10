package com.phungtriquan.controller;

import com.phungtriquan.model.Card;
import com.phungtriquan.service.CardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/cards")
@RequiredArgsConstructor
public class CardController {

    private final CardService cardService;

    @GetMapping
    public List<Card> getAll() {
        return cardService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Card> getById(@PathVariable UUID id) {
        return cardService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Card> create(@RequestBody Card card) {
        Card saved = cardService.save(card);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Card> update(@PathVariable UUID id, @RequestBody Card card) {
        if (!cardService.existsById(id)) return ResponseEntity.notFound().build();
        card.setId(id);
        return ResponseEntity.ok(cardService.save(card));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!cardService.existsById(id)) return ResponseEntity.notFound().build();
        cardService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
