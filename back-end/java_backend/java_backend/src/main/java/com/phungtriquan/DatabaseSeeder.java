package com.phungtriquan;

import com.phungtriquan.model.Product;
import com.phungtriquan.model.Category;
import com.phungtriquan.model.Tag;
import com.phungtriquan.model.ProductTag;
import com.phungtriquan.repository.ProductRepository;
import com.phungtriquan.repository.CategoryRepository;
import com.phungtriquan.repository.TagRepository;
import com.phungtriquan.repository.ProductTagRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import java.util.*;

@Component
@Profile("!test")
public class DatabaseSeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final TagRepository tagRepository;
    private final ProductTagRepository productTagRepository;

    public DatabaseSeeder(ProductRepository productRepository, 
                          CategoryRepository categoryRepository,
                          TagRepository tagRepository,
                          ProductTagRepository productTagRepository) {
        this.productRepository = productRepository;
        this.categoryRepository = categoryRepository;
        this.tagRepository = tagRepository;
        this.productTagRepository = productTagRepository;
    }

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        // Seed Categories & Genres
        List<Category> categories = categoryRepository.findAll();
        if (categories.isEmpty()) {
            Category catNew = Category.builder()
                    .categoryName("New")
                    .image("assets/img/cate1.png")
                    .genres(new HashSet<>(Arrays.asList("Woman", "Men", "Kids")))
                    .build();
            Category catClothes = Category.builder()
                    .categoryName("Clothes")
                    .image("assets/img/cate2.png")
                    .genres(new HashSet<>(Arrays.asList("Woman", "Men", "Kids")))
                    .build();
            Category catShoes = Category.builder()
                    .categoryName("Shoes")
                    .image("assets/img/cate3.png")
                    .genres(new HashSet<>(Arrays.asList("Woman", "Men", "Kids")))
                    .build();
            Category catAccessories = Category.builder()
                    .categoryName("Accesories")
                    .image("assets/img/cate4.png")
                    .genres(new HashSet<>(Arrays.asList("Woman", "Men", "Kids")))
                    .build();
            categoryRepository.saveAll(Arrays.asList(catNew, catClothes, catShoes, catAccessories));
            System.out.println(">>> DatabaseSeeder: Seeded default categories with genres successfully.");
        } else {
            boolean categoryUpdated = false;
            for (Category cat : categories) {
                if (cat.getGenres() == null || cat.getGenres().isEmpty()) {
                    if (cat.getGenres() == null) {
                        cat.setGenres(new HashSet<>(Arrays.asList("Woman", "Men", "Kids")));
                    } else {
                        cat.getGenres().clear();
                        cat.getGenres().addAll(Arrays.asList("Woman", "Men", "Kids"));
                    }
                    categoryRepository.save(cat);
                    categoryUpdated = true;
                }
            }
            if (categoryUpdated) {
                System.out.println(">>> DatabaseSeeder: Updated existing categories with default genres.");
            }
        }

        // Seed Tags if empty
        List<Tag> tags = tagRepository.findAll();
        if (tags.isEmpty()) {
            Tag tagNew = Tag.builder().tagName("New").icon("🔥").build();
            Tag tagSale = Tag.builder().tagName("Sale").icon("🏷️").build();
            Tag tagTrending = Tag.builder().tagName("Trending").icon("⚡").build();
            Tag tagBestSeller = Tag.builder().tagName("Best Seller").icon("⭐").build();
            tags = tagRepository.saveAll(Arrays.asList(tagNew, tagSale, tagTrending, tagBestSeller));
            System.out.println(">>> DatabaseSeeder: Seeded default tags successfully.");
        }

        List<Product> products = productRepository.findAll();
        boolean updated = false;

        List<String> availableBrands = Arrays.asList(
                "adidas", "adidas Originals", "Blend", "Boutique Moschino", "Champion",
                "Diesel", "Jack & Jones", "Naf Naf", "Red Valentino", "s.Oliver", "Zara", "Mango", "H&M");
        List<String> availableSizes = Arrays.asList("XS", "S", "M", "L", "XL");
        Random random = new Random();

        for (Product product : products) {
            boolean productUpdated = false;

            if (product.getBrand() == null || product.getBrand().trim().isEmpty()) {
                String randomBrand = availableBrands.get(random.nextInt(availableBrands.size()));
                product.setBrand(randomBrand);
                productUpdated = true;
            }

            if (product.getSize() == null || product.getSize().trim().isEmpty()) {
                // Select 2 to 5 random sizes
                int numSizes = 2 + random.nextInt(4); // 2, 3, 4, or 5
                List<String> shuffledSizes = new ArrayList<>(availableSizes);
                Collections.shuffle(shuffledSizes);
                List<String> selectedSizes = shuffledSizes.subList(0, numSizes);

                // Sort the sizes XS, S, M, L, XL to keep them structured
                selectedSizes.sort((a, b) -> {
                    List<String> order = Arrays.asList("XS", "S", "M", "L", "XL");
                    return Integer.compare(order.indexOf(a), order.indexOf(b));
                });

                String joinedSizes = String.join(",", selectedSizes);
                product.setSize(joinedSizes);
                productUpdated = true;
            }

            if (productUpdated) {
                productRepository.save(product);
                updated = true;
            }
        }

        if (updated) {
            System.out.println(
                    ">>> DatabaseSeeder: Automatically seeded missing brand/size attributes for products successfully.");
        } else {
            System.out.println(
                    ">>> DatabaseSeeder: All products already have brand and size attributes. No seeding required.");
        }

        // Seed product-tag associations if none exist
        long productTagCount = productTagRepository.count();
        if (productTagCount == 0 && !products.isEmpty()) {
            Map<String, Tag> tagMap = new HashMap<>();
            for (Tag t : tags) {
                tagMap.put(t.getTagName().toLowerCase(), t);
            }

            Tag tagNew = tagMap.get("new");
            Tag tagSale = tagMap.get("sale");
            Tag tagTrending = tagMap.get("trending");
            Tag tagBest = tagMap.get("best seller");

            for (Product product : products) {
                String slug = product.getSlug() != null ? product.getSlug().toLowerCase() : "";
                List<Tag> tagsToAssign = new ArrayList<>();

                if (slug.contains("short")) {
                    if (tagNew != null) tagsToAssign.add(tagNew);
                    if (tagSale != null) tagsToAssign.add(tagSale);
                } else if (slug.contains("skirt")) {
                    if (tagSale != null) tagsToAssign.add(tagSale);
                } else if (slug.contains("slim-fit") || slug.contains("slim")) {
                    if (tagNew != null) tagsToAssign.add(tagNew);
                    if (tagTrending != null) tagsToAssign.add(tagTrending);
                } else if (slug.contains("baggy")) {
                    if (tagTrending != null) tagsToAssign.add(tagTrending);
                } else if (slug.contains("dress")) {
                    if (slug.contains("girls")) {
                        if (tagNew != null) tagsToAssign.add(tagNew);
                        if (tagSale != null) tagsToAssign.add(tagSale);
                    } else {
                        if (tagBest != null) tagsToAssign.add(tagBest);
                    }
                } else if (slug.contains("cargo")) {
                    if (tagNew != null) tagsToAssign.add(tagNew);
                } else {
                    // Fallback random tags for any other products
                    if (tagNew != null) tagsToAssign.add(tagNew);
                    if (tagSale != null) tagsToAssign.add(tagSale);
                }

                for (Tag tag : tagsToAssign) {
                    ProductTag pt = ProductTag.builder()
                            .product(product)
                            .tag(tag)
                            .build();
                    productTagRepository.save(pt);
                }
            }
            System.out.println(">>> DatabaseSeeder: Seeded product-tag associations successfully.");
        }
    }
}
