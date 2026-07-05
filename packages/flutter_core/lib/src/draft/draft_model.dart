class DraftModel {
  final String draftId;
  final String positionId;
  final Map<String, dynamic> candidateData;
  final int currentWizardStep;
  final DateTime lastSaved;
  final int schemaVersion;

  DraftModel({
    required this.draftId,
    required this.positionId,
    required this.candidateData,
    required this.currentWizardStep,
    required this.lastSaved,
    this.schemaVersion = 1,
  });

  Map<String, dynamic> toJson() => {
    'draftId': draftId,
    'positionId': positionId,
    'candidateData': candidateData,
    'currentWizardStep': currentWizardStep,
    'lastSaved': lastSaved.toIso8601String(),
    'schemaVersion': schemaVersion,
  };

  factory DraftModel.fromJson(Map<String, dynamic> json) => DraftModel(
    draftId: json['draftId'] as String,
    positionId: json['positionId'] as String,
    candidateData: Map<String, dynamic>.from(json['candidateData'] as Map),
    currentWizardStep: json['currentWizardStep'] as int,
    lastSaved: DateTime.parse(json['lastSaved'] as String),
    schemaVersion: json['schemaVersion'] as int,
  );
}
