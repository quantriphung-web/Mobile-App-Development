package com.phungtriquan.controller;

import com.phungtriquan.model.Country;
import com.phungtriquan.service.CountryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/api/countries")
@RequiredArgsConstructor
public class CountryController {

    private final CountryService countryService;

    @GetMapping
    public List<Country> getAll() {
        return countryService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Country> getById(@PathVariable Integer id) {
        return countryService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Country> create(@RequestBody Country country) {
        Country saved = countryService.save(country);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Country> update(@PathVariable Integer id, @RequestBody Country country) {
        if (!countryService.existsById(id)) return ResponseEntity.notFound().build();
        country.setId(id);
        return ResponseEntity.ok(countryService.save(country));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Integer id) {
        if (!countryService.existsById(id)) return ResponseEntity.notFound().build();
        countryService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
