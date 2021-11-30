import 'dart:io';

import 'package:clubhouse_clone/meeting/meeting_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:mobx/mobx.dart';

part 'meeting_store.g.dart';

class MeetingStore = MeetingStoreBase with _$MeetingStore;

abstract class MeetingStoreBase
    with Store
    implements HMSUpdateListener, HMSLogListener {
  @observable
  bool isSpeakerOn = true;

  @observable
  HMSError? error;

  @observable
  HMSRoleChangeRequest? roleChangeRequest;

  @observable
  bool isMeetingStarted = false;
  @observable
  bool isVideoOn = true;
  @observable
  bool isMicOn = true;
  @observable
  bool reconnecting = false;
  @observable
  bool reconnected = false;
  @observable
  HMSTrackChangeRequest? hmsTrackChangeRequest;

  late MeetingController meetingController;

  @observable
  ObservableList<HMSPeer> peers = ObservableList.of([]);

  @observable
  HMSPeer? localPeer;

  @observable
  HMSTrack? screenTrack;

  @observable
  ObservableList<HMSTrack> tracks = ObservableList.of([]);

  @observable
  ObservableList<HMSMessage> messages = ObservableList.of([]);

  @observable
  ObservableMap<String, HMSTrackUpdate> trackStatus = ObservableMap.of({});

  @observable
  ObservableMap<String, HMSTrackUpdate> audioTrackStatus = ObservableMap.of({});

  @action
  void startListen() {
    meetingController.addMeetingListener(this);
    //startHMSLogger(HMSLogLevel.DEBUG, HMSLogLevel.DEBUG);
    //addLogsListener();
  }

  @action
  void removeListener() {
    meetingController.removeMeetingListener(this);
    // removeLogsListener();
  }

  @action
  void toggleSpeaker() {
    debugPrint("toggleSpeaker");
    if (isSpeakerOn) {
      muteAll();
    } else {
      unMuteAll();
    }
    isSpeakerOn = !isSpeakerOn;
  }

  @action
  Future<void> toggleAudio() async {
    await meetingController.switchAudio(isOn: isMicOn);
    isMicOn = !isMicOn;
  }

  @action
  void removePeer(HMSPeer peer) {
    peers.remove(peer);
    removeTrackWithPeerId(peer.peerId);
  }

  @action
  void addPeer(HMSPeer peer) {
    if (!peers.contains(peer)) peers.add(peer);
  }

  @action
  void removeTrackWithTrackId(String trackId) {
    tracks.removeWhere((eachTrack) => eachTrack.trackId == trackId);
  }

  @action
  void removeTrackWithPeerId(String peerId) {
    tracks.removeWhere((eachTrack) => eachTrack.peer?.peerId == peerId);
  }

  @action
  void addTrack(HMSTrack track) {
    if (tracks.contains(track)) removeTrackWithTrackId(track.trackId);

    if (track.source == 'SCREEN') {
      tracks.insert(0, track);
    } else {
      tracks.insert(tracks.length, track);
    }
    debugPrint("addTrack $track");
  }

  @action
  void onRoleUpdated(int index, HMSPeer peer) {
    peers[index] = peer;
  }

  @action
  Future<bool> joinMeeting() async {
    bool ans = await meetingController.joinMeeting();
    if (!ans) return false;
    isMeetingStarted = true;
    return true;
  }

  @action
  Future<void> sendMessage(String message) async {
    await meetingController.sendMessage(message);
  }

  @action
  void updateError(HMSError error) {
    this.error = error;
  }

  @action
  void updateRoleChangeRequest(HMSRoleChangeRequest roleChangeRequest) {
    this.roleChangeRequest = roleChangeRequest;
  }

  @action
  void addMessage(HMSMessage message) {
    messages.add(message);
  }

  @action
  void addTrackChangeRequestInstance(
      HMSTrackChangeRequest hmsTrackChangeRequest) {
    this.hmsTrackChangeRequest = hmsTrackChangeRequest;
  }

  @action
  void updatePeerAt(peer) {
    int index = peers.indexOf(peer);
    peers.removeAt(index);
    peers.insert(index, peer);
  }

  @override
  void onJoin({required HMSRoom room}) {
    if (Platform.isAndroid) {
      debugPrint("members ${room.peers!.length}");
      for (HMSPeer each in room.peers!) {
        if (each.isLocal) {
          localPeer = each;
          addPeer(localPeer!);
          debugPrint('on join ${localPeer!.peerId}');
          break;
        }
      }
    } else {
      for (HMSPeer each in room.peers!) {
        addPeer(each);
        if (each.isLocal) {
          localPeer = each;
          debugPrint('on join ${localPeer!.name}  ${localPeer!.peerId}');
          if (each.videoTrack != null) {
            trackStatus[each.videoTrack!.trackId] = HMSTrackUpdate.trackMuted;
            tracks.insert(0, each.videoTrack!);
          }
        } else {
          if (each.videoTrack != null) {
            trackStatus[each.videoTrack!.trackId] = HMSTrackUpdate.trackMuted;
            tracks.insert(0, each.videoTrack!);
          }
        }
      }
    }
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
    debugPrint('on room update');
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    peerOperation(peer, update);
  }

  @override
  void onTrackUpdate(
      {required HMSTrack track,
      required HMSTrackUpdate trackUpdate,
      required HMSPeer peer}) {
    debugPrint("onTrackUpdateFlutter $track ${peer.isLocal}");
    if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
      if (isSpeakerOn) {
        unMuteAll();
      } else {
        muteAll();
      }
      audioTrackStatus[track.trackId] = trackUpdate;
      if (peer.isLocal && trackUpdate == HMSTrackUpdate.trackMuted) {
        isMicOn = false;
      }
      return;
    }
    trackStatus[track.trackId] =
        track.isMute ? HMSTrackUpdate.trackMuted : HMSTrackUpdate.trackUnMuted;

    debugPrint("onTrackUpdate ${trackStatus[track.trackId]}");

    if (peer.isLocal) {
      localPeer = peer;
      if (track.isMute) {
        isVideoOn = false;
      }

      if (Platform.isAndroid) {
        int screenShareIndex = tracks.indexWhere((element) {
          return element.source == 'SCREEN';
        });
        debugPrint("ScreenShare $screenShareIndex");
        if (screenShareIndex == -1) {
          tracks.insert(0, track);
        } else {
          tracks.insert(1, track);
        }
      }
    } else {
      peerOperationWithTrack(peer, trackUpdate, track);
    }
  }

  @override
  void onError({required HMSError error}) {
    updateError(error);
  }

  @override
  void onMessage({required HMSMessage message}) {
    addMessage(message);
  }

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {
    debugPrint("onRoleChangeRequest Flutter");
    updateRoleChangeRequest(roleChangeRequest);
  }

  HMSTrack? previousHighestVideoTrack;
  int previousHighestIndex = -1;

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {
    if (updateSpeakers.isEmpty) return;
    HMSSpeaker highestAudioSpeaker = updateSpeakers[0];
    debugPrint("onUpdateSpeakerFlutter ${highestAudioSpeaker.peer.name}");
    int newHighestIndex = tracks.indexWhere(
        (element) => element.peer?.peerId == highestAudioSpeaker.peer.peerId);
    if (newHighestIndex == -1) return;

    if (previousHighestVideoTrack != null) {
      HMSTrack newPreviousTrack =
          HMSTrack.copyWith(false, track: previousHighestVideoTrack!);
      if (previousHighestIndex != -1) {
        tracks.removeAt(previousHighestIndex);
        tracks.insert(previousHighestIndex, newPreviousTrack);
      }
    }
    HMSTrack highestAudioSpeakerVideoTrack = tracks[newHighestIndex];
    HMSTrack newHighestTrack =
        HMSTrack.copyWith(true, track: highestAudioSpeakerVideoTrack);
    tracks.removeAt(newHighestIndex);
    tracks.insert(newHighestIndex, newHighestTrack);
    previousHighestVideoTrack = newHighestTrack;
    previousHighestIndex = newHighestIndex;
  }

  @override
  void onReconnecting() {
    reconnecting = true;
  }

  @override
  void onReconnected() {
    reconnecting = false;
    reconnected = true;
  }

  int trackChange = -1;

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {
    int isVideoTrack =
        hmsTrackChangeRequest.track.kind == HMSTrackKind.kHMSTrackKindVideo
            ? 1
            : 0;
    trackChange = isVideoTrack;
    debugPrint("flutteronChangeTrack $trackChange");
    addTrackChangeRequestInstance(hmsTrackChangeRequest);
  }

  void changeTracks() {
    debugPrint("flutteronChangeTracks $trackChange");
    if (trackChange == 0) {
      toggleAudio();
    }
  }

  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
    meetingController.leaveMeeting();
  }

  void changeRole(
      {required String peerId,
      required String roleName,
      bool forceChange = false}) {
    meetingController.changeRole(
        roleName: roleName, peerId: peerId, forceChange: forceChange);
  }

  Future<List<HMSRole>> getRoles() async {
    return meetingController.getRoles();
  }

  @action
  void peerOperation(HMSPeer peer, HMSPeerUpdate update) {
    switch (update) {
      case HMSPeerUpdate.peerJoined:
        debugPrint('peer joined');
        addPeer(peer);
        break;
      case HMSPeerUpdate.peerLeft:
        debugPrint('peer left');
        removePeer(peer);

        break;
      case HMSPeerUpdate.peerKnocked:
        // removePeer(peer);
        break;
      case HMSPeerUpdate.audioToggled:
        debugPrint('Peer audio toggled');
        break;
      case HMSPeerUpdate.videoToggled:
        debugPrint('Peer video toggled');
        break;
      case HMSPeerUpdate.roleUpdated:
        debugPrint('${peers.indexOf(peer)}');
        updatePeerAt(peer);
        break;
      case HMSPeerUpdate.defaultUpdate:
        debugPrint("Some default update or untouched case");
        break;
      default:
        debugPrint("Some default update or untouched case");
    }
  }

  @action
  void peerOperationWithTrack(
      HMSPeer peer, HMSTrackUpdate update, HMSTrack track) {
    debugPrint("onTrackUpdateFlutter $update ${peer.name} update");

    switch (update) {
      case HMSTrackUpdate.trackAdded:
        addTrack(track);
        break;
      case HMSTrackUpdate.trackRemoved:
        removeTrackWithTrackId(track.trackId);
        break;
      case HMSTrackUpdate.trackMuted:
        trackStatus[track.trackId] = HMSTrackUpdate.trackMuted;
        break;
      case HMSTrackUpdate.trackUnMuted:
        trackStatus[track.trackId] = HMSTrackUpdate.trackUnMuted;
        break;
      case HMSTrackUpdate.trackDescriptionChanged:
        break;
      case HMSTrackUpdate.trackDegraded:
        break;
      case HMSTrackUpdate.trackRestored:
        break;
      case HMSTrackUpdate.defaultUpdate:
        break;
      default:
        debugPrint("Some default update or untouched case");
    }
  }

  Future<bool> endRoom(bool lock) async {
    return await meetingController.endRoom(lock);
  }

  void leaveMeeting() {
    meetingController.leaveMeeting();
    removeListener();
  }

  void removePeerFromRoom(String peerId) {
    meetingController.removePeer(peerId);
  }

  void muteAll() {
    meetingController.muteAll();
  }

  void unMuteAll() {
    meetingController.unMuteAll();
  }

  @override
  void onLogMessage({required dynamic HMSLog}) {
    debugPrint(HMSLog.toString() + "onLogMessageFlutter");
  }
}
