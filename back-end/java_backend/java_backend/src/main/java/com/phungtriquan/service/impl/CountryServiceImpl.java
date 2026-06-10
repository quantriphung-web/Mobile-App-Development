package com.phungtriquan.service.impl;

import com.phungtriquan.model.Country;
import com.phungtriquan.repository.CountryRepository;
import com.phungtriquan.service.CountryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;


@Service
@RequiredArgsConstructor
public class CountryServiceImpl implements CountryService {

    private final CountryRepository countryRepository;

    @Override
    public List<Country> findAll() {
        return countryRepository.findAll();
    }

    @Override
    public Optional<Country> findById(Integer id) {
        return countryRepository.findById(id);
    }

    @Override
    public Country save(Country country) {
        return countryRepository.save(country);
    }

    @Override
    public boolean existsById(Integer id) {
        return countryRepository.existsById(id);
    }

    @Override
    public void deleteById(Integer id) {
        countryRepository.deleteById(id);
    }
}
