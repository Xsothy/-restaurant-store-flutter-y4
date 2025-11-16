import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:restaurant_store_flutter/src/core/constants/app_constants.dart';
import 'package:restaurant_store_flutter/src/core/routing/app_router.dart';
import 'package:restaurant_store_flutter/src/core/utils/snackbar_helper.dart';
import 'package:restaurant_store_flutter/src/features/config/providers/server_config_provider.dart';
import 'package:restaurant_store_flutter/src/presentation/widgets/custom_button.dart';
import 'package:restaurant_store_flutter/src/presentation/widgets/custom_text_field.dart';

class ServerConfigScreen extends StatefulWidget {
  const ServerConfigScreen({super.key});

  @override
  State<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends State<ServerConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<ServerConfigProvider>();
      _controller.text = provider.baseUrl;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validateUrl(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Base URL is required';
    }
    final candidate = (trimmed.startsWith('http://') || trimmed.startsWith('https://'))
        ? trimmed
        : 'http://$trimmed';
    final uri = Uri.tryParse(candidate);
    if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  Future<void> _handleSave(ServerConfigProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    final saved = await provider.saveBaseUrl(_controller.text);
    if (saved && mounted) {
      SnackbarHelper.showTopToast(
        context,
        'Server configured successfully. You can now continue.',
      );
      NavigationHelper.navigateToSplash(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ServerConfigProvider>(
          builder: (context, provider, _) {
            if (!provider.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Icon(
                    Icons.cloud_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Connect to your backend',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the base URL of the demo backend server running on your local network.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard(context),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: CustomTextField(
                      controller: _controller,
                      label: 'Backend Base URL',
                      hint: 'http://192.168.1.10:8080/api',
                      keyboardType: TextInputType.url,
                      prefixIcon: const Icon(Icons.link),
                      validator: _validateUrl,
                      onChanged: (_) => provider.clearError(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (provider.errorMessage != null)
                    Text(
                      provider.errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  if (provider.errorMessage != null) const SizedBox(height: 12),
                  CustomButton(
                    text: provider.isConfigured ? 'Update & Continue' : 'Save & Continue',
                    onPressed: provider.isSaving ? null : () => _handleSave(provider),
                    isLoading: provider.isSaving,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tip: Make sure your phone/emulator can reach the backend server over the same Wi-Fi network.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
                  ),
                  if (provider.isConfigured) ...[
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: provider.isSaving ? null : provider.resetConfiguration,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Use default from .env'),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Why is this required?',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This demo runs against a locally hosted backend. Provide the API base URL (including /api) so the app '
            'can send requests and receive real-time updates.',
          ),
        ],
      ),
    );
  }
}
