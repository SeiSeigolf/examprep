import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerDialog extends StatefulWidget {
  const PdfViewerDialog({
    super.key,
    required this.filePath,
    required this.pageNumber,
    required this.fileName,
  });

  final String filePath;
  final int pageNumber;
  final String fileName;

  @override
  State<PdfViewerDialog> createState() => _PdfViewerDialogState();
}

class _PdfViewerDialogState extends State<PdfViewerDialog> {
  late final PdfViewerController _controller;
  Uint8List? _pdfBytes;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = PdfViewerController();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final file = File(widget.filePath);
      debugPrint('[PdfViewer] filePath: ${widget.filePath}');
      debugPrint('[PdfViewer] exists: ${file.existsSync()}');
      final bytes = await file.readAsBytes();
      debugPrint('[PdfViewer] bytes loaded: ${bytes.length}');
      if (mounted) {
        setState(() => _pdfBytes = bytes);
      }
    } catch (e) {
      debugPrint('[PdfViewer] error: $e');
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = (screenSize.width * 0.75).clamp(600.0, 900.0);
    final dialogHeight = (screenSize.height * 0.85).clamp(500.0, 800.0);

    return Dialog(
      backgroundColor: const Color(0xFF1A1D23),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          children: [
            // ---- ヘッダー ----
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              decoration: const BoxDecoration(
                color: Color(0xFF2D3440),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf,
                      size: 16, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.fileName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D23),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'p.${widget.pageNumber}',
                      style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 18, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: '閉じる',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            // ---- PDF ビューア ----
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12)),
                child: _buildViewer(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewer() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'PDFを開けませんでした:\n$_error',
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_pdfBytes == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('PDFを読み込み中...',
                style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      );
    }

    return SfPdfViewer.memory(
      _pdfBytes!,
      controller: _controller,
      initialPageNumber: widget.pageNumber,
      onDocumentLoaded: (_) {
        _controller.jumpToPage(widget.pageNumber);
      },
      pageLayoutMode: PdfPageLayoutMode.single,
    );
  }
}
