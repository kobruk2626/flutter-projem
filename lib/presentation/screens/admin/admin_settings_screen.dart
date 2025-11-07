import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_momento/presentation/providers/auth_provider.dart';
import 'package:photo_momento/presentation/providers/settings_provider.dart';
import 'package:photo_momento/presentation/widgets/custom_app_bar.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    if (!authProvider.isAdmin) {
      return _buildAccessDenied();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Sistem Ayarları',
        showBackButton: true,
      ),
      body: settingsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSettingsContent(settingsProvider),
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Sistem Ayarları',
        showBackButton: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Erişim Reddedildi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContent(SettingsProvider settingsProvider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // System Status
        _buildSystemStatus(settingsProvider),
        const SizedBox(height: 24),

        // General Settings
        _buildSettingsSection(
          'Genel Ayarlar',
          Icons.settings,
          [
            _buildSettingsItem('Mağaza Bilgileri', Icons.store, _navigateToStoreSettings),
            _buildSettingsItem('Fiyat & Ödeme Ayarları', Icons.attach_money, _navigateToPaymentSettings),
            _buildSettingsItem('Kargo & Teslimat', Icons.local_shipping, _navigateToShippingSettings),
            _buildSettingsItem('Stok Yönetimi', Icons.inventory, _navigateToStockSettings),
          ],
        ),
        const SizedBox(height: 24),

        // Notification & Communication
        _buildSettingsSection(
          'Bildirim & İletişim',
          Icons.notifications,
          [
            _buildSettingsItem('E-posta Ayarları', Icons.email, _navigateToEmailSettings),
            _buildSettingsItem('SMS Ayarları', Icons.sms, _navigateToSmsSettings),
            _buildSettingsItem('Push Bildirimleri', Icons.notification_important, _navigateToPushSettings),
          ],
        ),
        const SizedBox(height: 24),

        // User Management
        _buildSettingsSection(
          'Kullanıcı Yönetimi',
          Icons.people,
          [
            _buildSettingsItem('Admin Kullanıcıları', Icons.admin_panel_settings, _navigateToAdminUsers),
            _buildSettingsItem('Güvenlik & İzinler', Icons.security, _navigateToSecuritySettings),
          ],
        ),
        const SizedBox(height: 24),

        // System Maintenance
        _buildSettingsSection(
          'Sistem Bakım',
          Icons.build,
          [
            _buildSettingsItem('Yedekleme & Geri Yükleme', Icons.backup, _navigateToBackupSettings),
            _buildSettingsItem('Sistem Logları', Icons.list_alt, _navigateToSystemLogs),
            _buildSettingsItem('Performans Ayarları', Icons.speed, _navigateToPerformanceSettings),
          ],
        ),
        const SizedBox(height: 32),

        // Quick Actions
        _buildQuickActions(settingsProvider),
      ],
    );
  }

  Widget _buildSystemStatus(SettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_queue,
                  color: settingsProvider.systemStatus == 'online'
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sistem Durumu: ${settingsProvider.systemStatus == 'online' ? 'ÇALIŞIYOR' : 'BAKIMDA'}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: settingsProvider.systemStatus == 'online'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSystemMetric('Sunucu Yükü', '${settingsProvider.serverLoad}%'),
                _buildSystemMetric('Bellek', '${settingsProvider.memoryUsage}%'),
                _buildSystemMetric('Disk', '${settingsProvider.diskUsage}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, IconData icon, List<Widget> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildQuickActions(SettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hızlı İşlemler',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickActionButton('Yedek Al', Icons.backup, _createBackup),
                _buildQuickActionButton('Önbelleği Temizle', Icons.cleaning_services, _clearCache),
                _buildQuickActionButton('Sistem Taraması', Icons.security, _runSystemScan),
                _buildQuickActionButton('Logları Temizle', Icons.delete_sweep, _clearLogs),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue,
      ),
    );
  }

  // Navigation Methods
  void _navigateToStoreSettings() {
    _showComingSoon('Mağaza Bilgileri');
  }

  void _navigateToPaymentSettings() {
    _showComingSoon('Fiyat & Ödeme Ayarları');
  }

  void _navigateToShippingSettings() {
    _showComingSoon('Kargo & Teslimat');
  }

  void _navigateToStockSettings() {
    _showComingSoon('Stok Yönetimi');
  }

  void _navigateToEmailSettings() {
    _showComingSoon('E-posta Ayarları');
  }

  void _navigateToSmsSettings() {
    _showComingSoon('SMS Ayarları');
  }

  void _navigateToPushSettings() {
    _showComingSoon('Push Bildirimleri');
  }

  void _navigateToAdminUsers() {
    _showComingSoon('Admin Kullanıcıları');
  }

  void _navigateToSecuritySettings() {
    _showComingSoon('Güvenlik & İzinler');
  }

  void _navigateToBackupSettings() {
    _showComingSoon('Yedekleme & Geri Yükleme');
  }

  void _navigateToSystemLogs() {
    _showComingSoon('Sistem Logları');
  }

  void _navigateToPerformanceSettings() {
    _showComingSoon('Performans Ayarları');
  }

  // Quick Actions Methods
  void _createBackup() {
    _showActionDialog('Yedekleme', 'Sistem yedeklemesi başlatılıyor...');
  }

  void _clearCache() {
    _showActionDialog('Önbellek Temizleme', 'Önbellek temizleniyor...');
  }

  void _runSystemScan() {
    _showActionDialog('Sistem Taraması', 'Sistem güvenlik taraması başlatılıyor...');
  }

  void _clearLogs() {
    _showActionDialog('Log Temizleme', 'Sistem logları temizleniyor...');
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('Bu özellik yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showActionDialog(String action, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$action başlatıldı'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
  }
}