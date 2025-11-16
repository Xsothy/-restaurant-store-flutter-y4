import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../utils/routes.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final auth = context.read<AuthProvider>();
    final user = auth.user;

    final name = user?.fullName ?? '';
    final email = user?.email ?? '';
    final phone = user?.phone ?? '';
    final address = user?.address?.fullAddress ?? '';

    _nameController = TextEditingController(text: name);
    _emailController = TextEditingController(text: email);
    _phoneController = TextEditingController(text: phone);
    _addressController = TextEditingController(text: address);
    _initialized = true;
  }

  @override
  void dispose() {
    if (_initialized) {
      _nameController.dispose();
      _emailController.dispose();
      _phoneController.dispose();
      _addressController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
          ),
          body: user == null
              ? const Center(child: Text('No user data available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: _nameController,
                          hint: 'Full name',
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (value) {
                            final text = (value ?? '').trim();
                            if (text.isEmpty) {
                              return AppConstants.nameRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _emailController,
                          hint: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (value) {
                            final text = (value ?? '').trim();
                            if (text.isEmpty) {
                              return AppConstants.emailRequired;
                            }
                            if (!text.contains('@')) {
                              return AppConstants.emailInvalid;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _phoneController,
                          hint: 'Phone number',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          validator: (value) =>
                              authProvider.validatePhone((value ?? '').trim()),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _addressController,
                          hint: 'Address',
                          maxLines: 3,
                          prefixIcon: const Icon(Icons.location_on_outlined),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Save changes',
                          width: double.infinity,
                          isLoading: authProvider.isLoading,
                          onPressed: authProvider.isLoading
                              ? null
                              : () => _handleSave(authProvider),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Future<void> _handleSave(AuthProvider authProvider) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      SnackbarHelper.showTopToast(
        context,
        'Profile updated successfully',
      );
      NavigationHelper.pop(context);
    } else {
      final message = authProvider.errorMessage ?? AppConstants.generalError;
      SnackbarHelper.showTopToast(
        context,
        message,
        isError: true,
      );
    }
  }
}
