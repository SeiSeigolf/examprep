import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/exam_units.provider.dart';
import '../providers/claims.provider.dart';
import '../providers/unit_stats.provider.dart';
import '../../../db/database.provider.dart';
import 'widgets/add_claim_dialog.dart';
import 'widgets/claim_list_item.dart';
import 'widgets/confidence_badge.dart';
import 'widgets/evidence_panel.dart';
import 'widgets/exam_unit_dialog.dart';

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
