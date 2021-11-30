import 'package:clubhouse_clone/enum/meeting_flow.dart';
import 'package:clubhouse_clone/meeting/meeting_controller.dart';
import 'package:clubhouse_clone/meeting/meeting_store.dart';
import 'package:clubhouse_clone/models/user.dart';
import 'package:clubhouse_clone/views/chat_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class RoomView extends StatefulWidget {
  final String roomTitle;
  final String roomId;
  final User user;
  const RoomView(
      {required this.roomTitle,
      required this.roomId,
      required this.user,
      Key? key})
      : super(key: key);

  @override
  _RoomViewState createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView> {
  late MeetingStore _meetingStore;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _meetingStore = context.read<MeetingStore>();
    MeetingController meetingController = MeetingController(
        roomUrl: widget.roomId, flow: MeetingFlow.join, user: widget.user);
    _meetingStore.meetingController = meetingController;

    initMeeting();
  }

  initMeeting() async {
    bool ans = await _meetingStore.joinMeeting();
    if (!ans) {
      Navigator.of(context).pop();
    }
    _meetingStore.startListen();
    if (widget.user.userRole == 'listener') {
      if (_meetingStore.isMicOn) {
        _meetingStore.toggleAudio();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.amberAccent.shade100,
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black,
            )),
      ),
      body: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22), topRight: Radius.circular(22))),
        padding:
            const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.roomTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: Observer(builder: (context) {
                if (!_meetingStore.isMeetingStarted) return const SizedBox();
                if (_meetingStore.peers.isEmpty) {
                  return const Center(
                      child: Text('Waiting for other to join!'));
                }
                final filteredList = _meetingStore.peers;
                return GridView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onLongPress: () {
                          _meetingStore.removePeer(filteredList[index]);
                        },
                        onTap: () {
                          _meetingStore.changeRole(
                              peerId: filteredList[index].peerId,
                              roleName: 'speaker');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CircleAvatar(
                            radius: 25,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(filteredList[index].name),
                                Text(filteredList[index].role!.name),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3));
              }),
            ),
            Row(
              children: [
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      _meetingStore.meetingController.leaveMeeting();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '✌️ Leave quietly',
                      style: TextStyle(color: Colors.redAccent),
                    )),
                const Spacer(),
                Observer(builder: (context) {
                  return OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          padding: EdgeInsets.zero,
                          shape: const CircleBorder()),
                      onPressed: () {
                        _meetingStore.toggleAudio();
                      },
                      child: Icon(
                          _meetingStore.isMicOn ? Icons.mic : Icons.mic_off));
                }),
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        padding: EdgeInsets.zero,
                        shape: const CircleBorder()),
                    onPressed: () {
                      _scaffoldKey.currentState!.openEndDrawer();
                    },
                    child: const Icon(Icons.chat))
              ],
            )
          ],
        ),
      ),
      endDrawer: ChatWidget(meetingStore: _meetingStore),
    );
  }
}
