import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_toast.dart';

class VoiceSearchDialog extends StatefulWidget {
  const VoiceSearchDialog({super.key, required this.onResult});

  final ValueChanged<String> onResult;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onResult,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => VoiceSearchDialog(onResult: onResult),
    );
  }

  @override
  State<VoiceSearchDialog> createState() => _VoiceSearchDialogState();
}

class _VoiceSearchDialogState extends State<VoiceSearchDialog> {
  final _speech = SpeechToText();
  String _status = '';
  bool _delivered = false;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final l10n = context.l10n;
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      if (mounted) {
        showAppToast(l10n.voice_search_permission_denied);
        Navigator.of(context).pop();
      }
      return;
    }

    final available = await _speech.initialize(
      onError: (e) => _onFailure(l10n.voice_search_try_again),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (!_delivered && mounted) {
            _onFailure(l10n.voice_search_try_again);
          }
        }
      },
    );

    if (!available) {
      if (mounted) {
        setState(() => _status = l10n.voice_search_unsupported);
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _status = l10n.voice_search_listening;
      _listening = true;
    });

    await _speech.listen(
      onResult: (result) {
        final words = result.recognizedWords.trim();
        if (words.isEmpty) return;
        if (result.finalResult) {
          _deliver(words);
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: 'vi_VN',
        listenMode: ListenMode.confirmation,
      ),
    );
  }

  void _deliver(String query) {
    if (_delivered) return;
    _delivered = true;
    _speech.stop();
    widget.onResult(query);
    if (mounted) Navigator.of(context).pop();
  }

  void _onFailure(String message) {
    if (_delivered || !mounted) return;
    setState(() => _status = message);
  }

  @override
  void dispose() {
    if (_listening) {
      _speech.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.voice_search_title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 24),
          if (_listening)
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          const SizedBox(height: 16),
          Text(
            _status.isEmpty ? l10n.voice_search_listening : _status,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.txtHint),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.voice_search_cancel),
          ),
        ],
      ),
    );
  }
}
