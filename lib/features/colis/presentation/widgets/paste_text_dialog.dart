import 'package:flutter/material.dart';
import 'package:colis_manager/core/theme/app_theme.dart';
import 'package:colis_manager/core/utils/text_parser_util.dart';

class PasteTextDialog extends StatefulWidget {
  final String expectedUnite;
  const PasteTextDialog({super.key, required this.expectedUnite});

  @override
  State<PasteTextDialog> createState() => _PasteTextDialogState();
}

class _PasteTextDialogState extends State<PasteTextDialog> {
  final _textController = TextEditingController();
  TextParserResult? _result;
  bool _isParsing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _parse() {
    setState(() => _isParsing = true);
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _result = const TextParserResult(
          errors: {'text': 'Veuillez coller le texte du transitaire'},
        );
        _isParsing = false;
      });
      return;
    }

    final result = TextParserUtil.parse(text);
    setState(() {
      _result = result;
      _isParsing = false;
    });

    if (result.isSuccess && result.data != null) {
      Navigator.of(context).pop(result.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.content_paste_rounded, size: 18, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Coller le texte', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.expectedUnite == 'M3'
                  ? 'Collez le texte du transitaire. Le tracking, volume et prix seront extraits.'
                  : 'Collez le texte du transitaire. Le tracking, poids et prix seront extraits.',
              style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade500, height: 1.3),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _textController,
              maxLines: 4,
              minLines: 3,
              decoration: InputDecoration(
                hintText: widget.expectedUnite == 'M3'
                    ? 'Estimation tracking n°: 465441716960265\nLe volume de ce colis est: 0.011718M3\nLe prix du fret de ce colis est: 33750Ar'
                    : 'Estimation tracking n°: 465441716960265\nLe poids de ce colis est: 0.5KG\nLe prix du fret de ce colis est: 33750Ar',
                isDense: true,
                contentPadding: const EdgeInsets.all(12),
              ),
              style: const TextStyle(fontSize: 13),
            ),
            if (_result != null && _result!.hasErrors) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.statusNonLivre.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_rounded, color: AppTheme.statusNonLivre, size: 16),
                        const SizedBox(width: 6),
                        const Text('Champs manquants', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.statusNonLivre, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ..._result!.errors.values.map((error) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text('• $error', style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade700)),
                    )),
                    if (_result!.data != null) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(_result!.data),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            backgroundColor: AppTheme.statusNonLivre.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Utiliser quand même', style: TextStyle(fontSize: 12, color: AppTheme.statusNonLivre, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.15) : Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Annuler', style: TextStyle(fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isParsing ? null : _parse,
                    icon: _isParsing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.auto_fix_high_rounded, size: 18, color: Colors.white),
                    label: const Text('Parser', style: TextStyle(color: Colors.white, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
