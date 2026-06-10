package com.phungtriquan.service;

import com.phungtriquan.config.CategoryResponse;
import com.phungtriquan.config.ProductRequest;
import com.phungtriquan.config.ProductResponse;
import com.phungtriquan.config.TagResponse;
import com.phungtriquan.config.BadRequestException;
import com.phungtriquan.model.Category;
import com.phungtriquan.model.Product;
import com.phungtriquan.model.ProductCategory;
import com.phungtriquan.model.ProductTag;
import com.phungtriquan.model.Tag;
import com.phungtriquan.repository.CategoryRepository;
import com.phungtriquan.repository.ProductCategoryRepository;
import com.phungtriquan.repository.ProductRepository;
import com.phungtriquan.repository.TagRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final ProductCategoryRepository productCategoryRepository;
    private final TagRepository tagRepository;

    @Value("${app.base-url:http://192.168.100.66:8080}")
    private String baseUrl;

    // ───── THÊM MỚI ─────
    public List<ProductResponse> getSaleProducts() {
        return productRepository.findSaleProducts()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public List<ProductResponse> getNewProducts() {
        return productRepository.findNewProducts()
                .stream()
                .map(this::toResponse)
                .toList();
    }
    // ────────────────────

    public List<ProductResponse> getAll() {
        return productRepository.findAll().stream()
                .map(this::toResponse)
                .toList();
    }

    public ProductResponse getById(UUID id) {
        return productRepository.findById(id)
                .map(this::toResponse)
                .orElseThrow(() -> new BadRequestException("Product not found"));
    }

    @Transactional
    public ProductResponse create(ProductRequest request) {
        String slug = request.getSlug();
        if (slug == null || slug.isBlank()) {
            slug = request.getProductName().toLowerCase()
                    .replaceAll("[^a-z0-9]+", "-")
                    .replaceAll("^-|-$", "");
        }

        Product product = Product.builder()
                .slug(slug)
                .productName(request.getProductName())
                .sku(request.getSku())
                .salePrice(request.getSalePrice() != null ? request.getSalePrice() : BigDecimal.ZERO)
                .comparePrice(request.getComparePrice() != null ? request.getComparePrice() : BigDecimal.ZERO)
                .buyingPrice(request.getBuyingPrice())
                .quantity(request.getQuantity() != null ? request.getQuantity() : 0)
                .shortDescription(request.getShortDescription())
                .productDescription(request.getProductDescription())
                .productType(request.getProductType())
                .published(request.getPublished() != null ? request.getPublished() : false)
                .disableOutOfStock(request.getDisableOutOfStock() != null ? request.getDisableOutOfStock() : true)
                .note(request.getNote())
                .image(request.getImage())
                .placeholder(request.getPlaceholder())
                .brand(request.getBrand())
                .size(request.getSize())
                .build();

        if (request.getTagIds() != null) {
            List<ProductTag> productTagList = new ArrayList<>();
            for (UUID tagId : request.getTagIds()) {
                Tag tag = tagRepository.findById(tagId)
                        .orElseThrow(() -> new BadRequestException("Tag not found: " + tagId));
                productTagList.add(ProductTag.builder().product(product).tag(tag).build());
            }
            product.setProductTags(productTagList);
        }

        product = productRepository.save(product);

        if (request.getCategoryIds() != null) {
            for (UUID catId : request.getCategoryIds()) {
                Category category = categoryRepository.findById(catId)
                        .orElseThrow(() -> new BadRequestException("Category not found: " + catId));
                productCategoryRepository.save(
                        ProductCategory.builder().product(product).category(category).build());
            }
        }

        return toResponse(productRepository.findById(product.getId()).orElse(product));
    }

    @Transactional
    public ProductResponse update(UUID id, ProductRequest request) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new BadRequestException("Product not found"));

        String slug = request.getSlug();
        if (slug == null || slug.isBlank()) {
            slug = request.getProductName().toLowerCase()
                    .replaceAll("[^a-z0-9]+", "-")
                    .replaceAll("^-|-$", "");
        }

        product.setSlug(slug);
        product.setProductName(request.getProductName());
        product.setSku(request.getSku());
        product.setSalePrice(request.getSalePrice() != null ? request.getSalePrice() : BigDecimal.ZERO);
        product.setComparePrice(request.getComparePrice() != null ? request.getComparePrice() : BigDecimal.ZERO);
        product.setBuyingPrice(request.getBuyingPrice());
        product.setQuantity(request.getQuantity() != null ? request.getQuantity() : 0);
        product.setShortDescription(request.getShortDescription());
        product.setProductDescription(request.getProductDescription());
        product.setProductType(request.getProductType());
        if (request.getPublished() != null) product.setPublished(request.getPublished());
        if (request.getDisableOutOfStock() != null) product.setDisableOutOfStock(request.getDisableOutOfStock());
        product.setNote(request.getNote());
        product.setImage(request.getImage());
        product.setPlaceholder(request.getPlaceholder());
        product.setBrand(request.getBrand());
        product.setSize(request.getSize());

        if (request.getTagIds() != null) {
            product.getProductTags().clear();
            for (UUID tagId : request.getTagIds()) {
                Tag tag = tagRepository.findById(tagId)
                        .orElseThrow(() -> new BadRequestException("Tag not found: " + tagId));
                product.getProductTags().add(ProductTag.builder().product(product).tag(tag).build());
            }
        }

        product = productRepository.save(product);

        if (request.getCategoryIds() != null) {
            List<ProductCategory> existingLinks = productCategoryRepository.findByProduct(product);
            productCategoryRepository.deleteAll(existingLinks);

            for (UUID catId : request.getCategoryIds()) {
                Category category = categoryRepository.findById(catId)
                        .orElseThrow(() -> new BadRequestException("Category not found: " + catId));
                productCategoryRepository.save(
                        ProductCategory.builder().product(product).category(category).build());
            }
        }

        return toResponse(product);
    }

    @Transactional
    public void delete(UUID id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new BadRequestException("Product not found"));
        productCategoryRepository.deleteByProduct(product);
        productRepository.delete(product);
    }

    @Transactional
    public void addCategory(UUID productId, UUID categoryId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new BadRequestException("Product not found"));
        Category category = categoryRepository.findById(categoryId)
                .orElseThrow(() -> new BadRequestException("Category not found"));

        boolean exists = productCategoryRepository.findByProduct(product).stream()
                .anyMatch(pc -> pc.getCategory().getId().equals(categoryId));
        if (!exists) {
            productCategoryRepository.save(
                    ProductCategory.builder().product(product).category(category).build());
        }
    }

    @Transactional
    public void removeCategory(UUID productId, UUID categoryId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new BadRequestException("Product not found"));
        productCategoryRepository.findByProduct(product).stream()
                .filter(pc -> pc.getCategory().getId().equals(categoryId))
                .findFirst()
                .ifPresent(productCategoryRepository::delete);
    }

    @Transactional
    public void addTag(UUID productId, UUID tagId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new BadRequestException("Tag not found"));
        Tag tag = tagRepository.findById(tagId)
                .orElseThrow(() -> new BadRequestException("Tag not found"));

        boolean exists = product.getProductTags().stream()
                .anyMatch(pt -> pt.getTag().getId().equals(tagId));
        if (!exists) {
            product.getProductTags().add(ProductTag.builder().product(product).tag(tag).build());
            productRepository.save(product);
        }
    }

    @Transactional
    public void removeTag(UUID productId, UUID tagId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new BadRequestException("Product not found"));
        product.getProductTags().stream()
                .filter(pt -> pt.getTag().getId().equals(tagId))
                .findFirst()
                .ifPresent(pt -> {
                    product.getProductTags().remove(pt);
                    productRepository.save(product);
                });
    }

    private String resolveImageUrl(String raw) {
        if (raw == null || raw.isEmpty()) return null;
        if (raw.startsWith("http://") || raw.startsWith("https://")) {
            // Thay localhost bằng app.base-url để Flutter/emulator load được ảnh
            return raw
                    .replace("http://localhost:8080", baseUrl)
                    .replace("http://127.0.0.1:8080", baseUrl);
        }
        if (raw.startsWith("/")) return baseUrl + raw;
        return baseUrl + "/uploads/images/" + raw;
    }

    public ProductResponse toResponse(Product product) {
        List<ProductCategory> links = productCategoryRepository.findByProduct(product);
        List<CategoryResponse> categories = links.stream()
                .map(link -> CategoryResponse.builder()
                        .id(link.getCategory().getId())
                        .categoryName(link.getCategory().getCategoryName())
                        .build())
                .toList();

        List<TagResponse> tags = product.getProductTags().stream()
                .map(pt -> TagResponse.builder()
                        .id(pt.getTag().getId())
                        .tagName(pt.getTag().getTagName())
                        .icon(pt.getTag().getIcon())
                        .build())
                .toList();

        // ── Lấy ảnh từ product_images table (đúng file) ──
        List<String> images = product.getProductImages().stream()
                .sorted(Comparator.comparingInt(pi -> pi.getSortOrder() != null ? pi.getSortOrder() : 0))
                .map(pi -> resolveImageUrl(pi.getImageUrl()))
                .filter(url -> url != null)
                .collect(Collectors.toList());

        // Nếu product_images rỗng, fallback về field image chính
        if (images.isEmpty() && product.getImage() != null) {
            images.add(resolveImageUrl(product.getImage()));
        }

        return ProductResponse.builder()
                .id(product.getId())
                .slug(product.getSlug())
                .productName(product.getProductName())
                .sku(product.getSku())
                .salePrice(product.getSalePrice())
                .comparePrice(product.getComparePrice())
                .buyingPrice(product.getBuyingPrice())
                .quantity(product.getQuantity())
                .shortDescription(product.getShortDescription())
                .productDescription(product.getProductDescription())
                .productType(product.getProductType())
                .published(product.getPublished())
                .disableOutOfStock(product.getDisableOutOfStock())
                .note(product.getNote())
                .image(resolveImageUrl(product.getImage()))
                .placeholder(product.getPlaceholder())
                .brand(product.getBrand())
                .size(product.getSize())
                .categories(categories)
                .tags(tags)
                .images(images)
                .createdAt(product.getCreatedAt())
                .updatedAt(product.getUpdatedAt())
                .build();
    }
}