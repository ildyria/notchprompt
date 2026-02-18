import 'package:flutter/material.dart';

import 'script_file_io.dart';

/// Plain-text script editor widget with import/export toolbar.
class ScriptEditorView extends StatefulWidget {
  const ScriptEditorView({
    required this.initialText,
    required this.onChanged,
    super.key,
  });

  final String initialText;
  final ValueChanged<String> onChanged;

  @override
  State<ScriptEditorView> createState() => _ScriptEditorViewState();
}

class _ScriptEditorViewState extends State<ScriptEditorView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _controller.addListener(_onEdited);
  }

  @override
  void didUpdateWidget(ScriptEditorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialText != widget.initialText &&
        _controller.text != widget.initialText) {
      _controller
        ..removeListener(_onEdited)
        ..text = widget.initialText
        ..addListener(_onEdited);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEdited() => widget.onChanged(_controller.text);

  Future<void> _importScript() async {
    try {
      final text = await importScriptText();
      if (text == null) return;
      _controller.text = text;
      widget.onChanged(text);
    } on Exception catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    }
  }

  Future<void> _exportScript() async {
    try {
      await exportScriptText(_controller.text);
    } on Exception catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('File Operation Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          maxLines: 12,
          style: const TextStyle(fontSize: 14, height: 1.5),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12),
            hintText: 'Paste your script here…',
            hintStyle: const TextStyle(color: Colors.white30),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _importScript,
              icon: const Icon(Icons.upload_file_rounded, size: 16),
              label: const Text('Import…'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _exportScript,
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Export…'),
            ),
          ],
        ),
      ],
    );
  }
}
