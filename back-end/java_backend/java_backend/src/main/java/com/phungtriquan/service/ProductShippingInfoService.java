package com.phungtriquan.service;

import com.phungtriquan.model.ProductShippingInfo;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProductShippingInfoService {
    List<ProductShippingInfo> findAll();
    Optional<ProductShippingInfo> findById(UUID id);
    ProductShippingInfo save(ProductShippingInfo productShippingInfo);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
