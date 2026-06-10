package com.phungtriquan.repository;

import com.phungtriquan.model.Category;
import com.phungtriquan.model.Product;
import com.phungtriquan.model.ProductCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Repository
public interface ProductCategoryRepository extends JpaRepository<ProductCategory, UUID> {
    List<ProductCategory> findByProduct(Product product);
    List<ProductCategory> findByCategory(Category category);

    @Transactional
    void deleteByProduct(Product product);

    @Transactional
    void deleteByCategory(Category category);
}
