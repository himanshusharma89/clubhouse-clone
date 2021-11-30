import 'package:clubhouse_clone/models/user.dart';
import 'package:clubhouse_clone/views/chat_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
            const Expanded(
                child: Center(child: Text('Waiting for other to join!'))),
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
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '✌️ Leave quietly',
                      style: TextStyle(color: Colors.redAccent),
                    )),
                const Spacer(),
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        padding: EdgeInsets.zero,
                        shape: const CircleBorder()),
                    onPressed: () {},
                    child: Icon(Icons.mic)),
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
      endDrawer: const ChatView(),
    );
  }
}
