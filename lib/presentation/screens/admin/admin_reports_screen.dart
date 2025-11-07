import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_momento/presentation/providers/auth_provider.dart';
import 'package:photo_momento/presentation/providers/report_provider.dart';
import 'package:photo_momento/presentation/widgets/custom_app_bar.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabTitles = ['Genel', 'Sipariş', 'Gelir', 'Müşteri', 'Ürün'];

  DateTimeRange? _selectedDateRange;
  String _selectedPeriod = 'this_month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _loadReports();
  }

  void _loadReports() {
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    reportProvider.loadReports();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final reportProvider = Provider.of<ReportProvider>(context);

    if (!authProvider.isAdmin) {
      return _buildAccessDenied();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Raporlar',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              _exportReports();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Filter
          _buildDateFilterSection(reportProvider),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              isScrollable: true,
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralReports(reportProvider),
                _buildOrderReports(reportProvider),
                _buildRevenueReports(reportProvider),
                _buildCustomerReports(reportProvider),
                _buildProductReports(reportProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Raporlar',
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

  Widget _buildDateFilterSection(ReportProvider reportProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Row(
            children: [
              // Period Selector
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPeriod,
                  items: const [
                    DropdownMenuItem(value: 'today', child: Text('Bugün')),
                    DropdownMenuItem(value: 'yesterday', child: Text('Dün')),
                    DropdownMenuItem(value: 'this_week', child: Text('Bu Hafta')),
                    DropdownMenuItem(value: 'this_month', child: Text('Bu Ay')),
                    DropdownMenuItem(value: 'this_year', child: Text('Bu Yıl')),
                    DropdownMenuItem(value: 'custom', child: Text('Özel Tarih')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriod = value!;
                      if (value != 'custom') {
                        _selectedDateRange = null;
                      }
                    });
                    _applyDateFilter(reportProvider);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Custom Date Range Button
              if (_selectedPeriod == 'custom')
                OutlinedButton(
                  onPressed: () {
                    _selectDateRange();
                  },
                  child: const Text('Tarih Seç'),
                ),
            ],
          ),

          // Selected Date Range Display
          if (_selectedDateRange != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGeneralReports(ReportProvider reportProvider) {
    if (reportProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Key Metrics
          _buildKeyMetrics(reportProvider),
          const SizedBox(height: 24),

          // Charts Section
          _buildChartsSection(reportProvider),
          const SizedBox(height: 24),

          // Quick Reports
          _buildQuickReports(),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(ReportProvider reportProvider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildMetricCard(
          'Toplam Sipariş',
          reportProvider.totalOrders.toString(),
          Icons.shopping_cart,
          Colors.blue,
        ),
        _buildMetricCard(
          'Toplam Gelir',
          '${reportProvider.totalRevenue}₺',
          Icons.attach_money,
          Colors.green,
        ),
        _buildMetricCard(
          'Yeni Müşteri',
          reportProvider.newCustomers.toString(),
          Icons.person_add,
          Colors.orange,
        ),
        _buildMetricCard(
          'Ort. Puan',
          reportProvider.averageRating.toStringAsFixed(1),
          Icons.star,
          Colors.amber,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(ReportProvider reportProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aylık Gelişim',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // Placeholder for charts
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Grafikler yakında eklenecek',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReports() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hızlı Raporlar',
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
                _buildQuickReportButton('Günlük Sipariş Raporu', Icons.shopping_cart),
                _buildQuickReportButton('Aylık Gelir Raporu', Icons.attach_money),
                _buildQuickReportButton('Müşteri Analizi', Icons.people),
                _buildQuickReportButton('Ürün Performansı', Icons.photo_library),
                _buildQuickReportButton('Stok Durumu', Icons.inventory),
                _buildQuickReportButton('Bildirim Raporları', Icons.notifications),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReportButton(String title, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {
        _generateQuickReport(title);
      },
      icon: Icon(icon, size: 16),
      label: Text(title),
    );
  }

  // Placeholder methods for other report types
  Widget _buildOrderReports(ReportProvider reportProvider) {
    return const Center(child: Text('Sipariş Raporları Yakında Eklenecek'));
  }

  Widget _buildRevenueReports(ReportProvider reportProvider) {
    return const Center(child: Text('Gelir Raporları Yakında Eklenecek'));
  }

  Widget _buildCustomerReports(ReportProvider reportProvider) {
    return const Center(child: Text('Müşteri Raporları Yakında Eklenecek'));
  }

  Widget _buildProductReports(ReportProvider reportProvider) {
    return const Center(child: Text('Ürün Raporları Yakında Eklenecek'));
  }

  void _applyDateFilter(ReportProvider reportProvider) {
    // Implement date filtering logic
    setState(() {});
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      saveText: 'Uygula',
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      _applyDateFilter(Provider.of<ReportProvider>(context, listen: false));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _exportReports() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Raporu İndir',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Excel Formatında İndir'),
              onTap: () {
                Navigator.pop(context);
                _downloadExcelReport();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('PDF Formatında İndir'),
              onTap: () {
                Navigator.pop(context);
                _downloadPdfReport();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _downloadExcelReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Excel rapor indirme özelliği yakında eklenecek'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _downloadPdfReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF rapor indirme özelliği yakında eklenecek'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _generateQuickReport(String reportType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$reportType oluşturuluyor...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}