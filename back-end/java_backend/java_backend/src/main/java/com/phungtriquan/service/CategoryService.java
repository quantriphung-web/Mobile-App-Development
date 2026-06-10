package com.phungtriquan.service;

import com.phungtriquan.config.CategoryRequest;
import com.phungtriquan.config.CategoryResponse;
import com.phungtriquan.config.BadRequestException;
import com.phungtriquan.model.Category;
import com.phungtriquan.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.HashSet;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public List<CategoryResponse> getAll() {
        return categoryRepository.findAll().stream()
                .map(this::toResponse)
                .toList();
    }

    public CategoryResponse getById(UUID id) {
        return categoryRepository.findById(id)
                .map(this::toResponse)
                .orElseThrow(() -> new BadRequestException("Category not found"));
    }

    public CategoryResponse create(CategoryRequest request) {
        Category category = Category.builder()
                .categoryName(request.getCategoryName())
                .categoryDescription(request.getCategoryDescription())
                .icon(request.getIcon())
                .image(request.getImage())
                .placeholder(request.getPlaceholder())
                .active(request.getActive() != null ? request.getActive() : true)
                .genres(request.getGenres() != null ? request.getGenres() : new HashSet<>())
                .build();

        if (request.getParentId() != null) {
            Category parent = categoryRepository.findById(request.getParentId())
                    .orElseThrow(() -> new BadRequestException("Parent category not found"));
            category.setParent(parent);
        }

        return toResponse(categoryRepository.save(category));
    }

    public CategoryResponse update(UUID id, CategoryRequest request) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new BadRequestException("Category not found"));

        category.setCategoryName(request.getCategoryName());
        category.setCategoryDescription(request.getCategoryDescription());
        category.setIcon(request.getIcon());
        category.setImage(request.getImage());
        category.setPlaceholder(request.getPlaceholder());
        if (request.getActive() != null) {
            category.setActive(request.getActive());
        }
        if (request.getGenres() != null) {
            category.setGenres(request.getGenres());
        }

        if (request.getParentId() != null) {
            Category parent = categoryRepository.findById(request.getParentId())
                    .orElseThrow(() -> new BadRequestException("Parent category not found"));
            category.setParent(parent);
        } else {
            category.setParent(null);
        }

        return toResponse(categoryRepository.save(category));
    }

    public void delete(UUID id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new BadRequestException("Category not found"));
        categoryRepository.delete(category);
    }

    private CategoryResponse toResponse(Category cat) {
        return CategoryResponse.builder()
                .id(cat.getId())
                .parentId(cat.getParent() != null ? cat.getParent().getId() : null)
                .categoryName(cat.getCategoryName())
                .categoryDescription(cat.getCategoryDescription())
                .icon(cat.getIcon())
                .image(cat.getImage())
                .placeholder(cat.getPlaceholder())
                .active(cat.getActive())
                .createdAt(cat.getCreatedAt())
                .updatedAt(cat.getUpdatedAt())
                .genres(cat.getGenres())
                .build();
    }
}
