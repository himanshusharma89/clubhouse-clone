import 'package:clubhouse_clone/enum/meeting_flow.dart';
import 'package:clubhouse_clone/meeting/hms_sdk_interactor.dart';
import 'package:clubhouse_clone/models/user.dart';
import 'package:clubhouse_clone/services/token_service.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

class MeetingController {
  final String roomUrl;
  final User user;
  final MeetingFlow flow;
  final HMSSDKInteractor? _hmsSdkInteractor;

  MeetingController(
      {required this.roomUrl, required this.user, required this.flow})
      : _hmsSdkInteractor = HMSSDKInteractor();

  Future<bool> joinMeeting() async {
    String? token =
        await TokenService.getToken(userId: user.userName, roomId: roomUrl);
    if (token == null) return false;

    HMSConfig config = HMSConfig(
      userId: user.userId,
      roomId: roomUrl,
      authToken: token,
      userName: user.userName,
    );
    await _hmsSdkInteractor?.joinMeeting(
        config: config, isProdLink: true, setWebRtcLogs: true);
    return true;
  }

  void leaveMeeting() {
    _hmsSdkInteractor?.leaveMeeting();
  }

  Future<void> switchAudio({bool isOn = false}) async {
    return await _hmsSdkInteractor?.switchAudio(isOn: isOn);
  }

  Future<void> sendMessage(String message) async {
    return await _hmsSdkInteractor?.sendMessage(message);
  }

  Future<void> sendDirectMessage(String message, String peerId) async {
    return await _hmsSdkInteractor?.sendDirectMessage(message, peerId);
  }

  Future<void> sendGroupMessage(String message, String roleName) async {
    return await _hmsSdkInteractor?.sendGroupMessage(message, roleName);
  }

  void addMeetingListener(HMSUpdateListener listener) {
    _hmsSdkInteractor?.addMeetingListener(listener);
  }

  void removeMeetingListener(HMSUpdateListener listener) {
    _hmsSdkInteractor?.removeMeetingListener(listener);
  }

  void changeRole(
      {required String peerId,
      required String roleName,
      bool forceChange = false}) {
    _hmsSdkInteractor?.changeRole(
        peerId: peerId, roleName: roleName, forceChange: forceChange);
  }

  Future<List<HMSRole>> getRoles() async {
    return _hmsSdkInteractor!.getRoles();
  }

  Future<bool> isAudioMute(HMSPeer? peer) async {
    bool isMute = await _hmsSdkInteractor!.isAudioMute(peer);
    return isMute;
  }

  Future<bool> endRoom(bool lock) async {
    return (await _hmsSdkInteractor?.endRoom(lock))!;
  }

  void removePeer(String peerId) {
    _hmsSdkInteractor?.removePeer(peerId);
  }

  void unMuteAll() {
    _hmsSdkInteractor?.unMuteAll();
  }

  void muteAll() {
    _hmsSdkInteractor?.muteAll();
  }
}
