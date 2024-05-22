import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Connection {
  late IO.Socket socket;
  List<Map<String, dynamic>> convert = [];
  List<Map<String, dynamic>> messages = [];

  void newListInit(data,Function(void Function()) setState) {

    convert.clear();

    for (var item in data) {
      bool exists = false;

      for (var map in convert) {
        print(map);
        if (map['messageId'.toString()] == item['messageId'.toString()]) {
          exists = true;
          break;
        }
      }

      if (!exists) {
        Map<String, dynamic> object = {
          "user": item['user'].toString(),
          "messageId": item['messageId'].toString(),
          "message": item['message']
        };

        convert.add(object);

        print("Added: $object");

        setState((){

        });
      }
    };
  }

  void updateList(item) {
    Map<String, dynamic> object = {};

    object = {
      "user": item['user'].toString(),
      "messageId": item['messageId'.toString()],
      "message": item['message']
    };

    convert.add(object as Map<String, dynamic>);

    print("this $object");
  }

  void connectSocket(
      StreamController<List<Map<String, dynamic>>> socketController,setState,ScrollController scrollController) {
    try {
      // Init
      socket = IO.io('http://192.168.43.52:3000', <String, dynamic>{
        "transports": ["websocket"],
        "autoConnect": false,
      });

      //Connnect
      socket.connect();

      //Check
      print(socket.connected);

      // Listen for connect event
      socket.onConnect((data) {
        print('Connected to server');
      });

      print(socket.connected);

      socket.on('connection', (data) {
        newListInit(data,setState);

        socketController.add(convert);

        scrollController.animateTo(
          - scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );

      });

      socket.on("message", (data) {
        updateList(data);
        socketController.add(convert);
        scrollController.animateTo(
          - scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });

      // Listen for disconnect event
      socket.onDisconnect((_) {
        print('Disconnected from server');
      });
    } catch (error) {
      print("Error here: $error");
    }
  }
}
