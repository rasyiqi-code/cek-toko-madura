class HandoverReport {
  final String date;
  final String fromKeeper;
  final String toKeeper;
  final double deficit;
  final double surplus;
  final List<String> details;
  final List<Map<String, dynamic>>? auditedItems;

  HandoverReport({
    required this.date,
    required this.fromKeeper,
    required this.toKeeper,
    required this.deficit,
    required this.surplus,
    required this.details,
    this.auditedItems,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'from': fromKeeper,
        'to': toKeeper,
        'deficit': deficit,
        'surplus': surplus,
        'details': details,
        'auditedItems': auditedItems,
      };

  factory HandoverReport.fromJson(Map<String, dynamic> json) => HandoverReport(
        date: json['date'],
        fromKeeper: json['from'] ?? 'N/A',
        toKeeper: json['to'] ?? 'N/A',
        deficit: json['deficit'].toDouble(),
        surplus: json['surplus'].toDouble(),
        details: List<String>.from(json['details']),
        auditedItems: json['auditedItems'] != null 
            ? List<Map<String, dynamic>>.from(json['auditedItems']) 
            : null,
      );
}
