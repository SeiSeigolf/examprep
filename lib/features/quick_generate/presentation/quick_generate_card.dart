import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../db/database.dart';
import '../../../db/database.provider.dart';
import '../../../shared/constants/source_weights.dart';
import '../../../shared/providers/exam_profile.provider.dart';
import '../../../shared/providers/navigation.provider.dart';
import '../../exam_units/providers/exam_units.provider.dart';
import '../../master_sheet/services/exam_pack_generator.dart'
    show ExamPackGenerator, ExamPackResult, ExportFormat;
import '../services/quick_generate_pipeline.dart';

// ============================================================
// Helpers
// ============================================================

const _medicalSubjects = [
  '生理学', '解剖学', '病理学', '薬理学', '生化学', '免疫学',
  '微生物学', '微生物', '公衆衛生', '内科学', '外科学', '小児科',
  '産婦人科', '精神医学', '神経学', '循環器', '呼吸器', '消化器',
  '腎臓', '内分泌', '血液', '感染症', '整形外科', '皮膚科',
  '眼科', '耳鼻科', '放射線', '救急',
];

String _fileBaseName(String path) {
  final normalized = path.replaceAll('\\\\', '/');
  final idx = normalized.lastIndexOf('/');
  return idx >= 0 ? normalized.substring(idx + 1) : normalized;
}

String _inferExamName(List<String> paths) {
  if (paths.isEmpty) return '';
  final combined = paths.map(_fileBaseName).join(' ');
  for (final s in _medicalSubjects) {
    if (combined.contains(s)) return '$s 期末';
  }
  if (paths.length == 1) {
    final base = _fileBaseName(paths.first)
        .replaceAll(RegExp(r'\.(pdf)$', caseSensitive: false), '');
    return base.length > 24 ? base.substring(0, 24) : base;
  }
  return '期末テスト';
}

String _inferSubject(List<String> paths) {
  final combined = paths.map(_fileBaseName).join(' ');
  for (final s in _medicalSubjects) {
    if (combined.contains(s)) return s;
  }
  return '';
}

String _inferSourceTypeFromPath(String path) {
  final lower = path.toLowerCase();
  final name = _fileBaseName(path);
  if (lower.contains('past') ||
      lower.contains('exam') ||
      name.contains('過去問')) {
    return 'past_exam';
  }
  if (lower.contains('prof') ||
      lower.contains('teacher') ||
      name.contains('教授') ||
      name.contains('先生')) {
    return 'professor_notes';
  }
  if (lower.contains('note') || name.contains('ノート')) return 'notes';
  if (lower.contains('assignment') || name.contains('課題')) return 'assignment';
  return 'lecture';
}

Color _sourceTypeColor(String type) {
  return switch (type) {
    'past_exam' => const Color(0xFFFF5252),
    'professor_notes' => const Color(0xFFFFD740),
    'lecture' => const Color(0xFF4A90D9),
    'notes' => const Color(0xFF50C878),
    'assignment' => const Color(0xFFFF9800),
    _ => Colors.white38,
  };
}

// ============================================================
// Main Widget
// ============================================================

class QuickGenerateCard extends ConsumerStatefulWidget {
  const QuickGenerateCard({super.key});

  @override
  ConsumerState<QuickGenerateCard> createState() => _QuickGenerateCardState();
}

class _QuickGenerateCardState extends ConsumerState<QuickGenerateCard> {
  final _examNameController = TextEditingController();
  final _subjectController = TextEditingController();
  DateTime? _examDate;
  String? _selectedSourceType;
  final List<String> _pdfPaths = [];

  bool _settingsExpanded = false;
  bool _running = false;

  // Ollama 設定
  bool _useOllama = false;
  String _ollamaModel = 'qwen3:4b';
  final _ollamaBaseUrlController = TextEditingController(
    text: 'http://localhost:11434',
  );
  QuickGenerateProgress? _progress;
  QuickGenerateResult? _result;
  Object? _error;
  bool _dragOver = false;

  @override
  void dispose() {
    _examNameController.dispose();
    _subjectController.dispose();
    _ollamaBaseUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    _onFilesAdded(
      picked.files.where((f) => f.path != null).map((f) => f.path!),
    );
  }

  void _onFilesAdded(Iterable<String> newPaths) {
    var added = false;
    for (final path in newPaths) {
      final normalized = path.trim();
      if (normalized.isEmpty) continue;
      if (!normalized.toLowerCase().endsWith('.pdf')) continue;
      if (_pdfPaths.contains(normalized)) continue;
      _pdfPaths.add(normalized);
      added = true;
    }
    if (!added) return;

    // Auto-fill exam name if still empty
    if (_examNameController.text.trim().isEmpty) {
      _examNameController.text = _inferExamName(_pdfPaths);
    }
    // Auto-fill subject if still empty
    if (_subjectController.text.trim().isEmpty) {
      _subjectController.text = _inferSubject(_pdfPaths);
    }

    setState(() {});
  }

  Future<void> _run() async {
    final examName = _examNameController.text.trim();
    if (examName.isEmpty) {
      setState(() => _error = '試験名を入力してください');
      return;
    }
    if (_pdfPaths.isEmpty) {
      setState(() => _error = 'PDFを1件以上追加してください');
      return;
    }

    setState(() {
      _running = true;
      _error = null;
      _result = null;
      _progress = const QuickGenerateProgress(
        step: QuickGenerateStep.extracting,
        message: '開始',
      );
    });

    try {
      final pipeline = QuickGeneratePipeline(ref.read(databaseProvider));
      final result = await pipeline.run(
        QuickGenerateRequest(
          examName: examName,
          examDate: _examDate,
          subject: _subjectController.text.trim().isEmpty
              ? null
              : _subjectController.text.trim(),
          pdfPaths: _pdfPaths,
          sourceType: _selectedSourceType,
          useOllama: _useOllama,
          ollamaModel: _ollamaModel,
          ollamaBaseUrl: _ollamaBaseUrlController.text.trim().isEmpty
              ? 'http://localhost:11434'
              : _ollamaBaseUrlController.text.trim(),
        ),
        onProgress: (p) {
          if (!mounted) return;
          setState(() => _progress = p);
        },
      );
      if (!mounted) return;
      setState(() => _result = result);
      ref.read(activeExamProfileIdProvider.notifier).state =
          result.examProfileId;
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: DropTarget(
        onDragEntered: (_) {
          if (_running) return;
          setState(() => _dragOver = true);
        },
        onDragExited: (_) {
          if (!mounted) return;
          setState(() => _dragOver = false);
        },
        onDragDone: (details) {
          if (_running) return;
          setState(() => _dragOver = false);
          _onFilesAdded(details.files.map((f) => f.path));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Header ----
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Color(0xFF4A90D9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Quick Generate',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'PDFをドロップするだけで網羅資料を生成',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ---- Drop Zone ----
              _DropZone(
                paths: _pdfPaths,
                dragOver: _dragOver,
                running: _running,
                onPickFiles: _pickFiles,
                onRemovePath: (p) => setState(() => _pdfPaths.remove(p)),
              ),

              // ---- Fields + Generate (only shown after files added) ----
              if (_pdfPaths.isNotEmpty) ...[
                const SizedBox(height: 12),

                // Exam name row
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _examNameController,
                          enabled: !_running,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            labelText: '試験名 *',
                            labelStyle: TextStyle(fontSize: 12),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _settingsExpanded = !_settingsExpanded),
                      icon: Icon(
                        _settingsExpanded ? Icons.expand_less : Icons.tune,
                        size: 15,
                      ),
                      label: Text(
                        _settingsExpanded ? '閉じる' : '詳細設定',
                        style: const TextStyle(fontSize: 11),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white54,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                  ],
                ),

                // Expandable settings
                if (_settingsExpanded) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: 180,
                        child: TextField(
                          controller: _subjectController,
                          enabled: !_running,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            labelText: '科目(任意)',
                            labelStyle: TextStyle(fontSize: 12),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: OutlinedButton.icon(
                          onPressed: _running
                              ? null
                              : () async {
                                  final now = DateTime.now();
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _examDate ?? now,
                                    firstDate: now.subtract(
                                      const Duration(days: 365),
                                    ),
                                    lastDate: now.add(
                                      const Duration(days: 365 * 3),
                                    ),
                                  );
                                  if (picked == null || !mounted) return;
                                  setState(
                                    () => _examDate = DateTime(
                                      picked.year,
                                      picked.month,
                                      picked.day,
                                      9,
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.event, size: 14),
                          label: Text(
                            _examDate == null
                                ? '試験日(任意)'
                                : _examDate!
                                    .toLocal()
                                    .toString()
                                    .substring(0, 10),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<String?>(
                          value: _selectedSourceType,
                          isDense: true,
                          decoration: const InputDecoration(
                            labelText: 'ソース種別(一括)',
                            labelStyle: TextStyle(fontSize: 11),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                'auto(ファイル名で推定)',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                            ...sourceTypeValues.map(
                              (t) => DropdownMenuItem<String?>(
                                value: t,
                                child: Text(
                                  sourceTypeLabels[t] ?? t,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            ),
                          ],
                          onChanged: _running
                              ? null
                              : (v) =>
                                    setState(() => _selectedSourceType = v),
                        ),
                      ),
                    ],
                  ),
                  // ---- Ollama 設定 ----
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _useOllama,
                        onChanged: _running
                            ? null
                            : (v) =>
                                  setState(() => _useOllama = v ?? false),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                      const Text(
                        'Ollamaを使う',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      if (_useOllama) ...[
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 140,
                          child: DropdownButtonFormField<String>(
                            value: _ollamaModel,
                            isDense: true,
                            decoration: const InputDecoration(
                              labelText: 'モデル',
                              labelStyle: TextStyle(fontSize: 11),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'qwen3:4b',
                                child: Text(
                                  'qwen3:4b',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'gpt-oss:20b',
                                child: Text(
                                  'gpt-oss:20b',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                            onChanged: _running
                                ? null
                                : (v) {
                                    if (v != null) {
                                      setState(() => _ollamaModel = v);
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: _ollamaBaseUrlController,
                            enabled: !_running,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'baseUrl',
                              labelStyle: TextStyle(fontSize: 11),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // Generate button
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: _running ? null : _run,
                      icon: _running
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome, size: 16),
                      label: const Text('網羅資料を生成'),
                    ),
                    if (_running && _progress != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_stepLabel(_progress!.step)}: ${_progress!.message}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              // ---- Error ----
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  'エラー: $_error',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ],

              // ---- Result ----
              if (_result != null) ...[
                const SizedBox(height: 12),
                _ResultPanel(result: _result!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _stepLabel(QuickGenerateStep step) {
    return switch (step) {
      QuickGenerateStep.extracting => '抽出中',
      QuickGenerateStep.drafting => 'Unit候補作成',
      QuickGenerateStep.deduplicating => '重複統合',
      QuickGenerateStep.auditing => '監査更新',
      QuickGenerateStep.exporting => '出力',
      QuickGenerateStep.done => '完了',
    };
  }
}

// ============================================================
// Drop Zone
// ============================================================

class _DropZone extends StatelessWidget {
  const _DropZone({
    required this.paths,
    required this.dragOver,
    required this.running,
    required this.onPickFiles,
    required this.onRemovePath,
  });

  final List<String> paths;
  final bool dragOver;
  final bool running;
  final VoidCallback onPickFiles;
  final ValueChanged<String> onRemovePath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (running || paths.isNotEmpty) ? null : onPickFiles,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        constraints: BoxConstraints(minHeight: paths.isEmpty ? 110 : 56),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: dragOver
                ? const Color(0xFF4A90D9)
                : paths.isEmpty
                    ? const Color(0xFF3A3F50)
                    : const Color(0xFF2E3340),
            width: dragOver ? 2 : 1,
          ),
          color: dragOver
              ? const Color(0xFF1A2535)
              : paths.isEmpty
                  ? const Color(0xFF14171E)
                  : const Color(0xFF16191F),
        ),
        child: paths.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.upload_file_outlined,
                    size: 32,
                    color: dragOver
                        ? const Color(0xFF4A90D9)
                        : Colors.white24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dragOver
                        ? 'ここにドロップ'
                        : 'PDFをドロップ　または　クリックして追加',
                    style: TextStyle(
                      color: dragOver
                          ? const Color(0xFF4A90D9)
                          : Colors.white38,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '複数ファイル対応 — 過去問・講義資料・ノートなど',
                    style: TextStyle(color: Colors.white24, fontSize: 11),
                  ),
                ],
              )
            : Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...paths.map(
                    (p) => Chip(
                      avatar: Icon(
                        Icons.picture_as_pdf,
                        size: 13,
                        color: _sourceTypeColor(
                          _inferSourceTypeFromPath(p),
                        ),
                      ),
                      label: Text(
                        '${_fileBaseName(p)}  [${sourceTypeLabels[_inferSourceTypeFromPath(p)] ?? ''}]',
                        style: const TextStyle(fontSize: 11),
                      ),
                      onDeleted: running ? null : () => onRemovePath(p),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  if (!running)
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 13),
                      label: const Text(
                        '追加',
                        style: TextStyle(fontSize: 11),
                      ),
                      onPressed: onPickFiles,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
      ),
    );
  }
}

// ============================================================
// Result Panel (Option B: inline rich view)
// ============================================================

class _ResultPanel extends ConsumerStatefulWidget {
  const _ResultPanel({required this.result});

  final QuickGenerateResult result;

  @override
  ConsumerState<_ResultPanel> createState() => _ResultPanelState();
}

class _ResultPanelState extends ConsumerState<_ResultPanel> {
  bool _unitsExpanded = false;
  bool _packRunning = false;
  ExamPackResult? _packResult;
  Object? _packError;
  ExportFormat _exportFormat = ExportFormat.markdown;

  static const _readyConflictThreshold = 5;
  static const _readyLowConfidenceThreshold = 10;

  Future<void> _generatePack() async {
    setState(() {
      _packRunning = true;
      _packError = null;
      _packResult = null;
    });

    try {
      final db = ref.read(databaseProvider);
      final result = widget.result;
      final appSupport = await getApplicationSupportDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final outputDir =
          '${appSupport.path}/exam_packs/${result.examProfileId}_$ts';

      final generator = ExamPackGenerator(db);
      final packResult = await generator.generateAndSave(
        examProfileId: result.examProfileId,
        examName: _examName(),
        outputDir: outputDir,
        format: _exportFormat,
      );

      if (!mounted) return;
      setState(() => _packResult = packResult);
    } catch (e) {
      if (!mounted) return;
      setState(() => _packError = e);
    } finally {
      if (mounted) setState(() => _packRunning = false);
    }
  }

  String _examName() {
    // ExamPackResult does not embed examName, derive from path or use fallback
    final profileId = widget.result.examProfileId;
    return '試験プロファイル #$profileId';
  }

  Future<void> _openPackFolder() async {
    if (_packResult == null) return;
    await Process.run('open', [_packResult!.outputDir]);
  }

  Future<void> _openMarkdown() async {
    try {
      if (!await File(widget.result.markdownPath).exists()) {
        throw 'ファイルがありません';
      }
      await Process.run('open', [widget.result.markdownPath]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('開けません: $e')),
        );
      }
    }
  }

  Future<void> _copyPath() async {
    await Clipboard.setData(
      ClipboardData(text: widget.result.markdownPath),
    );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('パスをコピーしました')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.result.summary;
    final ready = summary.uncoveredCount == 0 &&
        summary.conflictCount <= _readyConflictThreshold &&
        summary.lowConfidenceCount <= _readyLowConfidenceThreshold;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ready ? const Color(0xFF355E3B) : const Color(0xFF5C4A1C),
        ),
        color: ready ? const Color(0xFF17231A) : const Color(0xFF231E12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Status badge ----
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: ready
                      ? const Color(0xFF2E5E35)
                      : const Color(0xFF5C3E0A),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      ready ? Icons.check_circle : Icons.pending_actions,
                      size: 13,
                      color: ready ? Colors.lightGreenAccent : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ready ? '学習開始OK' : '要確認あり',
                      style: TextStyle(
                        color: ready ? Colors.lightGreenAccent : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Coverage ${summary.coveragePercent}%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.result.createdUnitIds.length} Units / 統合 ${widget.result.autoMergedCount}',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ---- Stats chips ----
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _StatChip(
                label: 'Uncovered',
                value: summary.uncoveredCount,
                color: summary.uncoveredCount > 0
                    ? Colors.redAccent
                    : Colors.white38,
              ),
              _StatChip(
                label: 'Conflict',
                value: summary.conflictCount,
                color: summary.conflictCount > _readyConflictThreshold
                    ? Colors.orangeAccent
                    : Colors.white38,
              ),
              _StatChip(
                label: 'LowConf',
                value: summary.lowConfidenceCount,
                color: summary.lowConfidenceCount > _readyLowConfidenceThreshold
                    ? Colors.yellowAccent
                    : Colors.white38,
              ),
              _StatChip(
                label: 'Auto-link',
                value: widget.result.autoLinkedCount,
                color: Colors.white38,
              ),
            ],
          ),

          // ---- Unit list (collapsible) ----
          if (widget.result.createdUnitIds.isNotEmpty) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () =>
                  setState(() => _unitsExpanded = !_unitsExpanded),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      _unitsExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 16,
                      color: Colors.white54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '生成Unit一覧 (${widget.result.createdUnitIds.length}件) — タップで詳細へ',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_unitsExpanded) ...[
              const SizedBox(height: 6),
              _InlineUnitList(unitIds: widget.result.createdUnitIds),
            ],
          ],

          // ---- Auto-merged pairs ----
          if (widget.result.autoMergedPairs.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '自動統合 ${widget.result.autoMergedCount}件:',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const SizedBox(height: 3),
            ...widget.result.autoMergedPairs.take(5).map(
              (p) => Text(
                '  ${p.parentTitle} ← ${p.childTitle}',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.result.autoMergedPairs.length > 5)
              Text(
                '  ... 他 ${widget.result.autoMergedPairs.length - 5} 件',
                style: const TextStyle(color: Colors.white24, fontSize: 10),
              ),
          ],

          const SizedBox(height: 10),
          const Divider(color: Color(0xFF2D3440), height: 1),
          const SizedBox(height: 10),

          // ---- 出力形式 + Action buttons ----
          Row(
            children: [
              const Text(
                '出力形式:',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const SizedBox(width: 6),
              DropdownButton<ExportFormat>(
                value: _exportFormat,
                isDense: true,
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white70, fontSize: 11),
                dropdownColor: const Color(0xFF1E2330),
                items: ExportFormat.values
                    .map(
                      (f) => DropdownMenuItem(
                        value: f,
                        child: Text(f.label),
                      ),
                    )
                    .toList(),
                onChanged: _packRunning
                    ? null
                    : (f) {
                        if (f != null) setState(() => _exportFormat = f);
                      },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (summary.uncoveredCount > 0)
                FilledButton.icon(
                  onPressed: () {
                    ref.read(selectedDestinationProvider.notifier).state =
                        AppDestination.coverageAudit;
                  },
                  icon: const Icon(Icons.rule_outlined, size: 14),
                  label: Text('Uncovered ${summary.uncoveredCount}件を解消'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5C2424),
                    foregroundColor: Colors.redAccent,
                  ),
                ),
              if (summary.conflictCount > _readyConflictThreshold)
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(selectedDestinationProvider.notifier).state =
                        AppDestination.examUnits;
                  },
                  icon: const Icon(Icons.warning_amber_outlined, size: 14),
                  label: Text('Conflict ${summary.conflictCount}件を確認'),
                ),
              OutlinedButton.icon(
                onPressed: _openMarkdown,
                icon: const Icon(Icons.open_in_new, size: 14),
                label: const Text('Markdownを開く'),
              ),
              OutlinedButton.icon(
                onPressed: _copyPath,
                icon: const Icon(Icons.copy, size: 14),
                label: const Text('パスをコピー'),
              ),
              FilledButton.icon(
                onPressed: _packRunning ? null : _generatePack,
                icon: _packRunning
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.folder_zip_outlined, size: 14),
                label: const Text('網羅資料パックを生成'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1F3A5F),
                  foregroundColor: const Color(0xFF80BFFF),
                ),
              ),
            ],
          ),

          // ---- Pack result ----
          if (_packError != null) ...[
            const SizedBox(height: 8),
            Text(
              'パック生成エラー: $_packError',
              style: const TextStyle(color: Colors.redAccent, fontSize: 11),
            ),
          ],
          if (_packResult != null) ...[
            const SizedBox(height: 10),
            const Divider(color: Color(0xFF2D3440), height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.folder_open_outlined,
                  size: 14,
                  color: Color(0xFF80BFFF),
                ),
                const SizedBox(width: 6),
                const Text(
                  '網羅資料パック生成完了',
                  style: TextStyle(
                    color: Color(0xFF80BFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _openPackFolder,
                  icon: const Icon(Icons.open_in_new, size: 13),
                  label: const Text('フォルダを開く', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF80BFFF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                    minimumSize: const Size(0, 28),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ..._packResult!.files.map(
              (f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 12,
                      color: Colors.white38,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        f.fileName,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Text(
                      '${(f.markdown.length / 1024).toStringAsFixed(1)} KB',
                      style: const TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2330),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF2D3440)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Inline Unit List (Option B)
// ============================================================

class _InlineUnitList extends ConsumerWidget {
  const _InlineUnitList({required this.unitIds});

  final List<int> unitIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<ExamUnit>>(
      future: ref.read(databaseProvider).examUnitsDao.getUnitsByIds(unitIds),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 28,
            child: Center(
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final units = snapshot.data!;
        const statusRank = <String, int>{
          'Uncovered': 0,
          'Conflict': 1,
          'LowConfidence': 2,
          'Partial': 3,
          'Covered': 4,
        };
        final sorted = [...units]
          ..sort(
            (a, b) => (statusRank[a.auditStatus] ?? 9)
                .compareTo(statusRank[b.auditStatus] ?? 9),
          );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...sorted.take(16).map((u) => _UnitRow(unit: u)),
            if (sorted.length > 16)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  '... 他 ${sorted.length - 16} 件',
                  style: const TextStyle(
                    color: Colors.white24,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _UnitRow extends ConsumerWidget {
  const _UnitRow({required this.unit});

  final ExamUnit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (statusColor, statusLabel) = switch (unit.auditStatus) {
      'Covered' => (const Color(0xFF4CAF50), 'Covered'),
      'Partial' => (const Color(0xFF8BC34A), 'Partial'),
      'Conflict' => (Colors.orangeAccent, 'Conflict'),
      'LowConfidence' => (Colors.yellowAccent, 'LowConf'),
      _ => (Colors.redAccent, 'Uncovered'),
    };

    return InkWell(
      onTap: () {
        ref.read(selectedExamUnitIdProvider.notifier).state = unit.id;
        ref.read(selectedDestinationProvider.notifier).state =
            AppDestination.examUnits;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                unit.title,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              statusLabel,
              style: TextStyle(color: statusColor, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
