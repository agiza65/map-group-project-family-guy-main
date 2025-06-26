import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

const String agoraAppId = '14e959682c9747919c09ec3ebe4accda';
const String agoraToken = '';
const String agoraChannel = 'test_channel';

class VoiceCallPage extends StatefulWidget {
  const VoiceCallPage({Key? key}) : super(key: key);

  @override
  State<VoiceCallPage> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  late final RtcEngine _engine;
  final List<int> _remoteUids = [];

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: agoraAppId));
    await _engine.enableAudio();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          setState(() => _remoteUids.add(uid));
        },
        onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          setState(() => _remoteUids.remove(uid));
        },
      ),
    );

    await _engine.joinChannel(
      token: agoraToken,
      channelId: agoraChannel,
      options: const ChannelMediaOptions(),
      uid: 0,
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool connected = _remoteUids.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF1FDF2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              connected ? Icons.call : Icons.call_end,
              size: 80,
              color: connected ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              connected ? 'Connected' : 'Waiting...',
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
