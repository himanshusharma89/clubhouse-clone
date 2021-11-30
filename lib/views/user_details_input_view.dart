import 'package:clubhouse_clone/meeting/meeting_store.dart';
import 'package:clubhouse_clone/models/user.dart';
import 'package:clubhouse_clone/views/room_view.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class UserDetailsInputView extends StatefulWidget {
  const UserDetailsInputView({Key? key}) : super(key: key);

  @override
  _UserDetailsInputViewState createState() => _UserDetailsInputViewState();
}

class _UserDetailsInputViewState extends State<UserDetailsInputView> {
  TextEditingController usernameTextEditingController = TextEditingController();
  TextEditingController userRoleTextEditingController = TextEditingController();

  String initial = "";
  String userRole = "";

  @override
  void initState() {
    super.initState();
    getPermissions();
    usernameTextEditingController.addListener(getUserNameInitial);
  }

  void getPermissions() async {
    await Permission.microphone.request();

    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }
  }

  @override
  void dispose() {
    usernameTextEditingController.removeListener(getUserNameInitial);
    usernameTextEditingController.dispose();
    userRoleTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('100MS Clubhouse Clone'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Transform.translate(
              offset: const Offset(0, -kToolbarHeight),
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade300,
                        offset: const Offset(3, 3),
                        blurRadius: 5)
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      child:
                          Text(initial, style: const TextStyle(fontSize: 50)),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: Colors.amber.shade200),
                      child: TextField(
                        controller: usernameTextEditingController,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter UserName',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: Colors.amber.shade200),
                      child: TextField(
                        controller: userRoleTextEditingController,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter Role(Listener or Speaker)',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: () {
                          User user = User(
                              userName: usernameTextEditingController.text,
                              userRole: userRoleTextEditingController.text,
                              userId: const Uuid().v1());
                          const roomId = '618d48acbe6c3c0b351510e0';
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => Provider<MeetingStore>(
                                        create: (_) => MeetingStore(),
                                        child: RoomView(
                                            roomTitle: 'Room Title',
                                            roomId: roomId,
                                            user: user),
                                      )));
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22))),
                        child: const Text('Join Room'))
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  getUserNameInitial() {
    if (usernameTextEditingController.text.isNotEmpty) {
      List<String?>? words = usernameTextEditingController.text.split(" ");

      initial = words[0]!.substring(0, 1).toUpperCase();
    } else {
      initial = "";
    }
    setState(() {});
  }
}
