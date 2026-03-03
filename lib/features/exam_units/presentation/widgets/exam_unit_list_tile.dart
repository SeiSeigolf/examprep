import 'package:flutter/material.dart';
import '../../../../db/database.dart';
import 'confidence_badge.dart';

class ExamUnitListTile extends StatelessWidget {
  const ExamUnitListTile({
    super.key,
    required this.unit,
    required this.index,
    required this.claimCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final ExamUnit unit;
  final int index;
  final int claimCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 8, 12),
          child: Row(
            children: [
              // ドラッグハンドル
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.drag_handle,
                      size: 18, color: Colors.white24),
                ),
              ),
              // unitType チップ
              _UnitTypeChip(unit.unitType),
              const SizedBox(width: 12),
              // タイトル + 説明
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (unit.description != null &&
                        unit.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        unit.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // バッジ類
              ConfidenceBadge(unit.confidenceLevel),
              const SizedBox(width: 6),
              AuditBadge(unit.auditStatus),
              if (claimCount > 0) ...[
                const SizedBox(width: 6),
                Text(
                  '$claimCount件',
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 11),
                ),
              ],
              const SizedBox(width: 4),
              // アクションメニュー
              PopupMenuButton<_Action>(
                icon: const Icon(Icons.more_vert, color: Colors.white38, size: 18),
                onSelected: (action) {
                  if (action == _Action.edit) onEdit();
                  if (action == _Action.delete) onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: _Action.edit, child: Text('編集')),
                  PopupMenuItem(
                    value: _Action.delete,
                    child: Text('削除', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Action { edit, delete }

class _UnitTypeChip extends StatelessWidget {
  const _UnitTypeChip(this.type);
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
      width: 52,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        type,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
