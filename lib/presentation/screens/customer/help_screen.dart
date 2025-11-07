import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_momento/presentation/widgets/custom_app_bar.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'Sipariş nasıl verilir?',
      answer: 'Sipariş vermek için:\n\n1. "Yeni Sipariş" butonuna tıklayın\n2. Ürün boyutunu ve kağıt tipini seçin\n3. Fotoğraflarınızı yükleyin\n4. Adet belirleyin\n5. Sepete ekleyin\n6. Ödeme yaparak siparişi tamamlayın',
      category: 'siparis',
    ),
    FAQItem(
      question: 'Hangi fotoğraf formatları destekleniyor?',
      answer: 'Desteklenen formatlar:\n\n• JPEG/JPG\n• PNG\n• WEBP\n\nMaksimum dosya boyutu: 10MB\nÖnerilen çözünürlük: 300 DPI ve üzeri',
      category: 'fotograf',
    ),
    FAQItem(
      question: 'Teslimat süresi ne kadar?',
      answer: 'Standart teslimat süreleri:\n\n• İstanbul: 1-2 iş günü\n• Diğer şehirler: 2-4 iş günü\n• Özel baskılar: 3-5 iş günü\n\nTeslimat süreleri hafta içi iş günleri için geçerlidir.',
      category: 'teslimat',
    ),
    FAQItem(
      question: 'Ücretsiz kargo şartı nedir?',
      answer: '150₺ ve üzeri alışverişlerde kargo ücretsizdir.\n\n150₺ altındaki siparişlerde standart kargo ücreti 15₺\'dir.',
      category: 'teslimat',
    ),
    FAQItem(
      question: 'İade ve değişim politikası nedir?',
      answer: 'İade ve değişim koşulları:\n\n• Baskı hatası varsa: Ücretsiz yeniden baskı\n• Müşteri hatası: İade kabul edilmez\n• Hasarlı ürün: 48 saat içinde bildirim\n• İade süresi: 14 gün\n\nBaskılı fotoğraflar kişiye özel olduğundan, müşteri hatasıyla yapılan siparişler iade edilemez.',
      category: 'iade',
    ),
    FAQItem(
      question: 'Ödeme yöntemleri nelerdir?',
      answer: 'Kabul edilen ödeme yöntemleri:\n\n• Kredi/Banka kartı\n• Kapıda nakit ödeme\n• Havale/EFT\n\nTüm kart işlemleri 256-bit SSL ile korunmaktadır.',
      category: 'odeme',
    ),
    FAQItem(
      question: 'Siparişimi nasıl iptal ederim?',
      answer: 'Sipariş iptali için:\n\n1. "Siparişlerim" sayfasına gidin\n2. İptal etmek istediğiniz siparişi seçin\n3. "Siparişi İptal Et" butonuna tıklayın\n\nNot: Baskı sürecine girmiş siparişler iptal edilemez.',
      category: 'siparis',
    ),
    FAQItem(
      question: 'Fotoğraf kalitesi nasıl olmalı?',
      answer: 'İyi baskı için öneriler:\n\n• Yüksek çözünürlük (300 DPI+)\n• Net ve odaklanmış fotoğraflar\n• Yeterli aydınlatma\n• Doğal renkler\n• Sıkıştırılmamış dosyalar\n\nDüşük kaliteli fotoğraflar baskıda kötü sonuç verebilir.',
      category: 'fotograf',
    ),
  ];

  List<FAQItem> _filteredItems = [];
  String _selectedCategory = 'tumu';

  @override
  void initState() {
    super.initState();
    _filteredItems = _faqItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Yardım Merkezi',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Search and Categories
          _buildSearchSection(),

          // FAQ List
          Expanded(
            child: _buildFAQList(),
          ),

          // Contact Section
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Sorunuzu arayın...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('Tümü', 'tumu'),
                _buildCategoryChip('Sipariş', 'siparis'),
                _buildCategoryChip('Fotoğraf', 'fotograf'),
                _buildCategoryChip('Teslimat', 'teslimat'),
                _buildCategoryChip('Ödeme', 'odeme'),
                _buildCategoryChip('İade', 'iade'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String category) {
    final isSelected = _selectedCategory == category;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
            _applyFilters();
          });
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.blue.shade100,
        checkmarkColor: Colors.blue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue : Colors.grey.shade700,
        ),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildFAQList() {
    if (_filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Sonuç Bulunamadı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Arama kriterlerinize uygun soru bulunamadı'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        return _buildFAQItem(_filteredItems[index]);
      },
    );
  }

  Widget _buildFAQItem(FAQItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          item.question,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              item.answer,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Hala yardıma mı ihtiyacınız var?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Destek ekibimizle iletişime geçin',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _callSupport,
                  icon: const Icon(Icons.phone),
                  label: const Text('Ara'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _sendEmail,
                  icon: const Icon(Icons.email),
                  label: const Text('E-posta'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _createSupportTicket,
            icon: const Icon(Icons.support_agent),
            label: const Text('Destek Talebi Oluştur'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredItems = _faqItems.where((item) {
        final matchesCategory = _selectedCategory == 'tumu' || item.category == _selectedCategory;
        final matchesSearch = query.isEmpty ||
            item.question.toLowerCase().contains(query) ||
            item.answer.toLowerCase().contains(query);

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _callSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Müşteri Hizmetleri'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Telefon: +90 212 123 4567'),
            SizedBox(height: 8),
            Text('Çalışma Saatleri:'),
            Text('Pazartesi - Cuma: 09:00 - 18:00'),
            Text('Cumartesi: 10:00 - 16:00'),
            Text('Pazar: Kapalı'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Here you would implement actual phone call
            },
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }

  void _sendEmail() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('E-posta Desteği'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('E-posta: destek@photomomento.com'),
            SizedBox(height: 8),
            Text('Ortalama yanıt süresi: 2 saat'),
            SizedBox(height: 8),
            Text('Lütfen sipariş numaranızı ve sorunuzu detaylı bir şekilde belirtin.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Here you would implement email sending
            },
            child: const Text('E-posta Gönder'),
          ),
        ],
      ),
    );
  }

  void _createSupportTicket() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Destek Talebi'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Destek talebi özelliği yakında eklenecek.'),
            SizedBox(height: 8),
            Text('Şu an için lütfen telefon veya e-posta ile iletişime geçin.'),
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

class FAQItem {
  final String question;
  final String answer;
  final String category;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}