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
  final _companyDescription = TextEditingController();

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
    _companyDescription.dispose();
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
    // Save company details first
    final patch = <String, dynamic>{};
    if (_companyName.text.trim().isNotEmpty &&
        _companyName.text.trim() != profile.companyName) {
      patch['companyName'] = _companyName.text.trim();
    }
    if (_companyDescription.text.trim().isNotEmpty &&
        _companyDescription.text.trim() != (profile.description ?? '')) {
      patch['description'] = _companyDescription.text.trim();
    }
    if (patch.isNotEmpty) {
      context.read<EntrepreneurProfileBloc>().add(
            EntrepreneurProfileUpdateRequested(patch),
          );
    }

    // Upload documents
    if (_nationalIdFile != null) {
      context.read<EntrepreneurProfileBloc>().add(
            EntrepreneurProfileKycUploadRequested(
              file: _nationalIdFile!,
              type: 'nationalId',
            ),
          );
    }
    if (_businessLicenseFile != null) {
      context.read<EntrepreneurProfileBloc>().add(
            EntrepreneurProfileKycUploadRequested(
              file: _businessLicenseFile!,
              type: 'businessLicense',
            ),
          );
    }
    if (_tinCertificateFile != null) {
      context.read<EntrepreneurProfileBloc>().add(
            EntrepreneurProfileKycUploadRequested(
              file: _tinCertificateFile!,
              type: 'tinCertificate',
            ),
          );
    }
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
                _companyDescription.text = profile.description ?? '';
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

              return _buildView(state);
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
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        profile.fullName,
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
          _buildPersonalInfoTab(profile, theme),
          AppSpacing.gapLg,
          _buildVerificationTab(profile, theme),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab(EntrepreneurProfileEntity profile, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
    // Get auth bloc to check email verification status
    final authState = context.watch<AuthBloc>().state;
    final emailVerified = authState.isAuthenticated && authState.user?.emailVerified == true;

    final hasGovId = _nationalIdFile != null || profile.nationalIdUrl.isNotEmpty;
    final hasBusinessDocs = (_businessLicenseFile != null || profile.businessLicenseUrl.isNotEmpty) &&
                           (_tinCertificateFile != null || profile.tinNumber.isNotEmpty);

    final steps = [
      {'label': 'Email Verified', 'done': emailVerified},
      {'label': 'Government ID', 'done': hasGovId},
      {'label': 'Business Documents', 'done': hasBusinessDocs},
      {'label': 'Admin Approved', 'done': profile.isVerified},
    ];
    final completedCount = steps.where((s) => s['done'] as bool).length;
    final progress = (completedCount / steps.length) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Verification Progress Card
        Card(
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shield,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    AppSpacing.gapSm,
                    Text(
                      'Verification Status',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: profile.isVerified
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : profile.isPending
                                ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
                                : AppColors.mutedForeground.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: profile.isVerified
                              ? const Color(0xFF10B981).withValues(alpha: 0.2)
                              : profile.isPending
                                  ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
                                  : AppColors.border,
                        ),
                      ),
                      child: Text(
                        profile.isVerified
                            ? '✓ Verified'
                            : profile.isPending
                                ? '⏳ Under Review'
                                : 'Incomplete',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: profile.isVerified
                              ? const Color(0xFF10B981)
                              : profile.isPending
                                  ? const Color(0xFF3B82F6)
                                  : AppColors.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapMd,
                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        Text(
                          '${progress.round()}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.gapXs,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapMd,
                // Steps
                ...steps.map((step) {
                  final done = step['done'] as bool;
                  final label = step['label'] as String;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        if (done)
                          Icon(
                            Icons.check_circle,
                            color: const Color(0xFF10B981),
                            size: 16,
                          )
                        else if (profile.isPending && label == 'Admin Approved')
                          Icon(
                            Icons.access_time,
                            color: const Color(0xFF3B82F6),
                            size: 16,
                          )
                        else
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.mutedForeground.withValues(alpha: 0.2),
                                width: 2,
                              ),
                            ),
                          ),
                        AppSpacing.gapSm,
                        Text(
                          label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: done ? theme.colorScheme.onSurface : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (profile.rejectionReason.isNotEmpty) ...[
                  AppSpacing.gapSm,
                  Container(
                    padding: AppSpacing.paddingSm,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: const Color(0xFFDC2626),
                          size: 16,
                        ),
                        AppSpacing.gapSm,
                        Expanded(
                          child: Text(
                            profile.rejectionReason,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        AppSpacing.gapLg,

        // Identity Verification
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
          label: 'Government-Issued ID',
          description: 'PDF or Image · Max 10MB',
          file: _nationalIdFile,
          existingUrl: profile.nationalIdUrl,
          onPick: () => _pickFile(
            onPicked: (file) => setState(() => _nationalIdFile = file),
            allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          ),
          onRemove: () => setState(() => _nationalIdFile = null),
          required: true,
        ),
        AppSpacing.gapLg,

        // Business Documents
        Text(
          'Business Documents',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        AppSpacing.gapSm,
        Text(
          'Upload your business registration certificate and TIN certificate.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        AppSpacing.gapMd,
        _DocumentUploadCard(
          label: 'Business Registration Certificate',
          description: 'PDF or Image · Certificate of Incorporation',
          file: _businessLicenseFile,
          existingUrl: profile.businessLicenseUrl,
          onPick: () => _pickFile(
            onPicked: (file) => setState(() => _businessLicenseFile = file),
            allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          ),
          onRemove: () => setState(() => _businessLicenseFile = null),
          required: true,
        ),
        AppSpacing.gapMd,
        _DocumentUploadCard(
          label: 'TIN Certificate',
          description: 'PDF or Image · Tax Identification Number',
          file: _tinCertificateFile,
          existingUrl: profile.tinNumber,
          onPick: () => _pickFile(
            onPicked: (file) => setState(() => _tinCertificateFile = file),
            allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          ),
          onRemove: () => setState(() => _tinCertificateFile = null),
          required: true,
        ),
        AppSpacing.gapLg,

        // Company Details
        Text(
          'Company Details',
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
                AppTextField(
                  label: 'Company Name',
                  controller: _companyName,
                  prefixIcon: Icons.business_outlined,
                  enabled: !profile.isVerified,
                ),
                AppSpacing.gapMd,
                AppTextField(
                  label: 'Brief Description',
                  controller: _companyDescription,
                  prefixIcon: Icons.description_outlined,
                  enabled: !profile.isVerified,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        AppSpacing.gapLg,

        // Save Button
        if (!profile.isVerified)
          AppButton(
            text: profile.status == 'unverified'
                ? 'Save & Submit for Review'
                : 'Save Changes',
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
  final bool required;

  const _DocumentUploadCard({
    required this.label,
    required this.description,
    required this.file,
    required this.existingUrl,
    required this.onPick,
    required this.onRemove,
    this.required = false,
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
                        child: Icon(
                          Icons.upload_file_outlined,
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
                      if (required)
                        Text(
                          '*',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      AppSpacing.gapSm,
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.mutedForeground,
                      ),
                    ],
                  ),
                ),
        );
      }
    }
