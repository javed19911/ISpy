import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class ActiveUsers extends StatefulWidget {
  final String user;

  const ActiveUsers({Key? key, required this.user}) : super(key: key);

  @override
  _ActiveUsersState createState() => _ActiveUsersState();
}

class _ActiveUsersState extends State<ActiveUsers> {
  final databaseReference = FirebaseDatabase.instance.ref().child("users");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("I-Spy"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text("Active Users",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                )),
            Flexible(
              child: FirebaseAnimatedList(
                // key: ValueKey<bool>(_anchorToBottom),
                query: databaseReference,
                // reverse: _anchorToBottom,
                itemBuilder: (context, snapshot, animation, index) {
                  var name = snapshot.child("name").value;
                  if (widget.user != name) {
                    return SizeTransition(
                        sizeFactor: animation,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 3, vertical: 8),
                              child: Row(children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text(name
                                      .toString()
                                      .characters
                                      .first
                                      .toUpperCase()),
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(10),
                                  ),
                                ),
                                Expanded(child: Text('$name')),
                                IconButton(
                                  icon: const Icon(Icons.message),
                                  onPressed: () {
                                    Navigator.pushNamed(context, "/user_chat",
                                        arguments: "${widget.user}_$name");
                                  },
                                ),
                              ]),
                            ),
                          ),
                        ));
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
