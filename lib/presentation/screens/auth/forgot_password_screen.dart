import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_momento/presentation/providers/auth_provider.dart';
import 'package:photo_momento/presentation/widgets/custom_text_field.dart';
import 'package:photo_momento/presentation/widgets/loading_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Şifremi Unuttum'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Header Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset,
                  color: Colors.blue,
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'Şifre Sıfırlama',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                _emailSent
                    ? 'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi'
                    : 'Şifrenizi sıfırlamak için e-posta adresinizi girin',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              if (!_emailSent) _buildResetForm(authProvider),
              if (_emailSent) _buildSuccessMessage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResetForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          CustomTextField(
            controller: _emailController,
            labelText: 'E-posta',
            prefixIcon: const Icon(Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lütfen e-posta adresinizi girin';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Lütfen geçerli bir e-posta adresi girin';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Error Message
          if (authProvider.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authProvider.error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 16,
                    ),
                    onPressed: () {
                      authProvider.clearError();
                    },
                  ),
                ],
              ),
            ),

          if (authProvider.error != null) const SizedBox(height: 16),

          // Reset Button
          LoadingButton(
            isLoading: authProvider.isLoading,
            onPressed: () => _resetPassword(authProvider),
            child: const Text(
              'Şifre Sıfırlama Bağlantısı Gönder',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        // Success Icon
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 64,
        ),

        const SizedBox(height: 24),

        // Success Message
        Text(
          'E-postanızı kontrol edin',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Şifre sıfırlama bağlantısı ${_emailController.text} adresine gönderildi. '
              'E-postanızı kontrol edin ve bağlantıya tıklayarak şifrenizi sıfırlayın.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Back to Login Button
        LoadingButton(
          isLoading: false,
          onPressed: () {
            context.push('/login');
          },
          child: const Text(
            'Giriş Sayfasına Dön',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Resend Link
        TextButton(
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          child: const Text(
            'Bağlantıyı Tekrar Gönder',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _resetPassword(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      await authProvider.resetPassword(_emailController.text.trim());

      if (authProvider.error == null) {
        setState(() {
          _emailSent = true;
        });
      }
    }
  }
}