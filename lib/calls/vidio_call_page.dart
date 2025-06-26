import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

const String agoraAppId = '14e959682c9747919c09ec3ebe4accda';
const String agoraToken = ''; // Kosong untuk testing
const String agoraChannel = 'test_channel';

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({Key? key}) : super(key: key);

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
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
    await _engine.enableVideo();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {},
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

  Widget _buildLocal() => AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );

  Widget _buildRemote(int uid) => AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: uid),
          connection: const RtcConnection(channelId: agoraChannel),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Center(
            child: _remoteUids.isEmpty
                ? const Text(
                    'Waiting for user...',
                    style: TextStyle(color: Colors.white),
                  )
                : _buildRemote(_remoteUids.first),
          ),
          Positioned(
            top: 24,
            left: 24,
            width: 120,
            height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildLocal(),
            ),
          ),
        ],
      ),
    );
  }
}
