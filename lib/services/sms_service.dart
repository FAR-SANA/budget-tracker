import 'package:telephony/telephony.dart';
import '../main.dart';

class SmsService {
  static final Telephony telephony = Telephony.instance;

  static void startListening() {
    telephony.listenIncomingSms(
      onNewMessage: (message) {
        backgroundSmsHandler(message);
      },
      onBackgroundMessage: backgroundSmsHandler,
      listenInBackground: true,
    );
  }
}
