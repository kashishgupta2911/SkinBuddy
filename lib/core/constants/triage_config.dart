class TriageConfig {
  static const double urgentConfidenceThreshold = 0.70;
  static const Set<String> urgentLabels = <String>{
    'infection',
    'cellulitis',
    'impetigo',
    'shingles',
  };
}
