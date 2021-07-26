import 'dart:convert';
import 'dart:ui';
import 'package:myuseum/login.dart';
import 'package:flutter/material.dart';
import 'package:myuseum/Utils/userInfo.dart';
import 'package:myuseum/Utils/getAPI.dart';

String roomId = "";

class Collections {
  String name = "", private = "", roomId = "", collectionId = "";
  List <dynamic> keys = [], tags = [];
  Collections(String newName, List <dynamic> newKeys, String newPrivate, String newRoomId, List <dynamic> newTags, String newCollectionId) {
    name = newName;
    keys = newKeys;
    private = newPrivate;
    roomId = newRoomId;
    tags = newTags;
    collectionId = newCollectionId;
  }
}

class CollectionsRoute extends StatefulWidget {
  final String roomId;

  const CollectionsRoute(
      {Key? key, required this.roomId})
      : super(key: key);
  @override
  _CollectionsRouteState createState() => _CollectionsRouteState();
}

class _CollectionsRouteState extends State<CollectionsRoute> {
  //Need to get the list of available rooms from the backend
  final List<Collections> _collections = [];
  var index = 0;

  @override
  void initState() {
    super.initState();
    getCollections();
  }

  void getCollections() {
    Map<String, String> content = {
      'id': widget.roomId,
    };
    String registerURL = urlBase + "/rooms/single";
    Register.getRegisterGetStatusCode(registerURL, content).then((value) {
      print('Status Code: ' + value);
      print(getId());
      if (value.compareTo("200") == 0) {
        Register.getRegisterGetBody(registerURL, content).then((value) {
          _collections.clear();
          Map<String, dynamic> collections = json.decode(value);
          for(int i = 0; i < collections['collections'].length; i++)
          {
            _collections.add(Collections(collections['collections'][i]['name'], collections['collections'][i]['keys'], collections['collections'][i]['private'].toString(), collections['collections'][i]['roomID'], collections['collections'][i]['tags'], collections['collections'][i]['id']));
          }
          setState(() {});
        });
      }
    });
  }

  Widget _buildList() {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _collections.length *
            2, //ensures the length includes all rooms with dividers
        itemBuilder: (context, item) {
          if (item.isOdd) return Divider();
          return _buildRow(_collections[(item/2).round()]); //-1 since you can't add the index after building the row
        });
  }

  Widget _buildRow(collection) {
    return ListTile(
        title: Text(collection.name),
        trailing: Icon(Icons.edit),
        onTap: () {
          //Edit the room name
        });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Collections'),
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
      body: _buildList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) {
                return NewCollectionDialog(roomId: widget.roomId);
              }).whenComplete(() {setState(() {getCollections();});});
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Refresh':
        getCollections();
        break;
      case 'Logout':
        _logout();
        break;
    }
  }

  void _logout() {
    //resets the login values to ensure you aren't still logged in
    id = "";
    email = "";
    accessToken = "";
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginRoute()),
    );
  }
}

class NewCollectionDialog extends StatefulWidget {
  final String roomId;
  const NewCollectionDialog({Key? key, required this.roomId}) :super(key: key);
  _NewCollectionDialogState createState() => new _NewCollectionDialogState();
}

class _NewCollectionDialogState extends State<NewCollectionDialog> {
  bool isSwitched = false;
  String collectionName = "", isPrivate = "false";
  List <String> keys = [];

  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaY: 10.0, sigmaX: 10.0),
      child: AlertDialog(
        title: Text('Add Room'),
        actions: <Widget>[
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter collection name';
              else
                return null;
            },
            onChanged: (value) {
              collectionName = value;
            },
            decoration: InputDecoration(labelText: 'Collection name'),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Tags, separate with a ", "'),
            onChanged: (value) {
              keys = value.split(', ');
            }
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
              _addCollection();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _addCollection() {
    String url = urlBase + "/collections/create";
    String content = '{"name": "' + collectionName + '", "keys": ' + keys.toString() + ',  "private": ' + isPrivate + ', "roomID": "' + widget.roomId + '"}';
    print(content);
    Register.postRegisterGetStatusCode(url, content).then((value) {
      if(value.compareTo("200") == 0)
        Navigator.pop(context);
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