
import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final String? title;

  const CustomErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    String friendlyMessage = _getFriendlyErrorMessage(error);
    IconData errorIcon = _getErrorIcon(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              errorIcon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title ?? 'Oops! Terjadi Kesalahan',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              friendlyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getFriendlyErrorMessage(String error) {
    String lowerError = error.toLowerCase();

    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return 'Tidak dapat terhubung ke internet.\nPastikan koneksi internet Anda aktif dan coba lagi.';
    } else if (lowerError.contains('timeout')) {
      return 'Koneksi terlalu lambat.\nSilakan periksa koneksi internet Anda dan coba lagi.';
    } else if (lowerError.contains('404') || lowerError.contains('not found')) {
      return 'Data yang dicari tidak ditemukan.\nSilakan coba dengan kata kunci lain.';
    } else if (lowerError.contains('500') || lowerError.contains('server')) {
      return 'Server sedang mengalami gangguan.\nSilakan coba beberapa saat lagi.';
    } else if (lowerError.contains('failed to load')) {
      return 'Gagal memuat data.\nSilakan periksa koneksi internet dan coba lagi.';
    } else if (lowerError.contains('search')) {
      return 'Pencarian tidak ditemukan.\nCoba gunakan kata kunci yang berbeda.';
    } else {
      return 'Terjadi kesalahan tak terduga.\nSilakan coba lagi atau hubungi tim support jika masalah berlanjut.';
    }
  }

  IconData _getErrorIcon(String error) {
    String lowerError = error.toLowerCase();

    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return Icons.wifi_off_rounded;
    } else if (lowerError.contains('search') || lowerError.contains('not found')) {
      return Icons.search_off_rounded;
    } else if (lowerError.contains('server')) {
      return Icons.cloud_off_rounded;
    } else {
      return Icons.error_outline_rounded;
    }
  }
}