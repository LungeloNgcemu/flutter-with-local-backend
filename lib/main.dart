import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:realtime/socket.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Real Time',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Realtime());
  }
}

class Realtime extends StatefulWidget {
  const Realtime({super.key});

  @override
  State<Realtime> createState() => _RealtimeState();
}

class _RealtimeState extends State<Realtime> {
  StreamController<List<Map<String, dynamic>>> socketController =
      StreamController<List<Map<String, dynamic>>>();

  Connection conn = Connection();

  TextEditingController controller = TextEditingController();

  ScrollController scrollController = ScrollController();


  @override
  void initState() {
    super.initState();

    conn.connectSocket(socketController,setState,scrollController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          height: 800,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder(
                  stream: socketController.stream,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.active) {
                      final data = snap.data?.reversed;

                      print(data?.length);

                      return Container(
                        height: 720,
                        color: Colors.white,
                        child: ListView.builder(
                          reverse: true,
                          controller: scrollController,
                          itemCount:data?.length ?? 0 ,
                            itemBuilder: (context, index) {

                          final user = data?.elementAt(index)['user'] ?? "";
                          final message = data?.elementAt(index)['message'] ?? "";

                          return ListTile(
                            title: Text('$user'),
                             subtitle: Text("$message"),
                          );
                        }),
                      );
                    }
                    return SizedBox();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 15),
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextField(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10.0),
                            ),
                            controller: controller,
                          ),
                        ),
                        IconButton(onPressed: (){

                          final Map<dynamic,dynamic> object = {
                            "user": "Lungelo",
                            "messageId": 666,
                            "message": controller.text
                          };

                          final messageJson = json.encode(object);

                          conn.socket.emit('message',messageJson);

                          controller.clear();
                          FocusManager.instance.primaryFocus?.unfocus();

                        }, icon: Icon(Icons.send_outlined))
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
