import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../bloc/entrepreneur_profile_bloc.dart';
import '../../domain/entities/entrepreneur_profile_entity.dart';

class EntrepreneurProfilePage extends StatefulWidget {
  const EntrepreneurProfilePage({super.key});

  @override
  State<EntrepreneurProfilePage> createState() =>
      _EntrepreneurProfilePageState();
}

class _EntrepreneurProfilePageState extends State<EntrepreneurProfilePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  final _fullName = TextEditingController();
  final _companyName = TextEditingController();
  final _companyReg = TextEditingController();
  final _sector = TextEditingController();
  final _stage = TextEditingController();

  // Document file states
  File? _nationalIdFile;
  File? _businessLicenseFile;
  File? _tinCertificateFile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context
        .read<EntrepreneurProfileBloc>()
        .add(const EntrepreneurProfileChecked());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullName.dispose();
    _companyName.dispose();
    _companyReg.dispose();
    _sector.dispose();
    _stage.dispose();
    super.dispose();
  }

  void _submitCreate() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<EntrepreneurProfileBloc>().add(
          EntrepreneurProfileCreateRequested(
            fullName: _fullName.text.trim(),
            companyName: _companyName.text.trim(),
            companyRegistrationNumber: _companyReg.text.trim(),
            businessSector: _sector.text.trim(),
            businessStage: _stage.text.trim(),
          ),
        );
  }

  void _load() {
    context
        .read<EntrepreneurProfileBloc>()
        .add(const EntrepreneurProfileLoaded());
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text(
          'You will need to sign in again to access your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const SignOutRequested());
            },
            child: Text(
              'Sign out',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile({
    required Function(File) onPicked,
    List<String>? allowedExtensions,
  }) async {
    final result = await FilePicker.pickFiles(
      type: allowedExtensions != null
          ? FileType.custom
          : FileType.any,
      allowedExtensions: allowedExtensions,
    );
    if (result != null && result.files.single.path != null) {
      onPicked(File(result.files.single.path!));
    }
  }

  void _saveVerificationDocuments(EntrepreneurProfileEntity profile) {
    // Simplified implementation - just update with placeholder URLs
    // In a real implementation, you would upload files first
    String nationalIdUrl = profile.nationalIdUrl;
    String businessLicenseUrl = profile.businessLicenseUrl;
    String tinNumber = profile.tinNumber;

    if (_nationalIdFile != null) {
      nationalIdUrl = 'uploaded_national_id_url';
    }

    if (_businessLicenseFile != null) {
      businessLicenseUrl = 'uploaded_business_license_url';
    }

    if (_tinCertificateFile != null) {
      tinNumber = 'uploaded_tin_url';
    }

    context.read<EntrepreneurProfileBloc>().add(
          EntrepreneurProfileVerificationDocumentsUpdateRequested(
            nationalIdUrl: nationalIdUrl,
            businessLicenseUrl: businessLicenseUrl,
            tinNumber: tinNumber,
          ),
        );
  }

  Widget _logoutSection({EdgeInsets? margin}) {
    return Card(
      margin: margin,
      child: ListTile(
        leading: Icon(
          Icons.logout_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
        title: const Text('Sign out'),
        subtitle: Text(
          'Leave this session on this device',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
              ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: _confirmLogout,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              'Company & visibility',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: _confirmLogout,
            icon: Icon(
              Icons.logout_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child:
              BlocConsumer<EntrepreneurProfileBloc, EntrepreneurProfileState>(
            listener: (context, state) {
              final profile = state.profile;
              if (state.status == EntrepreneurProfileStatus.loaded &&
                  profile != null) {
                _fullName.text = profile.fullName;
                _companyName.text = profile.companyName;
                _sector.text = profile.businessSector;
                _stage.text = profile.businessStage;
              }
            },
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == EntrepreneurProfileStatus.error) {
                return ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    Card(
                      child: Padding(
                        padding: AppSpacing.paddingLg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: Theme.of(context)
                                  .colorScheme
                                  .error
                                  .withValues(alpha: 0.8),
                            ),
                            AppSpacing.gapMd,
                            Text(
                              state.error ?? 'We could not load your profile.',
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            AppSpacing.gapLg,
                            AppButton(text: 'Try again', onPressed: _load),
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.gapMd,
                    _logoutSection(),
                  ],
                );
              }

              if (state.status == EntrepreneurProfileStatus.missing ||
                  state.status == EntrepreneurProfileStatus.initial) {
                return _buildCreateForm();
              }

              if (state.profile == null) {
                return ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    Card(
                      child: Padding(
                        padding: AppSpacing.paddingMd,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Profile found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            AppSpacing.gapSm,
                            Text(
                              'Load your saved details to view or edit them.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                            ),
                            AppSpacing.gapLg,
                            AppButton(
                              text: 'Load profile',
                              onPressed: _load,
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.gapMd,
                    _logoutSection(),
                  ],
                );
              }

              return SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: _buildView(state),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          Text(
            'Tell investors about your venture',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                ),
          ),
          AppSpacing.gapXs,
          Text(
            'Create your entrepreneur profile',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          AppSpacing.gapMd,
          Material(
            color: AppColors.card,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: AppSpacing.paddingMd,
              child: Column(
                children: [
                  AppTextField(
                    label: 'Full Name',
                    controller: _fullName,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  AppSpacing.gapMd,
                  AppTextField(
                    label: 'Company Name',
                    controller: _companyName,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  AppSpacing.gapMd,
                  AppTextField(
                    label: 'Company Registration Number',
                    controller: _companyReg,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  AppSpacing.gapMd,
                  AppTextField(
                    label: 'Business Sector',
                    controller: _sector,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  AppSpacing.gapMd,
                  AppTextField(
                    label: 'Business Stage',
                    hint: 'idea / mvp / early-revenue / scaling',
                    controller: _stage,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.gapLg,
          AppButton(text: 'Create profile', onPressed: _submitCreate),
          AppSpacing.gapXl,
          _logoutSection(),
        ],
      ),
    );
  }

  Widget _buildView(EntrepreneurProfileState state) {
    final profile = state.profile!;
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  profile.fullName.isNotEmpty
                      ? profile.fullName[0].toUpperCase()
                      : 'E',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName.isNotEmpty
                          ? profile.fullName
                          : 'Founder',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.companyName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapMd,
        TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: AppColors.mutedForeground,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'Personal Info'),
            Tab(text: 'Verification'),
          ],
        ),
        AppSpacing.gapMd,
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPersonalInfoTab(profile, theme),
              _buildVerificationTab(profile, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoTab(EntrepreneurProfileEntity profile, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        Text(
          'Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        AppSpacing.gapMd,
        Material(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _detailRow(
                    theme, Icons.person_outline, 'Full name', profile.fullName),
                const Divider(height: AppSpacing.lg, color: AppColors.border),
                _detailRow(theme, Icons.business_outlined, 'Company',
                    profile.companyName),
                const Divider(height: AppSpacing.lg, color: AppColors.border),
                _detailRow(theme, Icons.category_outlined, 'Sector',
                    profile.businessSector),
                const Divider(height: AppSpacing.lg, color: AppColors.border),
                _detailRow(theme, Icons.timeline_outlined, 'Stage',
                    profile.businessStage),
              ],
            ),
          ),
        ),
        AppSpacing.gapMd,
        Text(
          'Edit profile',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        AppSpacing.gapXs,
        Text(
          'Update your info and tap Save changes.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
              ),
        ),
        AppSpacing.gapMd,
        Material(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Full name',
                  controller: _fullName,
                  prefixIcon: Icons.person_outline,
                ),
                AppSpacing.gapMd,
                AppTextField(
                  label: 'Company name',
                  controller: _companyName,
                  prefixIcon: Icons.business_outlined,
                ),
                AppSpacing.gapMd,
                AppTextField(
                  label: 'Business sector',
                  controller: _sector,
                  prefixIcon: Icons.category_outlined,
                ),
                AppSpacing.gapMd,
                AppTextField(
                  label: 'Business stage',
                  hint: 'idea / mvp / early-revenue / scaling',
                  controller: _stage,
                  prefixIcon: Icons.timeline_outlined,
                ),
              ],
            ),
          ),
        ),
        AppSpacing.gapMd,
        AppButton(
          text: 'Save changes',
          onPressed: () {
            context.read<EntrepreneurProfileBloc>().add(
                  EntrepreneurProfileUpdateRequested({
                    'fullName': _fullName.text.trim().isEmpty
                        ? profile.fullName
                        : _fullName.text.trim(),
                    'companyName': _companyName.text.trim().isEmpty
                        ? profile.companyName
                        : _companyName.text.trim(),
                    'businessStage': _stage.text.trim().isEmpty
                        ? profile.businessStage
                        : _stage.text.trim(),
                  }),
                );
          },
        ),
        AppSpacing.gapXl,
        _logoutSection(),
      ],
    );
  }

  Widget _detailRow(
      ThemeData theme, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.mutedForeground),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.mutedForeground,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? '—' : value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationTab(EntrepreneurProfileEntity profile, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        // Verification Status Card
        Card(
          color: profile.isVerified
              ? const Color(0xFFECFDF5)
              : profile.isPending
                  ? const Color(0xFFEFF6FF)
                  : const Color(0xFFFFFBEB),
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      profile.isVerified
                          ? Icons.verified
                          : profile.isPending
                              ? Icons.pending
                              : Icons.warning_amber_rounded,
                      color: profile.isVerified
                          ? const Color(0xFF10B981)
                          : profile.isPending
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFFF59E0B),
                    ),
                    AppSpacing.gapSm,
                    Text(
                      profile.isVerified
                          ? 'Verified'
                          : profile.isPending
                              ? 'Under Review'
                              : 'Incomplete',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: profile.isVerified
                            ? const Color(0xFF10B981)
                            : profile.isPending
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapSm,
                Text(
                  profile.isVerified
                      ? 'Your identity and business documents have been verified.'
                      : profile.isPending
                          ? 'Your documents are being reviewed by an administrator.'
                          : 'Complete your verification to access all features.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                if (profile.rejectionReason.isNotEmpty) ...[
                  AppSpacing.gapSm,
                  Container(
                    padding: AppSpacing.paddingSm,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      profile.rejectionReason,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        AppSpacing.gapLg,

        // Document Upload Section
        Text(
          'Identity Verification',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        AppSpacing.gapSm,
        Text(
          'Upload a valid government-issued ID (National ID, Driving License, or Passport).',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        AppSpacing.gapMd,
        _DocumentUploadCard(
          label: 'Government ID',
          description: 'National ID, Driving License, or Passport',
          file: _nationalIdFile,
          existingUrl: profile.nationalIdUrl,
          onPick: () => _pickFile(
            onPicked: (file) => setState(() => _nationalIdFile = file),
            allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          ),
          onRemove: () => setState(() => _nationalIdFile = null),
        ),
        AppSpacing.gapLg,

        Text(
          'Business Verification',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        AppSpacing.gapSm,
        Text(
          'Upload your business license and TIN certificate.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        AppSpacing.gapMd,
        _DocumentUploadCard(
          label: 'Business License',
          description: 'Certificate of incorporation or business license',
          file: _businessLicenseFile,
          existingUrl: profile.businessLicenseUrl,
          onPick: () => _pickFile(
            onPicked: (file) => setState(() => _businessLicenseFile = file),
            allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          ),
          onRemove: () => setState(() => _businessLicenseFile = null),
        ),
        AppSpacing.gapMd,
        _DocumentUploadCard(
          label: 'TIN Certificate',
          description: 'Tax Identification Number certificate',
          file: _tinCertificateFile,
          existingUrl: profile.tinNumber,
          onPick: () => _pickFile(
            onPicked: (file) => setState(() => _tinCertificateFile = file),
            allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          ),
          onRemove: () => setState(() => _tinCertificateFile = null),
        ),
        AppSpacing.gapLg,

        // Save Button
        AppButton(
          text: 'Save Documents',
          onPressed: () => _saveVerificationDocuments(profile),
        ),
      ],
    );
  }
}

class _DocumentUploadCard extends StatelessWidget {
  final String label;
  final String description;
  final File? file;
  final String? existingUrl;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _DocumentUploadCard({
    required this.label,
    required this.description,
    required this.file,
    required this.existingUrl,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFile = file != null;
    final hasExisting = existingUrl != null && existingUrl!.isNotEmpty;
    final isComplete = hasFile || hasExisting;

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isComplete
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : AppColors.border,
          width: 2,
        ),
      ),
      child: hasFile
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file!.path.split('/').last,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Ready to upload',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                  color: AppColors.mutedForeground,
                ),
              ],
            )
          : hasExisting
              ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Uploaded',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: onPick,
                      child: const Text('Replace'),
                    ),
                  ],
                )
              : InkWell(
                  onTap: onPick,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.mutedForeground.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: const Icon(
                          Icons.cloud_upload_outlined,
                          color: AppColors.mutedForeground,
                          size: 20,
                        ),
                      ),
                      AppSpacing.gapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.mutedForeground,
                      ),
                    ],
                  ),
                ),
    );
  }
}
