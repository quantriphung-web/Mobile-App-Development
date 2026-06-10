import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:backend/screens/product_model.dart';
import 'package:backend/screens/api_service.dart';

// ─────────────────────────────────────────────
// RATINGS & REVIEWS SCREEN
// ─────────────────────────────────────────────
class RatingsScreen extends StatefulWidget {
  final Product product;
  final List<Map<String, dynamic>> reviews;

  const RatingsScreen({
    super.key,
    required this.product,
    required this.reviews,
  });

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  bool withPhoto = false;
  bool _isLoggedIn = false;
  bool _reviewsChanged = false;
  late List<Map<String, dynamic>> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = List.from(widget.reviews);
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final user = await ApiService.getCurrentUser();
    if (!mounted) return;
    setState(() => _isLoggedIn = user != null);
  }

  void _popWithResult() => Navigator.pop(context, _reviewsChanged);

  double get _avgRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.fold<double>(
          0,
          (s, r) => s + (r['rating'] as num).toDouble(),
        ) /
        _reviews.length;
  }

  int _countStars(int stars) =>
      _reviews.where((r) => (r['rating'] as num).toInt() == stars).length;

  /// Returns the index of the current user's review, or -1 if none.
  int get _currentUserReviewIndex => _reviews.indexWhere(
    (r) =>
        (r['reviewer_name'] ?? '') == 'You' || (r['is_current_user'] == true),
  );

  bool get _currentUserHasReviewed => _currentUserReviewIndex != -1;

  // ── FAB actions ──────────────────────────────

  /// Open WriteReviewSheet for a brand-new review.
  Future<void> _writeNewReview() async {
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to write a review.')),
      );
      return;
    }
    if (_currentUserHasReviewed) return;

    final added = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WriteReviewSheet(productId: widget.product.id),
    );
    if (added != null) {
      setState(() {
        _reviews.insert(0, added);
        _reviewsChanged = true;
      });
    }
  }

  /// Open WriteReviewSheet pre-filled with existing data for editing.
  Future<void> _editReview(int index) async {
    final existing = _reviews[index];
    final updated = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WriteReviewSheet(
        productId: widget.product.id,
        existingReview: existing,
      ),
    );
    if (updated != null) {
      setState(() {
        _reviews[index] = updated;
        _reviewsChanged = true;
      });
    }
  }

  /// Show a confirm dialog then delete the review.
  Future<void> _deleteReview(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete review?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to delete your review? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final review = _reviews[index];
      final reviewId =
          (review['id'] ?? review['review_id'] ?? review['reviewId'])
              ?.toString();
      var deleted = false;
      if (reviewId != null && reviewId.isNotEmpty) {
        try {
          deleted = await ApiService.deleteProductReview(
            widget.product.id,
            reviewId,
          );
        } catch (_) {
          deleted = false;
        }
      }

      if (deleted) {
        setState(() {
          _reviews.removeAt(index);
          _reviewsChanged = true;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete review. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = withPhoto
        ? _reviews.where((r) {
            final urls =
                (r['photo_urls'] as List?)
                    ?.cast<String>()
                    .where((u) => u.trim().isNotEmpty)
                    .toList() ??
                [];
            return urls.isNotEmpty;
          }).toList()
        : _reviews;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _popWithResult();
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _popWithResult,
        ),
        title: Text(
          widget.product.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      // ── FAB: ẩn khi chưa đăng nhập hoặc đã đánh giá ──
      floatingActionButton: !_isLoggedIn || _currentUserHasReviewed
          ? null
          : FloatingActionButton.extended(
              onPressed: _writeNewReview,
              backgroundColor: const Color(0xFFE53935),
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              label: const Text(
                'Write a review',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rating & Reviews',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (i) {
                              if (i < _avgRating.floor()) {
                                return const Icon(
                                  Icons.star,
                                  color: Color(0xFFFFC107),
                                  size: 16,
                                );
                              } else if (i < _avgRating &&
                                  _avgRating % 1 >= 0.5) {
                                return const Icon(
                                  Icons.star_half,
                                  color: Color(0xFFFFC107),
                                  size: 16,
                                );
                              }
                              return const Icon(
                                Icons.star_border,
                                color: Color(0xFFFFC107),
                                size: 16,
                              );
                            }),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_reviews.length} ratings',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            _RatingBar(
                              stars: 5,
                              count: _countStars(5),
                              total: _reviews.length,
                            ),
                            _RatingBar(
                              stars: 4,
                              count: _countStars(4),
                              total: _reviews.length,
                            ),
                            _RatingBar(
                              stars: 3,
                              count: _countStars(3),
                              total: _reviews.length,
                            ),
                            _RatingBar(
                              stars: 2,
                              count: _countStars(2),
                              total: _reviews.length,
                            ),
                            _RatingBar(
                              stars: 1,
                              count: _countStars(1),
                              total: _reviews.length,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filtered.length} reviews',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => withPhoto = !withPhoto),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: withPhoto
                                  ? Colors.black
                                  : Colors.grey[400]!,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            color: withPhoto ? Colors.black : Colors.white,
                          ),
                          child: withPhoto
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'With photo',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          filtered.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          withPhoto
                              ? 'No photo reviews yet'
                              : 'No reviews yet. Be the first!',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((_, i) {
                    final review = filtered[i];
                    final isCurrentUser =
                        (review['reviewer_name'] ?? '') == 'You' ||
                        (review['is_current_user'] == true);
                    // Find the real index in _reviews for edit/delete
                    final realIndex = _reviews.indexOf(review);
                    return _ReviewCard(
                      review: review,
                      isCurrentUser: isCurrentUser,
                      onEdit: isCurrentUser && realIndex != -1
                          ? () => _editReview(realIndex)
                          : null,
                      onDelete: isCurrentUser && realIndex != -1
                          ? () => _deleteReview(realIndex)
                          : null,
                    );
                  }, childCount: filtered.length),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final int stars;
  final int count;
  final int total;

  const _RatingBar({
    required this.stars,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          ...List.generate(
            stars,
            (_) => const Icon(Icons.star, size: 12, color: Color(0xFFFFC107)),
          ),
          ...List.generate(
            5 - stars,
            (_) => const Icon(Icons.star_border, size: 12, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: fraction,
                backgroundColor: const Color(0xFFEEEEEE),
                color: const Color(0xFFE53935),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 16,
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Review Card  (now shows Edit / Delete for own review)
// ─────────────────────────────────────────────
class _ReviewCard extends StatefulWidget {
  final Map<String, dynamic> review;
  final bool isCurrentUser;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ReviewCard({
    required this.review,
    this.isCurrentUser = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _helpful = false;
  late int _helpfulCount;

  @override
  void initState() {
    super.initState();
    _helpfulCount = (widget.review['helpful_count'] as num?)?.toInt() ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.review;

    final name = (r['reviewer_name'] ?? r['name'] ?? 'Anonymous').toString();
    final avatarLetter = (r['avatar_letter'] ?? r['avatar'] ?? name[0])
        .toString();
    final avatarColorStr = (r['avatar_color'] ?? '#EF9A9A').toString();
    final rating = (r['rating'] as num).toInt();
    final text = (r['review_text'] ?? r['text'] ?? '').toString();
    final date = (r['review_date'] ?? r['date'] ?? '').toString();

    final photoUrls =
        (r['photo_urls'] as List?)
            ?.cast<String>()
            .map((url) => url.trim())
            .where((url) => url.isNotEmpty)
            .toList() ??
        [];

    Color avatarColor;
    try {
      final hex = avatarColorStr.replaceAll('#', '');
      avatarColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      avatarColor = const Color(0xFFEF9A9A);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Subtle highlight border for current user's review
        border: widget.isCurrentUser
            ? Border.all(
                color: const Color(0xFF1565C0).withValues(alpha: 0.35),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: avatarColor,
            child: Text(
              avatarLetter.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if (widget.isCurrentUser) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1565C0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'You',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.isCurrentUser)
                      // Edit / Delete icon button
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') widget.onEdit?.call();
                          if (value == 'delete') widget.onDelete?.call();
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Color(0xFFE53935),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Color(0xFFE53935)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        date,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                if (widget.isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      date,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      size: 15,
                      color: const Color(0xFFFFC107),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
                if (photoUrls.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: photoUrls.length,
                      itemBuilder: (_, i) => Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            photoUrls[i],
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                ? child
                                : const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFE53935),
                                      ),
                                    ),
                                  ),
                            errorBuilder: (_, e, s) => Container(
                              color: const Color(0xFFEEEEEE),
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                // Hide "Helpful" for the current user's own review
                if (!widget.isCurrentUser)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_helpfulCount > 0)
                        Text(
                          '$_helpfulCount helpful',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _helpful = !_helpful;
                            _helpfulCount += _helpful ? 1 : -1;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              _helpful
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                              size: 16,
                              color: _helpful
                                  ? const Color(0xFFE53935)
                                  : Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Helpful',
                              style: TextStyle(
                                fontSize: 13,
                                color: _helpful
                                    ? const Color(0xFFE53935)
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WRITE / EDIT REVIEW – Modal Bottom Sheet
// ─────────────────────────────────────────────
class WriteReviewSheet extends StatefulWidget {
  final String productId;

  /// If provided the sheet opens in "edit" mode pre-filled with existing data.
  final Map<String, dynamic>? existingReview;

  const WriteReviewSheet({
    super.key,
    required this.productId,
    this.existingReview,
  });

  @override
  State<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<WriteReviewSheet> {
  int _rating = 0;
  bool _submitting = false;
  late final TextEditingController _controller;
  final List<XFile> _photos = [];
  final ImagePicker _picker = ImagePicker();

  bool get _isEditMode => widget.existingReview != null;

  static const _ratingLabels = [
    '',
    'Poor',
    'Fair',
    'Good',
    'Very Good',
    'Excellent!',
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingReview;
    _rating = existing != null ? (existing['rating'] as num).toInt() : 0;
    _controller = TextEditingController(
      text: existing != null
          ? (existing['review_text'] ?? existing['text'] ?? '').toString()
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _existingPhotoUrls =>
      (widget.existingReview?['photo_urls'] as List?)
          ?.cast<String>()
          .where((u) => u.trim().isNotEmpty)
          .toList() ??
      [];

  Future<void> _pickImage() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty && mounted) {
      setState(() {
        _photos.addAll(picked.map((f) => XFile(f.path.trim())).toList());
        if (_photos.length > 5) _photos.length = 5;
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (picked != null && mounted) {
        setState(() {
          _photos.insert(0, XFile(picked.path.trim()));
          if (_photos.length > 5) _photos.length = 5;
        });
      }
    } catch (_) {
      // ignore camera errors silently for now
    }
  }

  void _removePhoto(int index) => setState(() => _photos.removeAt(index));

  Future<void> _submit() async {
    if (_rating == 0) return;
    setState(() => _submitting = true);
    try {
      Map<String, dynamic>? saved;

      if (_isEditMode) {
        final existingId =
            (widget.existingReview?['id'] ??
                    widget.existingReview?['review_id'])
                ?.toString();
        List<String> uploadedUrls = [];
        if (_photos.isNotEmpty) {
          uploadedUrls = await ApiService.uploadReviewImages(_photos);
        }

        if (existingId != null) {
          final mergedPhotos = uploadedUrls.isNotEmpty
              ? [..._existingPhotoUrls, ...uploadedUrls]
              : _existingPhotoUrls;
          saved = await ApiService.updateProductReview(
            widget.productId,
            existingId,
            rating: _rating,
            reviewText: _controller.text.trim(),
            photoUrls: mergedPhotos,
          );
        } else {
          saved = await ApiService.postProductReview(
            widget.productId,
            reviewerName: '',
            avatarLetter: '',
            avatarColor: '',
            rating: _rating,
            reviewText: _controller.text.trim(),
            photos: _photos,
          );
        }
      } else {
        saved = await ApiService.postProductReview(
          widget.productId,
          reviewerName: '',
          avatarLetter: '',
          avatarColor: '',
          rating: _rating,
          reviewText: _controller.text.trim(),
          photos: _photos,
        );
      }

      if (saved != null && mounted) {
        final photoUrls =
            (saved['photo_urls'] as List?)
                ?.cast<String>()
                .where((u) => u.trim().isNotEmpty)
                .toList() ??
            (_existingPhotoUrls);

        final result = <String, dynamic>{
          'id': saved['id'] ?? widget.existingReview?['id'],
          'reviewer_name':
              saved['reviewer_name'] ?? saved['reviewerName'] ?? '',
          'avatar_letter':
              saved['avatar_letter'] ?? saved['avatarLetter'] ?? '',
          'avatar_color':
              saved['avatar_color'] ?? saved['avatarColor'] ?? '#90CAF9',
          'rating': _rating,
          'review_text': _controller.text.trim(),
          'review_date': _isEditMode
              ? (widget.existingReview!['review_date'] ?? 'Just now')
              : 'Just now',
          'has_photo': photoUrls.isNotEmpty,
          'photo_urls': photoUrls.isNotEmpty ? photoUrls : _existingPhotoUrls,
          'helpful_count': widget.existingReview?['helpful_count'] ?? 0,
          'is_current_user': true,
        };

        Navigator.pop(context, result);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit review. Please login first.'),
          ),
        );
        setState(() => _submitting = false);
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _rating > 0 && !_submitting;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomPad),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: Column(
                children: [
                  Text(
                    _isEditMode ? 'Edit your review' : 'What is your rate?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () => setState(() => _rating = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            i < _rating ? Icons.star : Icons.star_outline,
                            color: i < _rating
                                ? const Color(0xFFFFC107)
                                : Colors.grey[300],
                            size: 44,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  AnimatedOpacity(
                    opacity: _rating > 0 ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _ratingLabels[_rating],
                      style: const TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Please share your opinion about the product',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _controller,
              maxLines: 5,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Your review',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF7F7F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFCCCCCC),
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    width: 120,
                    height: 80,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _photos.length < 5 ? _takePhoto : null,
                              child: Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: _photos.length < 5
                                      ? const Color(0xFFE53935)
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _photos.length < 5 ? _pickImage : null,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _photos.length < 5
                                      ? const Color(0xFF1565C0)
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.photo_library,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Take / Upload',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  ..._photos.asMap().entries.map((entry) {
                    final i = entry.key;
                    final xfile = entry.value;
                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(xfile.path),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, e, s) => Container(
                                color: const Color(0xFFEEEEEE),
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 14,
                          child: GestureDetector(
                            onTap: () => _removePhoto(i),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE53935),
                  disabledForegroundColor: Colors.white54,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _isEditMode ? 'UPDATE REVIEW' : 'SEND REVIEW',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
