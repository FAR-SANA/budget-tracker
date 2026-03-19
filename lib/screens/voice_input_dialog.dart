import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../theme/app_colors.dart';

class VoiceInputDialog extends StatefulWidget {
  const VoiceInputDialog({super.key});

  @override
  State<VoiceInputDialog> createState() => _VoiceInputDialogState();
}

class _VoiceInputDialogState extends State<VoiceInputDialog> {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _text = "Tap the mic and speak";

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize();
  }

  void _startListening() async {
    setState(() => _isListening = true);

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _text = result.recognizedWords;
        });
      },
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);

    Navigator.pop(context, _text);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background(context), // ✅ ADD
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Speak your record",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text(context),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Example:\nRs 200 spent for Fruits on 26th February 2026 in the food category from account Savings",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.subText(context), fontSize: 13),
            ),

            const SizedBox(height: 20),

            Text(
              _text,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.text(context)),
            ),

            const SizedBox(height: 20),

            IconButton(
              iconSize: 60,
              icon: Icon(
                _isListening ? Icons.stop : Icons.mic,
                color: AppColors.text(context),
              ),
              onPressed: _isListening ? _stopListening : _startListening,
            ),
          ],
        ),
      ),
    );
  }
}
