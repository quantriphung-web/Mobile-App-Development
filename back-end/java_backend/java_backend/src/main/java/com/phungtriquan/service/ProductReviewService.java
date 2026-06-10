package com.phungtriquan.service;

import com.phungtriquan.config.BadRequestException;
import com.phungtriquan.config.UpdateReviewRequest;
import com.phungtriquan.model.Product;
import com.phungtriquan.model.ProductReview;
import com.phungtriquan.model.StaffAccount;
import com.phungtriquan.repository.ProductRepository;
import com.phungtriquan.repository.ProductReviewRepository;
import com.phungtriquan.repository.StaffAccountRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.*;
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@RequiredArgsConstructor
public class ProductReviewService {

    private final ProductReviewRepository reviewRepository;
    private final StaffAccountRepository  staffAccountRepository;
    private final ProductRepository       productRepository;

    @Value("${app.review.upload.dir:${user.dir}/uploads/reviews}")
    private String uploadDir;

    @Value("${app.base-url:http://192.168.100.66:8080}")
    private String baseUrl;

    private static final DateTimeFormatter DATE_FMT =
            DateTimeFormatter.ofPattern("MMM dd, yyyy")
                             .withZone(ZoneId.systemDefault());

    private static final String[] COLORS = {
        "#EF9A9A","#90CAF9","#A5D6A7","#FFE082",
        "#CE93D8","#80DEEA","#FFAB91","#B0BEC5"
    };

    @Transactional(readOnly = true)
    public List<ProductReview> getReviews(UUID productId) {
        return reviewRepository.findByProductIdOrderByCreatedAtDesc(productId);
    }

    @Transactional
    public ProductReview createReview(
            UUID productId,
            Integer rating,
            String reviewText,
            List<MultipartFile> photos,
            Authentication authentication
    ) throws IOException {

        StaffAccount user = getAuthenticatedUser(authentication);

        if (reviewRepository.existsByProductIdAndUser_Id(productId, user.getId())) {
            throw new BadRequestException(
                    "You have already reviewed this product. You can edit or delete your existing review.");
        }

        String fullName = (user.getFirstName() + " " + user.getLastName()).trim();
        String letter   = fullName.isEmpty() ? "U"
                        : String.valueOf(fullName.charAt(0)).toUpperCase();
        String color    = COLORS[(int)(Math.abs(user.getId().hashCode()) % COLORS.length)];

        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new BadRequestException("Product not found: " + productId));

        List<String> savedUrls = savePhotos(photos);

        ProductReview review = ProductReview.builder()
                .product(product)
                .user(user)
                .reviewerName(fullName.isEmpty() ? user.getEmail() : fullName)
                .avatarLetter(letter)
                .avatarColor(color)
                .rating(rating == null ? 5 : rating)
                .reviewText(reviewText)
                .reviewDate(DATE_FMT.format(Instant.now()))
                .hasPhoto(!savedUrls.isEmpty())
                .photoUrls(savedUrls.toArray(new String[0]))
                .helpfulCount(0)
                .createdAt(Instant.now())
                .build();

        return reviewRepository.save(review);
    }

    @Transactional
    public ProductReview updateReview(
            UUID productId,
            Long reviewId,
            UpdateReviewRequest request,
            Authentication authentication
    ) {
        StaffAccount user = getAuthenticatedUser(authentication);
        ProductReview review = getOwnedReview(productId, reviewId, user);

        if (request.getRating() != null) {
            review.setRating(request.getRating());
        }
        if (request.getReviewText() != null) {
            review.setReviewText(request.getReviewText().trim());
        }
        if (request.getPhotoUrls() != null) {
            String[] urls = request.getPhotoUrls().stream()
                    .filter(url -> url != null && !url.isBlank())
                    .map(String::trim)
                    .toArray(String[]::new);
            review.setPhotoUrls(urls);
            review.setHasPhoto(urls.length > 0);
        }

        review.setReviewDate(DATE_FMT.format(Instant.now()));
        return reviewRepository.save(review);
    }

    @Transactional
    public void deleteReview(UUID productId, Long reviewId, Authentication authentication) {
        StaffAccount user = getAuthenticatedUser(authentication);
        ProductReview review = getOwnedReview(productId, reviewId, user);
        reviewRepository.delete(review);
    }

    public Optional<ProductReview> markHelpful(Long reviewId) {
        return reviewRepository.findById(reviewId).map(r -> {
            r.setHelpfulCount(r.getHelpfulCount() + 1);
            return reviewRepository.save(r);
        });
    }

    private StaffAccount getAuthenticatedUser(Authentication authentication) {
        if (authentication == null || authentication.getName() == null) {
            throw new BadRequestException("Authentication required");
        }
        return staffAccountRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new BadRequestException("User not found"));
    }

    private ProductReview getOwnedReview(UUID productId, Long reviewId, StaffAccount user) {
        ProductReview review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new BadRequestException("Review not found"));

        if (review.getProduct() == null
                || !productId.equals(review.getProduct().getId())) {
            throw new BadRequestException("Review does not belong to this product");
        }
        if (review.getUser() == null || !user.getId().equals(review.getUser().getId())) {
            throw new BadRequestException("You can only modify your own review");
        }
        return review;
    }

    private List<String> savePhotos(List<MultipartFile> photos) throws IOException {
        if (photos == null || photos.isEmpty()) return List.of();

        Path dirPath = Paths.get(uploadDir);
        Files.createDirectories(dirPath);

        List<String> urls = new ArrayList<>();
        for (MultipartFile file : photos) {
            if (file == null || file.isEmpty()) continue;

            String originalName = file.getOriginalFilename() != null
                    ? file.getOriginalFilename().trim()
                    : "unknown.jpg";

            String ext      = getExtension(originalName);
            String filename = UUID.randomUUID() + "." + ext;
            Path   dest     = dirPath.resolve(filename);

            Files.copy(file.getInputStream(), dest,
                       StandardCopyOption.REPLACE_EXISTING);

            String url = (baseUrl + "/uploads/reviews/" + filename).trim();
            urls.add(url);
        }
        return urls;
    }

    private String getExtension(String filename) {
        if (filename == null || !filename.contains(".")) return "jpg";
        filename = filename.trim();
        return filename.substring(filename.lastIndexOf('.') + 1).toLowerCase().trim();
    }
}
