import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/exam_units.provider.dart';
import '../providers/claims.provider.dart';
import '../providers/unit_stats.provider.dart';
import '../../../db/database.provider.dart';
import '../../ingestion/presentation/widgets/pdf_viewer_dialog.dart';
import 'widgets/add_claim_dialog.dart';
import 'widgets/claim_list_item.dart';
import 'widgets/confidence_badge.dart';
import 'widgets/evidence_panel.dart';
import 'widgets/exam_unit_dialog.dart';
import '../services/quiz_generator.dart';

class ExamUnitDetailPage extends ConsumerWidget {
  const ExamUnitDetailPage({super.key, required this.examUnitId});
  final int examUnitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(examUnitsListProvider);

    // 一覧の中から該当ユニットを探す
    final unit = unitsAsync.whenData(
      (units) => units.where((u) => u.id == examUnitId).firstOrNull,
    );

    if (unit.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (unit.value == null) {
      // 削除されたなど
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedExamUnitIdProvider.notifier).state = null;
      });
      return const SizedBox.shrink();
    }

    final u = unit.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- ヘッダーバー ----
        Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1D23),
            border: Border(bottom: BorderSide(color: Color(0xFF2E3340))),
          ),
          child: Row(
            children: [
              // 戻るボタン
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Colors.white54,
                ),
                onPressed: () {
                  ref.read(selectedExamUnitIdProvider.notifier).state = null;
                  ref.read(selectedClaimIdProvider.notifier).state = null;
                },
                tooltip: '一覧に戻る',
              ),
              const SizedBox(width: 4),
              // unitType チップ
              _UnitTypeLabel(u.unitType),
              const SizedBox(width: 10),
              // タイトル
              Expanded(
                child: Text(
                  u.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // バッジ
              ConfidenceBadge(u.confidenceLevel),
              const SizedBox(width: 6),
              AuditBadge(u.auditStatus),
              const SizedBox(width: 12),
              // 編集ボタン
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: const Text('編集', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => ExamUnitDialog(unit: u),
                ),
              ),
            ],
          ),
        ),
        // 説明欄
        if (u.description != null && u.description!.isNotEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            color: const Color(0xFF16191F),
            child: Text(
              u.description!,
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
        _ReviewSettingsBar(examUnitId: examUnitId),
        _QuizGeneratorPanel(
          examUnitId: examUnitId,
          problemFormat: u.problemFormat,
        ),

        // ---- 2カラムコンテンツ ----
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- 左: Claim 一覧 ----
              SizedBox(width: 340, child: _ClaimsPanel(examUnitId: examUnitId)),
              const VerticalDivider(width: 1),
              // ---- 右: Evidence パネル ----
              Expanded(child: _EvidencePanelWrapper()),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuizGeneratorPanel extends ConsumerStatefulWidget {
  const _QuizGeneratorPanel({
    required this.examUnitId,
    required this.problemFormat,
  });

  final int examUnitId;
  final String problemFormat;

  @override
  ConsumerState<_QuizGeneratorPanel> createState() =>
      _QuizGeneratorPanelState();
}

class _QuizGeneratorPanelState extends ConsumerState<_QuizGeneratorPanel> {
  DateTime _startedAt = DateTime.now();
  int? _lastClaimId;
  int? _selectedChoiceIndex;
  final _answerController = TextEditingController();
  bool _saving = false;
  bool? _lastResult;
  int? _lastSeconds;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _resetForClaim(int claimId) {
    if (_lastClaimId == claimId) return;
    _lastClaimId = claimId;
    _startedAt = DateTime.now();
    _selectedChoiceIndex = null;
    _answerController.clear();
    _lastResult = null;
    _lastSeconds = null;
  }

  Future<void> _saveAttempt({
    required int examUnitId,
    required int claimId,
    required String format,
    required bool isCorrect,
  }) async {
    final seconds = DateTime.now()
        .difference(_startedAt)
        .inSeconds
        .clamp(0, 36000);
    setState(() => _saving = true);
    try {
      await ref
          .read(databaseProvider)
          .quizAttemptsDao
          .insertAttempt(
            examUnitId: examUnitId,
            claimId: claimId,
            format: format,
            isCorrect: isCorrect,
            secondsSpent: seconds,
          );
      if (!mounted) return;
      setState(() {
        _lastResult = isCorrect;
        _lastSeconds = seconds;
        _startedAt = DateTime.now();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('回答を保存しました: ${isCorrect ? '正解' : '不正解'} / ${seconds}s'),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final examUnitId = widget.examUnitId;
    final problemFormat = widget.problemFormat;
    final claimsAsync = ref.watch(claimsForUnitProvider(examUnitId));
    final selectedClaimId = ref.watch(selectedClaimIdProvider);
    final segmentsAsync = ref.watch(allSegmentsWithSourceProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
      color: const Color(0xFF16191F),
      child: claimsAsync.when(
        loading: () => const LinearProgressIndicator(minHeight: 2),
        error: (e, _) => Text(
          'クイズ生成エラー: $e',
          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
        ),
        data: (claims) {
          if (claims.isEmpty) {
            return const Text(
              'Claimがないためクイズを生成できません',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            );
          }
          final target = claims.firstWhere(
            (c) => c.id == selectedClaimId,
            orElse: () => claims.first,
          );
          _resetForClaim(target.id);

          final quiz = generateQuizForUnit(
            problemFormat: problemFormat,
            targetClaim: target,
            allClaimsInUnit: claims,
          );
          final packAsync = ref.watch(evidencePackForClaimProvider(target.id));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.quiz_outlined,
                    size: 15,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'クイズ生成（MVP）',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _FormatChip(problemFormat),
                  const Spacer(),
                  Text(
                    '対象Claim: ${target.id}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _QuizBody(
                quiz: quiz,
                selectedChoiceIndex: _selectedChoiceIndex,
                answerController: _answerController,
                saving: _saving,
                onChoiceSelected: (v) =>
                    setState(() => _selectedChoiceIndex = v),
                onSubmitMcq: () async {
                  final idx = _selectedChoiceIndex;
                  if (idx == null) return;
                  final isCorrect = idx == quiz.correctChoiceIndex;
                  await _saveAttempt(
                    examUnitId: examUnitId,
                    claimId: target.id,
                    format: '選択肢',
                    isCorrect: isCorrect,
                  );
                },
                onSubmitFill: () async {
                  final user = _answerController.text.trim();
                  final ans = (quiz.answer ?? '').trim();
                  if (user.isEmpty || ans.isEmpty) return;
                  final isCorrect = user.toLowerCase() == ans.toLowerCase();
                  await _saveAttempt(
                    examUnitId: examUnitId,
                    claimId: target.id,
                    format: '穴埋め',
                    isCorrect: isCorrect,
                  );
                },
                onSubmitDescriptive: (isCorrect) async {
                  await _saveAttempt(
                    examUnitId: examUnitId,
                    claimId: target.id,
                    format: '記述',
                    isCorrect: isCorrect,
                  );
                },
              ),
              if (_lastResult != null) ...[
                const SizedBox(height: 6),
                Text(
                  '直近結果: ${_lastResult! ? '正解' : '不正解'} (${_lastSeconds ?? 0}s)',
                  style: TextStyle(
                    color: _lastResult!
                        ? Colors.lightGreenAccent
                        : Colors.amberAccent,
                    fontSize: 11,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              const Text(
                '根拠（EvidencePackItems）',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              packAsync.when(
                loading: () => const Text(
                  '読み込み中...',
                  style: TextStyle(color: Colors.white24, fontSize: 11),
                ),
                error: (e, _) => Text(
                  '読み込みエラー: $e',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                ),
                data: (bundle) {
                  if (bundle == null || bundle.items.isEmpty) {
                    return const Text(
                      'EvidencePackItemsなし',
                      style: TextStyle(color: Colors.white24, fontSize: 11),
                    );
                  }
                  return segmentsAsync.when(
                    loading: () => const Text(
                      '参照情報を読み込み中...',
                      style: TextStyle(color: Colors.white24, fontSize: 11),
                    ),
                    error: (e, _) => Text(
                      '参照情報エラー: $e',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 11,
                      ),
                    ),
                    data: (segments) {
                      final map = {for (final s in segments) s.segment.id: s};
                      return Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: bundle.items.map((item) {
                          final seg = map[item.sourceSegmentId];
                          final page =
                              item.pageNumber ?? seg?.segment.pageNumber;
                          final enabled =
                              seg != null && page != null && page > 0;
                          return OutlinedButton.icon(
                            onPressed: !enabled
                                ? null
                                : () => showDialog(
                                    context: context,
                                    builder: (_) => PdfViewerDialog(
                                      filePath: seg.source.filePath,
                                      fileName: seg.source.fileName,
                                      pageNumber: page,
                                    ),
                                  ),
                            icon: const Icon(Icons.picture_as_pdf, size: 13),
                            label: Text(
                              'p.${page ?? '-'}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 30),
                              visualDensity: VisualDensity.compact,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuizBody extends StatelessWidget {
  const _QuizBody({
    required this.quiz,
    required this.selectedChoiceIndex,
    required this.answerController,
    required this.saving,
    required this.onChoiceSelected,
    required this.onSubmitMcq,
    required this.onSubmitFill,
    required this.onSubmitDescriptive,
  });
  final GeneratedQuiz quiz;
  final int? selectedChoiceIndex;
  final TextEditingController answerController;
  final bool saving;
  final ValueChanged<int?> onChoiceSelected;
  final VoidCallback onSubmitMcq;
  final VoidCallback onSubmitFill;
  final ValueChanged<bool> onSubmitDescriptive;

  @override
  Widget build(BuildContext context) {
    switch (quiz.problemFormat) {
      case '穴埋め':
        return _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quiz.prompt,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: answerController,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: '解答を入力',
                  hintStyle: TextStyle(color: Colors.white30),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: saving ? null : onSubmitFill,
                child: const Text('判定して保存'),
              ),
            ],
          ),
        );
      case '記述':
        return _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quiz.prompt,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 6),
              const Text(
                '採点要素',
                style: TextStyle(color: Colors.white60, fontSize: 11),
              ),
              const SizedBox(height: 4),
              ...quiz.rubric.map(
                (r) => Text(
                  '• $r',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: answerController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: '回答を記述（MVPでは自己採点）',
                  hintStyle: TextStyle(color: Colors.white30),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilledButton.tonal(
                    onPressed: saving ? null : () => onSubmitDescriptive(true),
                    child: const Text('正解として保存'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: saving ? null : () => onSubmitDescriptive(false),
                    child: const Text('不正解として保存'),
                  ),
                ],
              ),
            ],
          ),
        );
      case '選択肢':
      default:
        return _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quiz.prompt,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 6),
              ...quiz.choices.asMap().entries.map(
                (e) => RadioListTile<int>(
                  value: e.key,
                  groupValue: selectedChoiceIndex,
                  onChanged: saving ? null : onChoiceSelected,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${e.key + 1}. ${e.value}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: saving ? null : onSubmitMcq,
                child: const Text('判定して保存'),
              ),
            ],
          ),
        );
    }
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }
}

class _FormatChip extends StatelessWidget {
  const _FormatChip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---- Claim 一覧パネル ----

class _ClaimsPanel extends ConsumerWidget {
  const _ClaimsPanel({required this.examUnitId});
  final int examUnitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsAsync = ref.watch(claimsForUnitProvider(examUnitId));
    final selectedClaimId = ref.watch(selectedClaimIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // パネルヘッダー
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
          child: Row(
            children: [
              const Text(
                'Claims',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 14),
                label: const Text('追加', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AddClaimDialog(examUnitId: examUnitId),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: claimsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'エラー: $e',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
            data: (claimList) {
              if (claimList.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Claim がまだありません\n「追加」から作成してください\n\n※ Claim には必ず根拠（Evidence）が\n　 必要です',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white24, fontSize: 12),
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: claimList.length,
                itemBuilder: (context, i) {
                  final claim = claimList[i];
                  return ClaimListItem(
                    claim: claim,
                    isSelected: claim.id == selectedClaimId,
                    onTap: () {
                      ref.read(selectedClaimIdProvider.notifier).state =
                          claim.id;
                    },
                    onDelete: () => _confirmDelete(context, ref, claim.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int claimId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Claim を削除'),
        content: const Text('この Claim と紐づく Evidence Link を全て削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(context).pop();
              if (ref.read(selectedClaimIdProvider) == claimId) {
                ref.read(selectedClaimIdProvider.notifier).state = null;
              }
              await ref
                  .read(databaseProvider)
                  .claimsDao
                  .deleteClaimWithEvidence(claimId);
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}

// ---- Evidence パネルラッパー ----

class _EvidencePanelWrapper extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClaimId = ref.watch(selectedClaimIdProvider);

    if (selectedClaimId == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_outlined, size: 40, color: Colors.white12),
            SizedBox(height: 12),
            Text(
              'Claim を選択すると\n根拠（Evidence）が表示されます',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white24, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: EvidencePanel(claimId: selectedClaimId),
    );
  }
}

class _ReviewSettingsBar extends ConsumerStatefulWidget {
  const _ReviewSettingsBar({required this.examUnitId});
  final int examUnitId;

  @override
  ConsumerState<_ReviewSettingsBar> createState() => _ReviewSettingsBarState();
}

class _ReviewSettingsBarState extends ConsumerState<_ReviewSettingsBar> {
  final _pointWeightController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _pointWeightFocus = FocusNode();
  final _frequencyFocus = FocusNode();
  bool? _manualOverride;
  bool _saving = false;

  @override
  void dispose() {
    _pointWeightController.dispose();
    _frequencyController.dispose();
    _pointWeightFocus.dispose();
    _frequencyFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final pointWeight = int.tryParse(_pointWeightController.text);
    final frequency = int.tryParse(_frequencyController.text);
    final manualOverride = _manualOverride ?? false;
    if (pointWeight == null || frequency == null) return;
    if (pointWeight < 1 || frequency < 1) return;

    setState(() => _saving = true);
    try {
      await ref.read(saveUnitReviewSettingsProvider)(
        examUnitId: widget.examUnitId,
        pointWeight: pointWeight,
        frequency: frequency,
        frequencyManualOverride: manualOverride,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review Queueパラメータを保存しました'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(
      unitReviewSettingsProvider(widget.examUnitId),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      color: const Color(0xFF16191F),
      child: settingsAsync.when(
        loading: () => const LinearProgressIndicator(minHeight: 2),
        error: (e, _) => Text(
          'Review設定の読み込みエラー: $e',
          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
        ),
        data: (settings) {
          if (!_pointWeightFocus.hasFocus &&
              _pointWeightController.text != settings.pointWeight.toString()) {
            _pointWeightController.text = settings.pointWeight.toString();
          }
          if (!_frequencyFocus.hasFocus &&
              _frequencyController.text != settings.frequency.toString()) {
            _frequencyController.text = settings.frequency.toString();
          }
          _manualOverride ??= settings.frequencyManualOverride;

          return Row(
            children: [
              const Text(
                'Review Queue',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              _NumberField(
                label: 'pointWeight',
                controller: _pointWeightController,
                focusNode: _pointWeightFocus,
              ),
              const SizedBox(width: 10),
              _NumberField(
                label: 'frequency',
                controller: _frequencyController,
                focusNode: _frequencyFocus,
                enabled: _manualOverride ?? false,
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Switch(
                    value: _manualOverride ?? false,
                    onChanged: (v) => setState(() => _manualOverride = v),
                  ),
                  Text(
                    _manualOverride == true ? 'manual' : 'auto',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              FilledButton.tonal(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('保存'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.controller,
    required this.focusNode,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(color: Colors.white, fontSize: 12),
        decoration: InputDecoration(
          isDense: true,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54, fontSize: 11),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}

// ---- 補助ウィジェット ----

class _UnitTypeLabel extends StatelessWidget {
  const _UnitTypeLabel(this.type);
  final String type;

  static const _colors = <String, Color>{
    '定義': Color(0xFF4A90D9),
    '機序': Color(0xFF9C27B0),
    '鑑別': Color(0xFF00BCD4),
    '画像所見': Color(0xFF4CAF50),
    'その他': Color(0xFF607D8B),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[type] ?? const Color(0xFF607D8B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
