import 'draft_model.dart';

abstract class DraftRepository {
  Future<void> saveDraft(DraftModel draft);
  Future<DraftModel?> getDraft(String positionId);
  Future<void> deleteDraft(String positionId);
  Future<List<DraftModel>> getAllDrafts();
}
