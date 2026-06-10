package com.phungtriquan.service;

import com.phungtriquan.model.Country;
import java.util.List;
import java.util.Optional;


public interface CountryService {
    List<Country> findAll();
    Optional<Country> findById(Integer id);
    Country save(Country country);
    boolean existsById(Integer id);
    void deleteById(Integer id);
}
