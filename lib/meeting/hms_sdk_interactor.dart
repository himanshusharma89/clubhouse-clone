import 'package:hmssdk_flutter/hmssdk_flutter.dart';

class HMSSDKInteractor {
  late HMSConfig config;
  late List<HMSMessage> messages;
  late HMSMeeting _meeting;

  HMSSDKInteractor() {
    _meeting = HMSMeeting();
  }

  Future<void> joinMeeting(
      {required HMSConfig config,
      required bool isProdLink,
      required bool setWebRtcLogs}) async {
    this.config = config;
    await _meeting.joinMeeting(
        config: this.config,
        isProdLink: isProdLink,
        // endPoint: Constant.getTokenURL,
        setWebrtcLogs: setWebRtcLogs);
  }

  Future<void> leaveMeeting() async {
    return await _meeting.leaveMeeting();
  }

  Future<void> switchAudio({bool isOn = false}) async {
    return await _meeting.switchAudio(isOn: isOn);
  }

  Future<void> sendMessage(String message) async {
    return await _meeting.sendMessage(message);
  }

  Future<void> sendDirectMessage(String message, String peerId) async {
    return await _meeting.sendDirectMessage(message, peerId);
  }

  Future<void> sendGroupMessage(String message, String roleName) async {
    return await _meeting.sendGroupMessage(message, roleName);
  }

  void addMeetingListener(HMSUpdateListener listener) {
    _meeting.addMeetingListener(listener);
  }

  void removeMeetingListener(HMSUpdateListener listener) {
    _meeting.removeMeetingListener(listener);
  }

  Future<bool> endRoom(bool lock) async {
    bool ended = await _meeting.endRoom(lock);
    return ended;
  }

  void removePeer(String peerId) {
    _meeting.removePeer(peerId);
  }

  void changeRole(
      {required String peerId,
      required String roleName,
      bool forceChange = false}) {
    _meeting.changeRole(
        peerId: peerId, roleName: roleName, forceChange: forceChange);
  }

  Future<List<HMSRole>> getRoles() async {
    return _meeting.getRoles();
  }

  Future<bool> isAudioMute(HMSPeer? peer) async {
    bool isMute = await _meeting.isAudioMute(peer);
    return isMute;
  }

  void muteAll() {
    _meeting.muteAll();
  }

  void unMuteAll() {
    _meeting.unMuteAll();
  }
}
