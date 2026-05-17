import '../../domain/entities/pitch_detail_entity.dart';

/// Models for pitch detail - serializable versions of entities
class PitchDocumentModel {
  final String id;
  final String type;
  final String url;
  final String name;
  final String? mimeType;
  final DateTime? uploadedAt;

  const PitchDocumentModel({
    required this.id,
    required this.type,
    required this.url,
    required this.name,
    this.mimeType,
    this.uploadedAt,
  });

  factory PitchDocumentModel.fromJson(Map<String, dynamic> json) {
    return PitchDocumentModel(
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

  PitchDocument toPitchDocument() {
    return PitchDocument(
      id: id,
      type: type,
      url: url,
      name: name,
      mimeType: mimeType,
      uploadedAt: uploadedAt,
    );
  }
}

class EntrepreneurInfoModel {
  final String id;
  final String fullName;
  final String? email;
  final String? profilePicture;
  final String? companyName;
  final String? title;
  final String? bio;

  const EntrepreneurInfoModel({
    required this.id,
    required this.fullName,
    this.email,
    this.profilePicture,
    this.companyName,
    this.title,
    this.bio,
  });

  factory EntrepreneurInfoModel.fromJson(Map<String, dynamic> json) {
    return EntrepreneurInfoModel(
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

  EntrepreneurInfo toEntrepreneurInfo() {
    return EntrepreneurInfo(
      id: id,
      fullName: fullName,
      email: email,
      profilePicture: profilePicture,
      companyName: companyName,
      title: title,
      bio: bio,
    );
  }
}

class PitchFinancialsModel {
  final double? monthlyRecurringRevenue;
  final double? totalRevenue;
  final double? burnRate;
  final int? runway;
  final double? marketSize;
  final String? currency;

  const PitchFinancialsModel({
    this.monthlyRecurringRevenue,
    this.totalRevenue,
    this.burnRate,
    this.runway,
    this.marketSize,
    this.currency,
  });

  factory PitchFinancialsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PitchFinancialsModel();
    }
    return PitchFinancialsModel(
      monthlyRecurringRevenue:
          _toDouble(json['monthlyRecurringRevenue'] ?? json['mrr']),
      totalRevenue: _toDouble(json['totalRevenue'] ?? json['total_revenue']),
      burnRate: _toDouble(json['burnRate'] ?? json['burn_rate']),
      runway: _toInt(json['runway']),
      marketSize: _toDouble(json['marketSize'] ?? json['market_size']),
      currency: (json['currency']) as String?,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return null;
      }
    }
    if (value is num) return value.toInt();
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }
    if (value is num) return value.toDouble();
    return null;
  }

  PitchFinancials toPitchFinancials() {
    return PitchFinancials(
      monthlyRecurringRevenue: monthlyRecurringRevenue,
      totalRevenue: totalRevenue,
      burnRate: burnRate,
      runway: runway,
      marketSize: marketSize,
      currency: currency,
    );
  }
}

class AIMatchContextModel {
  final String? rationale;
  final double? overallScore;
  final Map<String, double>? scoreBreakdown;
  final String? summary;

  const AIMatchContextModel({
    this.rationale,
    this.overallScore,
    this.scoreBreakdown,
    this.summary,
  });
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }
    if (value is num) return value.toDouble();
    return null;
  }

  factory AIMatchContextModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AIMatchContextModel();
    }
    return AIMatchContextModel(
      rationale: (json['aiRationale'] ?? json['rationale']) as String?,
      overallScore: _toDouble(json['score'] ?? json['overall_score']),
      scoreBreakdown: json['scoreBreakdown'] != null
          ? Map<String, double>.from(
              (json['scoreBreakdown'] as Map).cast<String, dynamic>().map(
                    (k, v) => MapEntry(k, _toDouble(v) ?? 0.0),
                  ),
            )
          : null,
      summary: (json['summary']) as String?,
    );
  }

  AIMatchContext toAIMatchContext() {
    return AIMatchContext(
      rationale: rationale,
      overallScore: overallScore,
      scoreBreakdown: scoreBreakdown,
      summary: summary,
    );
  }
}

class PitchDetailModel extends PitchDetailEntity {
  const PitchDetailModel({
    required String id,
    required String title,
    required String summary,
    required String sector,
    required String stage,
    double? targetAmount,
    required String currency,
    required String problemStatement,
    required String solution,
    required String competitiveAdvantage,
    required PitchFinancials financials,
    required List<PitchDocument> documents,
    String? videoUrl,
    required EntrepreneurInfo entrepreneur,
    AIMatchContext? matchContext,
    double? aiScore,
    required bool isSaved,
    required DateTime submittedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          title: title,
          summary: summary,
          sector: sector,
          stage: stage,
          targetAmount: targetAmount,
          currency: currency,
          problemStatement: problemStatement,
          solution: solution,
          competitiveAdvantage: competitiveAdvantage,
          financials: financials,
          documents: documents,
          videoUrl: videoUrl,
          entrepreneur: entrepreneur,
          matchContext: matchContext,
          aiScore: aiScore,
          isSaved: isSaved,
          submittedAt: submittedAt,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory PitchDetailModel.fromJson(Map<String, dynamic> json) {
    // Handle nested problem object
    final problem = json['problem'] as Map<String, dynamic>?;
    final solution = json['solution'] as Map<String, dynamic>?;
    
    return PitchDetailModel(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      summary: (json['summary'] ?? '') as String,
      sector: (json['sector'] ?? '') as String,
      stage: (json['stage'] ?? '') as String,
      targetAmount: _toDouble(json['targetAmount'] ?? json['target_amount']),
      currency: (json['currency'] ?? 'ETB') as String,
      problemStatement: (json['problemStatement'] ??
          json['problem_statement'] ??
          problem?['statement'] ??
          '') as String,
      solution: (json['solution'] is String 
          ? json['solution'] as String
          : solution?['description'] ?? 
            json['solution'] ?? 
            '') as String,
      competitiveAdvantage: (json['competitiveAdvantage'] ??
          json['competitive_advantage'] ??
          solution?['competitiveAdvantage'] ??
          '') as String,
      financials: PitchFinancialsModel.fromJson(
        json['financials'] as Map<String, dynamic>?,
      ).toPitchFinancials(),
      documents: ((json['documents'] ?? []) as List)
          .whereType<Map<String, dynamic>>()
          .map((doc) => PitchDocumentModel.fromJson(doc).toPitchDocument())
          .toList(),
      videoUrl: (json['videoUrl'] ?? json['video_url']) as String?,
      entrepreneur: EntrepreneurInfoModel.fromJson(
        (json['entrepreneurId'] ?? json['entrepreneur'] ?? {})
            as Map<String, dynamic>,
      ).toEntrepreneurInfo(),
      matchContext: AIMatchContextModel.fromJson(
        json['matchContext'] as Map<String, dynamic>?,
      ).toAIMatchContext(),
      aiScore: _toDouble(json['aiScore'] ?? json['ai_score']),
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

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }
    if (value is num) return value.toDouble();
    return null;
  }

  factory PitchDetailModel.fromEntity(PitchDetailEntity entity) {
    return PitchDetailModel(
      id: entity.id,
      title: entity.title,
      summary: entity.summary,
      sector: entity.sector,
      stage: entity.stage,
      targetAmount: entity.targetAmount,
      currency: entity.currency,
      problemStatement: entity.problemStatement,
      solution: entity.solution,
      competitiveAdvantage: entity.competitiveAdvantage,
      financials: entity.financials,
      documents: entity.documents,
      videoUrl: entity.videoUrl,
      entrepreneur: entity.entrepreneur,
      matchContext: entity.matchContext,
      aiScore: entity.aiScore,
      isSaved: entity.isSaved,
      submittedAt: entity.submittedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
