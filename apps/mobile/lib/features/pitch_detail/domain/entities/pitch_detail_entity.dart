import 'package:equatable/equatable.dart';

/// Represents a pitch document (PDF, image, etc.)
class PitchDocument extends Equatable {
  final String id;
  final String type; // 'pitch_deck', 'financial_model', 'business_plan', etc.
  final String url;
  final String name;
  final String? mimeType;
  final DateTime? uploadedAt;

  const PitchDocument({
    required this.id,
    required this.type,
    required this.url,
    required this.name,
    this.mimeType,
    this.uploadedAt,
  });

  factory PitchDocument.fromJson(Map<String, dynamic> json) {
    return PitchDocument(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      type: (json['type'] ?? '') as String,
      url: (json['url'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      mimeType: (json['mimeType'] ?? json['mime_type']) as String?,
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, type, url, name, mimeType, uploadedAt];
}

/// Represents entrepreneur info in pitch detail
class EntrepreneurInfo extends Equatable {
  final String id;
  final String fullName;
  final String? email;
  final String? profilePicture;
  final String? companyName;
  final String? title;
  final String? bio;

  const EntrepreneurInfo({
    required this.id,
    required this.fullName,
    this.email,
    this.profilePicture,
    this.companyName,
    this.title,
    this.bio,
  });

  factory EntrepreneurInfo.fromJson(Map<String, dynamic> json) {
    return EntrepreneurInfo(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      fullName: (json['fullName'] ?? json['full_name'] ?? '') as String,
      email: (json['email']) as String?,
      profilePicture:
          (json['profilePicture'] ?? json['profile_picture']) as String?,
      companyName: (json['companyName'] ?? json['company_name']) as String?,
      title: (json['title'] ?? json['position']) as String?,
      bio: (json['bio'] ?? json['description']) as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, fullName, email, profilePicture, companyName, title, bio];
}

/// Financial information for the pitch
class PitchFinancials extends Equatable {
  final double? monthlyRecurringRevenue;
  final double? totalRevenue;
  final double? burnRate;
  final int? runway;
  final double? marketSize;
  final String? currency;

  const PitchFinancials({
    this.monthlyRecurringRevenue,
    this.totalRevenue,
    this.burnRate,
    this.runway,
    this.marketSize,
    this.currency,
  });

  factory PitchFinancials.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PitchFinancials();
    }
    return PitchFinancials(
      monthlyRecurringRevenue:
          (json['monthlyRecurringRevenue'] ?? json['mrr']) as double?,
      totalRevenue: (json['totalRevenue'] ?? json['total_revenue']) as double?,
      burnRate: (json['burnRate'] ?? json['burn_rate']) as double?,
      runway: (json['runway']) as int?,
      marketSize: (json['marketSize'] ?? json['market_size']) as double?,
      currency: (json['currency']) as String?,
    );
  }

  @override
  List<Object?> get props => [
        monthlyRecurringRevenue,
        totalRevenue,
        burnRate,
        runway,
        marketSize,
        currency
      ];
}

/// AI match context for investor views
class AIMatchContext extends Equatable {
  final String? rationale;
  final double? overallScore;
  final Map<String, double>? scoreBreakdown;
  final String? summary;

  const AIMatchContext({
    this.rationale,
    this.overallScore,
    this.scoreBreakdown,
    this.summary,
  });

  factory AIMatchContext.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AIMatchContext();
    }
    return AIMatchContext(
      rationale: (json['aiRationale'] ?? json['rationale']) as String?,
      overallScore: (json['score'] ?? json['overall_score']) as double?,
      scoreBreakdown: json['scoreBreakdown'] != null
          ? Map<String, double>.from(
              (json['scoreBreakdown'] as Map).cast<String, dynamic>().map(
                    (k, v) => MapEntry(k, (v as num).toDouble()),
                  ),
            )
          : null,
      summary: (json['summary']) as String?,
    );
  }

  @override
  List<Object?> get props => [rationale, overallScore, scoreBreakdown, summary];
}

/// Complete pitch detail entity
class PitchDetailEntity extends Equatable {
  final String id;
  final String title;
  final String summary;
  final String sector;
  final String stage;
  final double? targetAmount;
  final String currency;
  final String problemStatement;
  final String solution;
  final String competitiveAdvantage;
  final PitchFinancials financials;
  final List<PitchDocument> documents;
  final String? videoUrl;
  final EntrepreneurInfo entrepreneur;
  final AIMatchContext? matchContext;
  final double? aiScore;
  final bool isSaved;
  final DateTime submittedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PitchDetailEntity({
    required this.id,
    required this.title,
    required this.summary,
    required this.sector,
    required this.stage,
    this.targetAmount,
    required this.currency,
    required this.problemStatement,
    required this.solution,
    required this.competitiveAdvantage,
    required this.financials,
    required this.documents,
    this.videoUrl,
    required this.entrepreneur,
    this.matchContext,
    this.aiScore,
    required this.isSaved,
    required this.submittedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PitchDetailEntity.fromJson(Map<String, dynamic> json) {
    return PitchDetailEntity(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      summary: (json['summary'] ?? '') as String,
      sector: (json['sector'] ?? '') as String,
      stage: (json['stage'] ?? '') as String,
      targetAmount: (json['targetAmount'] ?? json['target_amount']) as double?,
      currency: (json['currency'] ?? 'ETB') as String,
      problemStatement: (json['problemStatement'] ??
          json['problem_statement'] ??
          '') as String,
      solution: (json['solution'] ?? '') as String,
      competitiveAdvantage: (json['competitiveAdvantage'] ??
          json['competitive_advantage'] ??
          '') as String,
      financials: PitchFinancials.fromJson(
        json['financials'] as Map<String, dynamic>?,
      ),
      documents: ((json['documents'] ?? []) as List)
          .whereType<Map<String, dynamic>>()
          .map((doc) => PitchDocument.fromJson(doc))
          .toList(),
      videoUrl: (json['videoUrl'] ?? json['video_url']) as String?,
      entrepreneur: EntrepreneurInfo.fromJson(
        (json['entrepreneurId'] ?? json['entrepreneur'] ?? {})
            as Map<String, dynamic>,
      ),
      matchContext: AIMatchContext.fromJson(
        json['matchContext'] as Map<String, dynamic>?,
      ),
      aiScore: (json['aiScore'] ?? json['ai_score']) as double?,
      isSaved: (json['isSaved'] ?? json['is_saved'] ?? false) as bool,
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        summary,
        sector,
        stage,
        targetAmount,
        currency,
        problemStatement,
        solution,
        competitiveAdvantage,
        financials,
        documents,
        videoUrl,
        entrepreneur,
        matchContext,
        aiScore,
        isSaved,
        submittedAt,
        createdAt,
        updatedAt,
      ];
}
