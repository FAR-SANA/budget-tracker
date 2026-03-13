import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Speak your record",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              "Example:\nRs 200 spent for Fruits on 26th February 2026 in the food category from account Savings",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 20),

            Text(_text, textAlign: TextAlign.center),

            const SizedBox(height: 20),

            IconButton(
              iconSize: 60,
              icon: Icon(
                _isListening ? Icons.stop : Icons.mic,
                color: const Color(0xFF142752),
              ),
              onPressed: _isListening ? _stopListening : _startListening,
            ),
          ],
        ),
      ),
    );
  }
}
