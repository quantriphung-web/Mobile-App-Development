package com.phungtriquan.service;

import com.phungtriquan.config.TagRequest;
import com.phungtriquan.config.TagResponse;
import com.phungtriquan.config.BadRequestException;
import com.phungtriquan.model.Tag;
import com.phungtriquan.repository.TagRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TagService {

    private final TagRepository tagRepository;

    public List<TagResponse> getAll() {
        return tagRepository.findAll().stream()
                .map(this::toResponse)
                .toList();
    }

    public TagResponse getById(UUID id) {
        return tagRepository.findById(id)
                .map(this::toResponse)
                .orElseThrow(() -> new BadRequestException("Tag not found"));
    }

    public TagResponse create(TagRequest request) {
        if (tagRepository.findByTagName(request.getTagName()).isPresent()) {
            throw new BadRequestException("Tag name already exists");
        }
        Tag tag = Tag.builder()
                .tagName(request.getTagName())
                .icon(request.getIcon())
                .build();
        return toResponse(tagRepository.save(tag));
    }

    public TagResponse update(UUID id, TagRequest request) {
        Tag tag = tagRepository.findById(id)
                .orElseThrow(() -> new BadRequestException("Tag not found"));

        tagRepository.findByTagName(request.getTagName()).ifPresent(existing -> {
            if (!existing.getId().equals(id)) {
                throw new BadRequestException("Tag name already exists");
            }
        });

        tag.setTagName(request.getTagName());
        tag.setIcon(request.getIcon());
        return toResponse(tagRepository.save(tag));
    }

    public void delete(UUID id) {
        Tag tag = tagRepository.findById(id)
                .orElseThrow(() -> new BadRequestException("Tag not found"));
        tagRepository.delete(tag);
    }

    private TagResponse toResponse(Tag tag) {
        return TagResponse.builder()
                .id(tag.getId())
                .tagName(tag.getTagName())
                .icon(tag.getIcon())
                .createdAt(tag.getCreatedAt())
                .updatedAt(tag.getUpdatedAt())
                .build();
    }
}
