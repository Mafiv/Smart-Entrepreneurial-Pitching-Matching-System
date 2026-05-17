import 'package:equatable/equatable.dart';

class EntrepreneurProfileEntity extends Equatable {
  final Map<String, dynamic> data;
  const EntrepreneurProfileEntity({required this.data});

  String get fullName => (data['fullName'] as String?) ?? '';
  String get companyName => (data['companyName'] as String?) ?? '';
  String get businessSector => (data['businessSector'] as String?) ?? '';
  String get businessStage => (data['businessStage'] as String?) ?? '';
  String? get description => (data['description'] as String?);

  // Verification document URLs
  String get nationalIdUrl => (data['nationalIdUrl'] as String?) ?? '';
  String get businessLicenseUrl => (data['businessLicenseUrl'] as String?) ?? '';
  String get tinNumber => (data['tinNumber'] as String?) ?? '';

  // Verification status
  String get status => (data['status'] as String?) ?? 'incomplete';
  String get rejectionReason => (data['rejectionReason'] as String?) ?? '';

  bool get isVerified => status == 'verified';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  bool get hasNationalId => nationalIdUrl.isNotEmpty;
  bool get hasBusinessLicense => businessLicenseUrl.isNotEmpty;
  bool get hasTin => tinNumber.isNotEmpty;

  @override
  List<Object?> get props => [data];
}

