// lib/ui/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        elevation: 0,
      ),
      body: Consumer2<ThemeProvider, SettingsProvider>(
        builder: (context, themeProvider, settingsProvider, child) {
          return ListView(
            children: [
              // Theme Settings Section
              _buildSectionHeader(context, 'Tampilan'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        themeProvider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: const Text('Tema Gelap'),
                      subtitle: Text(
                        themeProvider.isDarkMode
                            ? 'Mode gelap aktif'
                            : 'Mode terang aktif',
                      ),
                      trailing: Switch.adaptive(
                        value: themeProvider.isDarkMode,
                        onChanged: themeProvider.isLoading
                            ? null
                            : (value) => themeProvider.toggleTheme(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Notification Settings Section
              _buildSectionHeader(context, 'Notifikasi'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        settingsProvider.isDailyReminderActive
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: const Text('Pengingat Harian'),
                      subtitle: Text(
                        settingsProvider.isDailyReminderActive
                            ? 'Aktif - Notifikasi pada 11:00 AM'
                            : 'Nonaktif - Tidak ada pengingat',
                      ),
                      trailing: Switch.adaptive(
                        value: settingsProvider.isDailyReminderActive,
                        onChanged: settingsProvider.isLoading
                            ? null
                            : (value) => _handleDailyReminderToggle(
                            context, settingsProvider, value),
                      ),
                    ),
                    if (settingsProvider.isDailyReminderActive)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Pengingat akan muncul setiap hari pada pukul 11:00 AM untuk mengingatkan Anda makan siang.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // App Info Section
              _buildSectionHeader(context, 'Tentang Aplikasi'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('Versi Aplikasi'),
                      subtitle: Text('1.0.0'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.developer_mode),
                      title: const Text('Dikembangkan oleh'),
                      subtitle: const Text('Flutter Developer'),
                      onTap: () => _showDeveloperInfo(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.code),
                      title: const Text('Data API'),
                      subtitle: const Text('Dicoding Restaurant API'),
                      onTap: () => _showApiInfo(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Reset Settings Section
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.restore,
                    color: Colors.orange,
                  ),
                  title: const Text('Reset Pengaturan'),
                  subtitle: const Text('Kembalikan pengaturan ke default'),
                  onTap: () => _showResetDialog(context, settingsProvider),
                ),
              ),

              const SizedBox(height: 32),

              // Loading indicator
              if (settingsProvider.isLoading || themeProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),

              // Error message
              if (settingsProvider.errorMessage != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          settingsProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        onPressed: settingsProvider.clearError,
                        icon: const Icon(Icons.close, color: Colors.red),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Future<void> _handleDailyReminderToggle(
      BuildContext context,
      SettingsProvider settingsProvider,
      bool value,
      ) async {
    if (value) {
      // Show permission dialog first
      final bool shouldEnable = await _showPermissionDialog(context);
      if (shouldEnable) {
        await settingsProvider.toggleDailyReminder(value);
      }
    } else {
      await settingsProvider.toggleDailyReminder(value);
    }
  }

  Future<bool> _showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izin Notifikasi'),
          content: const Text(
            'Aplikasi memerlukan izin untuk menampilkan notifikasi pengingat harian. '
                'Pastikan Anda mengizinkan notifikasi dari aplikasi ini di pengaturan perangkat.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Lanjutkan'),
            ),
          ],
        );
      },
    ) ??
        false;
  }

  void _showResetDialog(
      BuildContext context,
      SettingsProvider settingsProvider,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Pengaturan'),
          content: const Text(
            'Apakah Anda yakin ingin mereset semua pengaturan ke default? '
                'Tindakan ini akan menghapus semua preferensi yang telah Anda simpan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await settingsProvider.resetSettings();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengaturan berhasil direset'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _showDeveloperInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Informasi Developer'),
          content: const Text(
            'Aplikasi Restaurant App ini dikembangkan sebagai bagian dari submission '
                'kelas Flutter Fundamental di Dicoding Academy.\n\n'
                'Dibuat dengan Flutter dan menggunakan Dicoding Restaurant API.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _showApiInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Informasi API'),
          content: const Text(
            'Data restoran disediakan oleh Dicoding Restaurant API.\n\n'
                'Base URL: https://restaurant-api.dicoding.dev\n\n'
                'API ini menyediakan data daftar restoran, detail restoran, '
                'pencarian, dan fitur review.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}