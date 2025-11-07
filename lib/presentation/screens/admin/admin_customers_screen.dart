import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_momento/presentation/providers/auth_provider.dart';
import 'package:photo_momento/presentation/providers/customer_provider.dart';
import 'package:photo_momento/presentation/widgets/custom_app_bar.dart';
import 'package:photo_momento/data/models/customer_model.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'tumu';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  void _loadCustomers() {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    customerProvider.loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);

    if (!authProvider.isAdmin) {
      return _buildAccessDenied();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Müşteri Yönetimi',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewCustomer,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchFilterSection(customerProvider),

          // Statistics
          _buildStatistics(customerProvider),

          // Customers List
          Expanded(
            child: _buildCustomersList(customerProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Müşteri Yönetimi',
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

  Widget _buildSearchFilterSection(CustomerProvider customerProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'İsim, e-posta veya telefon ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              _applyFilters(customerProvider);
            },
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tümü', 'tumu'),
                const SizedBox(width: 8),
                _buildFilterChip('Aktif', 'aktif'),
                const SizedBox(width: 8),
                _buildFilterChip('Yeni', 'yeni'),
                const SizedBox(width: 8),
                _buildFilterChip('Sadık', 'sadik'),
                const SizedBox(width: 8),
                _buildFilterChip('Pasif', 'pasif'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        _applyFilters(Provider.of<CustomerProvider>(context, listen: false));
      },
    );
  }

  Widget _buildStatistics(CustomerProvider customerProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Toplam', customerProvider.customers.length.toString()),
          _buildStatItem('Aktif', customerProvider.activeCustomersCount.toString()),
          _buildStatItem('Yeni', customerProvider.newCustomersCount.toString()),
          _buildStatItem('Sadık', customerProvider.loyalCustomersCount.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
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

  Widget _buildCustomersList(CustomerProvider customerProvider) {
    if (customerProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (customerProvider.customers.isEmpty) {
      return _buildEmptyCustomers();
    }

    // Filter customers
    final filteredCustomers = customerProvider.customers.where((customer) {
      final matchesFilter = _matchesFilter(customer);
      final query = _searchController.text.toLowerCase();
      final matchesSearch = query.isEmpty ||
          customer.name.toLowerCase().contains(query) ||
          customer.email.toLowerCase().contains(query) ||
          customer.phone.contains(query);

      return matchesFilter && matchesSearch;
    }).toList();

    if (filteredCustomers.isEmpty) {
      return _buildNoCustomersForFilter();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await customerProvider.loadCustomers();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredCustomers.length,
        itemBuilder: (context, index) {
          final customer = filteredCustomers[index];
          return _buildCustomerCard(customer, customerProvider);
        },
      ),
    );
  }

  bool _matchesFilter(CustomerModel customer) {
    switch (_selectedFilter) {
      case 'aktif':
        return customer.isActive;
      case 'yeni':
        return customer.isNew;
      case 'sadik':
        return customer.isLoyal;
      case 'pasif':
        return !customer.isActive;
      default:
        return true;
    }
  }

  Widget _buildCustomerCard(CustomerModel customer, CustomerProvider customerProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer.email,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        customer.phone,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(customer).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(customer),
                    style: TextStyle(
                      color: _getStatusColor(customer),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Customer Details
            Row(
              children: [
                // Customer Avatar
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    customer.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Customer Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${customer.totalOrders} Sipariş',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${customer.totalSpent}₺',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(customer.rating.toStringAsFixed(1)),
                          const SizedBox(width: 12),
                          Icon(Icons.location_on, color: Colors.grey, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              customer.city,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Actions
            _buildCustomerActions(customer, customerProvider),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(CustomerModel customer) {
    if (customer.isLoyal) return Colors.purple;
    if (customer.isNew) return Colors.blue;
    if (customer.isActive) return Colors.green;
    return Colors.orange;
  }

  String _getStatusText(CustomerModel customer) {
    if (customer.isLoyal) return 'Sadık';
    if (customer.isNew) return 'Yeni';
    if (customer.isActive) return 'Aktif';
    return 'Pasif';
  }

  Widget _buildCustomerActions(CustomerModel customer, CustomerProvider customerProvider) {
    return Row(
      children: [
        // Detail Button
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              _viewCustomerDetails(customer);
            },
            child: const Text('Detay'),
          ),
        ),
        const SizedBox(width: 8),

        // Contact Button
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              _contactCustomer(customer);
            },
            child: const Text('İletişim'),
          ),
        ),
        const SizedBox(width: 8),

        // Call Button
        IconButton(
          onPressed: () {
            _callCustomer(customer);
          },
          icon: const Icon(Icons.phone, color: Colors.green),
        ),

        // Message Button
        IconButton(
          onPressed: () {
            _messageCustomer(customer);
          },
          icon: const Icon(Icons.message, color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildEmptyCustomers() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz Müşteri Yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCustomersForFilter() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_alt_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Bu Filtreye Uygun Müşteri Yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilters(CustomerProvider customerProvider) {
    setState(() {});
  }

  void _addNewCustomer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Müşteri Ekle'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Yeni müşteri ekleme özelliği yakında eklenecek.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _viewCustomerDetails(CustomerModel customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Müşteri Detayı - ${customer.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('E-posta: ${customer.email}'),
            Text('Telefon: ${customer.phone}'),
            Text('Şehir: ${customer.city}'),
            const SizedBox(height: 8),
            Text('Toplam Sipariş: ${customer.totalOrders}'),
            Text('Toplam Harcama: ${customer.totalSpent}₺'),
            Text('Ortalama Puan: ${customer.rating}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _contactCustomer(CustomerModel customer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Telefon Ara'),
              onTap: () {
                Navigator.pop(context);
                _callCustomer(customer);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.blue),
              title: const Text('SMS Gönder'),
              onTap: () {
                Navigator.pop(context);
                _messageCustomer(customer);
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.orange),
              title: const Text('E-posta Gönder'),
              onTap: () {
                Navigator.pop(context);
                _emailCustomer(customer);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _callCustomer(CustomerModel customer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${customer.phone} aranıyor...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _messageCustomer(CustomerModel customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SMS Gönder'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('SMS gönderme özelliği yakında eklenecek.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _emailCustomer(CustomerModel customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('E-posta Gönder'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('E-posta gönderme özelliği yakında eklenecek.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}