import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

class SoundRecorder {
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecorderInitialized = false;

  bool get isRecording => _audioRecorder!.isRecording;
  Future init() async {
    _audioRecorder = FlutterSoundRecorder();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Micropphone Permission not granted');
    }
    await _audioRecorder!.openAudioSession();
    _isRecorderInitialized = true;
  }

  void dispose() {
    if (_isRecorderInitialized) return;
    _audioRecorder!.closeAudioSession();
    _audioRecorder = null;
    _isRecorderInitialized = false;
  }

  Future record(final String path) async {
    if (!_isRecorderInitialized) return;
    await _audioRecorder!.startRecorder(toFile: path);
  }

  Future stop() async {
    if (!_isRecorderInitialized) return;
    await _audioRecorder!.stopRecorder();
  }

  Future toggleRecording(final String path) async {
    if (_audioRecorder!.isStopped) {
      await record(path);
    } else {
      await stop();
    }
  }
}
