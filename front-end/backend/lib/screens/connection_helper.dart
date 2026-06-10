import 'package:flutter/material.dart';
import 'package:backend/screens/api_service.dart';
import 'package:backend/screens/product_model.dart';
import 'package:backend/screens/productdetailscreen.dart';

/// Gọi hàm này thay cho Navigator.push trực tiếp khi navigate đến ProductDetailScreen.
/// Tự động kiểm tra kết nối backend trước khi navigate.
/// Nếu mất kết nối → hiện snackbar lỗi, không navigate.
/// Nếu có kết nối → navigate bình thường.
Future<void> navigateToProduct(BuildContext context, Product product) async {
  // Hiện loading indicator nhỏ trên snackbar trong khi kiểm tra
  final messenger = ScaffoldMessenger.of(context);

  final isConnected = await ApiService.checkConnection();

  if (!context.mounted) return;

  if (!isConnected) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Không thể kết nối đến server.\nVui lòng kiểm tra lại kết nối.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Thử lại',
          textColor: Colors.white,
          onPressed: () => navigateToProduct(context, product),
        ),
      ),
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
  );
}
