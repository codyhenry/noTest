import 'dart:ui';
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:myuseum/collections.dart';
import 'package:myuseum/main.dart';
import 'package:myuseum/login.dart';
import 'package:flutter/material.dart';
import 'package:myuseum/Utils/userInfo.dart';
import 'package:myuseum/Utils/getAPI.dart';

class Room {
  String name = "";
  String id = "";
  String private = "";
  Room(String newName, String newId, String newPrivate) {
    name = newName;
    id = newId;
    private = newPrivate;
  }
}

class RoomsRoute extends StatefulWidget {
  @override
  _RoomsRouteState createState() => _RoomsRouteState();
}

class _RoomsRouteState extends State<RoomsRoute> {
  //Need to get the list of available rooms from the backend
  final List<Room> _rooms = [];
  var index = 0;
  String roomName = "", isPrivate = "false";

  @override
  void initState() {
    super.initState();
    getRooms();
  }

  Future getRooms() async {
    Map<String, String> content = {
      'id': getId(),
    };
    String registerURL = urlBase + "/users/rooms";
    Register.getRegisterGetStatusCode(registerURL, content).then((value) {
      if (value.compareTo("200") == 0) {
        Register.getRegisterGetBody(registerURL, content).then((newValue) {
          List rooms = json.decode(newValue);
          _rooms.clear();
          for (int i = 0; i < rooms.length; i++) {
            _rooms.add(Room(rooms[i]['name'], rooms[i]['id'], rooms[i]['private'].toString()));
          }
          setState(() {});
        });
      }
    });
  }

  Widget _buildList() {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _rooms.length *
            2, //ensures the length includes all rooms with dividers
        itemBuilder: (context, item) {
          if (item.isOdd) return Divider();
          return _buildRow(_rooms[(item / 2)
              .round()]); //-1 since you can't add the index after building the row
        });
  }

  Widget _buildRow(room) {
    String changedRoomName = room.name;

    return ListTile(
        title: Text(room.name),
        onTap: () {
          Navigator.push(context,MaterialPageRoute(builder: (context) => CollectionsRoute(roomId: room.id)),);
        },
        trailing: IconButton(
          icon: new Icon(Icons.border_color_rounded),
          tooltip: 'Edit Room',
          color: colorScheme.primary,
          onPressed:
              () /*{
            showDialog(
              context: context,
              builder: (_) =>
                  DeleteRoomDialog(roomName: room.name, roomId: room.id),
            ).whenComplete(() {
              getRooms();
              setState(() {});
            }); //refreshes the list
          },*/
              {
            //Edit Room Popup
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Edit Room'),
                //content: !EDIT ROOM NAME HERE,
                actions: <Widget>[
                  TextFormField(
                    initialValue: changedRoomName,
                    onChanged: (value) {
                      changedRoomName = value;
                    },
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Close'),
                    child: const Text('Close'),
                  ),
                  IconButton(
                    tooltip: 'Delete Room',
                    icon: new Icon(Icons.delete),
                    color: colorScheme.error,
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => DeleteRoomDialog(
                          roomName: room.name, roomId: room.id),
                    ).whenComplete(() {
                      getRooms();
                      setState(() {});
                    }),
                  ),
                  IconButton(
                    tooltip: 'Save Room Edit',
                    icon: new Icon(Icons.save),
                    color: colorScheme.primary,
                    onPressed: () {
                      _editRoom(changedRoomName, room.id, room.private);
                      // Navigator.pop(context);
                    }
                  )
                ],
              ),
            ).whenComplete((){getRooms(); setState(() {});});
          },
        ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Rooms'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Logout', 'Refresh'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: //_buildList(),
          ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _rooms.length *
                  2, //ensures the length includes all rooms with dividers
              itemBuilder: (context, item) {
                if (item.isOdd) return Divider();
                return _buildRow(_rooms[(item / 2).round()]); //-1 since you can't add the index after building the row
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) {
                return NewRoomDialog();
              }).whenComplete(() {
            getRooms();
            setState(() {});
          }); //refreshes the list
        },
        tooltip: 'Add Room',
        child: Icon(Icons.add),
      ),
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Refresh':
        getRooms();
        break;
      case 'Logout':
        _logout();
        break;
    }
  }

  void _logout() {
    //resets the login values to ensure you aren't still logged in
    setId("");
    setEmail("");
    setAccessToken("");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginRoute()),
    );
  }

  void _editRoom(String roomName, String roomId, String isPrivate) {
     String url = urlBase + "/rooms/single";
     Map<String, String> content = {'id': roomId};
     String body = '{"name": "' + roomName + '", "private": ' + isPrivate + '}';
     Register.putRegisterGetStatus(url, content, body).then((value) {
       if(value.compareTo("200") == 0) {
         Navigator.pop(context);
       }
       else if(value.compareTo("401") == 0)
       {
         print("Access token invalid");
       }
       else if(value.compareTo("409") == 0)
       {
         print("Content already exists");
       }
       else
       {
         print(value);
       }
     });
  }
}

class DeleteRoomDialog extends StatefulWidget {
  final String roomId, roomName;
  const DeleteRoomDialog(
      {Key? key, required this.roomId, required this.roomName})
      : super(key: key);

  @override
  _DeleteRoomDialogState createState() => new _DeleteRoomDialogState();
}

class _DeleteRoomDialogState extends State<DeleteRoomDialog> {
  void deleteRoom(String roomId) {
    String url = urlBase + "/rooms/single";
    Map<String, String> content = {
      'id': roomId,
    };
    print(content);
    Register.deleteRegisterGetStatusCode(url, content);
  }

  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaY: 10.0, sigmaX: 10.0),
      child: AlertDialog(
        title: Text('Delete Room'),
        actions: <Widget>[
          Text('Are you sure you want to delete ${widget.roomName}?'),
          ElevatedButton(
            onPressed: () {
              deleteRoom(widget.roomId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(colorScheme.error)),
            child: Text('Delete'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(colorScheme.primary)),
            child: Text('Close'),
          )
        ],
      ),
    );
  }
}

class NewRoomDialog extends StatefulWidget {
  _NewRoomDialogState createState() => new _NewRoomDialogState();
}

class _NewRoomDialogState extends State<NewRoomDialog> {
  bool isSwitched = false;
  String isPrivate = "false", roomName = "";

  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaY: 10.0, sigmaX: 10.0),
      child: AlertDialog(
        title: Text('Add Room'),
        actions: <Widget>[
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter room name';
              else
                return null;
            },
            onChanged: (value) {
              roomName = value;
            },
            decoration: InputDecoration(labelText: 'Room name'),
          ),
          Switch(
            value: isSwitched,
            onChanged: (bool value) {
              setState(() {
                isSwitched = value;
                toggleIsPrivate();
                value = !value;
                print("is Switched is $isSwitched");
                print("private is $isPrivate");
              });
            },
          ),
          if (!isSwitched) Text("public"),
          if (isSwitched) Text("private"),
          ElevatedButton(
            child: Text('Ok'),
            onPressed: () {
              _addRoom();
              _RoomsRouteState().getRooms();
              _RoomsRouteState()._buildList();
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  void _addRoom() {
    String url = urlBase + "/rooms/create";
    String content =
        '{"name": "' + roomName + '", "private": ' + isPrivate + '}';
    print(content);
    Register.postRegisterGetStatusCode(url, content).whenComplete(() {
      _RoomsRouteState().getRooms().whenComplete(() {
        _RoomsRouteState().setState(() {});
      });
    });
  }

  void toggleIsPrivate() {
    print("toggleIsPrivate was called");
    if (isPrivate.compareTo("true") == 0) {
      isPrivate = "false";
      return;
    }
    if (isPrivate.compareTo("false") == 0) {
      isPrivate = "true";
      return;
    }
  }
}
