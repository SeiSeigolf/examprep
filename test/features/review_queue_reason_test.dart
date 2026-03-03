import 'package:exam_os/features/review_queue/providers/review_queue.provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('要確認理由は優先順位順で連結される', () {
    const item = ReviewQueueItem(
      claimId: 1,
      examUnitId: 1,
      examUnitTitle: '循環器',
      claimContent: 'test',
      contentConfidence: 'L',
      auditStatus: 'LowConfidence',
      pointWeight: 1,
      frequency: 1,
      openConflictCount: 2,
      evidenceItemCount: 1,
      mastery: 0.0,
      reviewOverdue: true,
      nextReviewAt: null,
      priority: 5,
    );

    final reason = buildReviewReason(item);
    expect(reason, contains('1) Conflict(open) がある'));
    expect(reason, contains('0) 期限切れレビュー'));
    expect(reason, contains('2) auditStatus=LowConfidence'));
    expect(reason, contains('3) contentConfidence=L'));
    expect(reason, contains('4) evidence数が少ない (1)'));
  });

  test('該当理由がないときはデフォルト文言', () {
    const item = ReviewQueueItem(
      claimId: 1,
      examUnitId: 1,
      examUnitTitle: '循環器',
      claimContent: 'test',
      contentConfidence: 'H',
      auditStatus: 'Covered',
      pointWeight: 1,
      frequency: 1,
      openConflictCount: 0,
      evidenceItemCount: 3,
      mastery: 1.0,
      reviewOverdue: false,
      nextReviewAt: null,
      priority: 0.1,
    );
    expect(buildReviewReason(item), '優先度スコアが高い');
  });
}
