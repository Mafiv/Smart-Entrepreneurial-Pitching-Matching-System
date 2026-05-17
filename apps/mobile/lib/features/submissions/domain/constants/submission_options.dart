/// Static option lists for the entrepreneur pitch creation flow.
///
/// Mirrors `apps/web/src/lib/validations/submission.ts` so that mobile and
/// web users see the same sectors, stages and document categories.
library;

class OptionItem {
  final String value;
  final String label;
  const OptionItem(this.value, this.label);
}

class DocCategory {
  final String value;
  final String label;
  final bool required;
  const DocCategory({
    required this.value,
    required this.label,
    required this.required,
  });
}

class SubmissionOptions {
  SubmissionOptions._();

  static const List<OptionItem> sectors = [
    OptionItem('technology', 'Technology'),
    OptionItem('healthcare', 'Healthcare'),
    OptionItem('fintech', 'Fintech'),
    OptionItem('education', 'Education'),
    OptionItem('agriculture', 'Agriculture'),
    OptionItem('energy', 'Energy'),
    OptionItem('real_estate', 'Real Estate'),
    OptionItem('manufacturing', 'Manufacturing'),
    OptionItem('retail', 'Retail'),
    OptionItem('other', 'Other'),
  ];

  static const List<OptionItem> stages = [
    OptionItem('mvp', 'MVP / Prototype'),
    OptionItem('early-revenue', 'Early Revenue'),
    OptionItem('scaling', 'Scaling / Growth'),
  ];

  static const List<OptionItem> _docDefs = [
    OptionItem('pitch_deck', 'Pitch Deck'),
    OptionItem('financial_model', 'Financial Model'),
    OptionItem('product_demo', 'Product Demo / Screenshots'),
    OptionItem('customer_testimonials', 'Customer Testimonials'),
    OptionItem('tin_certificate', 'TIN Certificate'),
    OptionItem('business_license', 'Business License'),
    OptionItem('moa_aoa', 'MoA / AoA'),
    OptionItem('other', 'Other Supporting Details'),
  ];

  static const Map<String, List<String>> _requiredByStage = {
    'mvp': ['pitch_deck'],
    'early-revenue': [
      'pitch_deck',
      'financial_model',
      'tin_certificate',
      'business_license',
    ],
    'scaling': [
      'pitch_deck',
      'financial_model',
      'tin_certificate',
      'business_license',
      'moa_aoa',
    ],
  };

  static List<DocCategory> docCategoriesForStage(String stage) {
    final required = (_requiredByStage[stage] ?? const ['pitch_deck']).toSet();
    return _docDefs
        .map((d) => DocCategory(
              value: d.value,
              label: d.label,
              required: required.contains(d.value),
            ))
        .toList(growable: false);
  }

  static String sectorLabel(String value) =>
      sectors.firstWhere((s) => s.value == value,
          orElse: () => OptionItem(value, value)).label;

  static String stageLabel(String value) =>
      stages.firstWhere((s) => s.value == value,
          orElse: () => OptionItem(value, value)).label;

  static String docLabel(String value) =>
      _docDefs.firstWhere((d) => d.value == value,
          orElse: () => OptionItem(value, value)).label;
}
