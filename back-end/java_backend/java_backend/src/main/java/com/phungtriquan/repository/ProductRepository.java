package com.phungtriquan.repository;

import com.phungtriquan.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ProductRepository extends JpaRepository<Product, UUID> {

    @Query(value = """
        SELECT * FROM products
        WHERE published = true
          AND compare_price > sale_price
          AND quantity > 0
        ORDER BY (compare_price - sale_price) DESC
        LIMIT 5
        """, nativeQuery = true)
    List<Product> findSaleProducts();

    @Query(value = """
        SELECT * FROM products
        WHERE published = true
          AND quantity > 0
        ORDER BY created_at DESC
        LIMIT 5
        """, nativeQuery = true)
    List<Product> findNewProducts();
}