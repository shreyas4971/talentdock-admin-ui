import 'draft_model.dart';
import 'draft_repository.dart';

class DraftService {
  final DraftRepository _repository;

  DraftService(this._repository);

  Future<void> autoSave(String positionId, Map<String, dynamic> values, int step) async {
    final draft = DraftModel(
      draftId: 'draft_${DateTime.now().millisecondsSinceEpoch}',
      positionId: positionId,
      candidateData: values,
      currentWizardStep: step,
      lastSaved: DateTime.now(),
    );
    await _repository.saveDraft(draft);
  }

  Future<DraftModel?> restoreDraft(String positionId) async {
    return await _repository.getDraft(positionId);
  }

  Future<void> clearDraft(String positionId) async {
    await _repository.deleteDraft(positionId);
  }
}
