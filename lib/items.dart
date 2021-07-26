import 'dart:ui';
import 'dart:convert';
import 'package:myuseum/main.dart';
import 'package:myuseum/login.dart';
import 'package:flutter/material.dart';
import 'package:myuseum/Utils/userInfo.dart';
import 'package:myuseum/Utils/getAPI.dart';

//lay out items in two columns and infinite rows
//How to click and open up a specific item

String collectionId = "";
void setCollectionId(String newId) {
  collectionId = newId;
}

class Items {
  String name = "", description = "", itemId = "", collectionId = "";
  List<dynamic> keys = [], tags = [];
  Items(String newName, String newDescription, List<dynamic> newKeys,
      List<dynamic> newTags, String newItemId, String newCollectionId) {
    name = newName;
    description = newDescription;
    keys = newKeys;
    tags = newTags;
    itemId = newItemId;
    collectionId = newCollectionId;
  }
}

//Do we need the room ID for this?
class ItemsRoute extends StatefulWidget {
  final String collectionId;

  const ItemsRoute({Key? key, required this.collectionId}) : super(key: key);
  @override
  _ItemsRouteState createState() => _ItemsRouteState();
}

class _ItemsRouteState extends State<ItemsRoute> {
  //Need to get the list of available items from the backend
  final List<Items> _items = [];
  var index = 0;

  @override
  void initState() {
    super.initState();
    getItems();
  }

  void getItems() {
    Map<String, String> content = {
      'id': widget.collectionId,
    };
    String registerURL = urlBase + "/item/single";
    Register.getRegisterGetStatusCode(registerURL, content).then((value) {
      print('Status Code: ' + value);
      print(getId());
      if (value.compareTo("200") == 0) {
        Register.getRegisterGetBody(registerURL, content).then((value) {
          _items.clear();
          Map<String, dynamic> items = json.decode(value);
          for (int i = 0; i < items['items'].length; i++) {
            _items.add(Items(
                items['items'][i]['name'],
                items['items'][i]['description'],
                items['items'][i]['keys'],
                items['items'][i]['tags'],
                items['items'][i]['itemID'],
                items['items'][i]['collectionId']));
          }
          setState(() {});
        });
      }
    });
  }

  Widget _buildList() {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _items.length *
            2, //ensures the length includes all items with dividers
        itemBuilder: (context, item) {
          if (item.isOdd) return Divider();
          return _buildRow(_items[(item / 2)
              .round()]); //-1 since you can't add the index after building the row
        });
  }

  Widget _buildRow(item) {
    return ListTile(
        title: Text(item.name),
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
        title: Text('Items'),
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
                return NewItemDialog();
              });
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Refresh':
        getItems();
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
/*
  void _editItem(String itemName, String isPrivate) {
    String url = urlBase + "/item/single";
    String content =
        '{"name": "' + itemName + '", "description": ' + description + '}';
    Register.putRegisterGetStatus(url, content).then((value) {
      if (value.compareTo("200") == 0) {
        _ItemsRouteState().getItems().whenComplete(() {
          _ItemsRouteState().setState(() {});
        });
        Navigator.pop(context);
      } else if (value.compareTo("401") == 0) {
        print("Access token invalid");
      } else if (value.compareTo("401") == 0) {
        print("Content already exists");
      } else {
        print(value);
      }
    });
  }*/
}

class DeleteItemDialog extends StatefulWidget {
  final String itemId, itemName;
  const DeleteItemDialog(
      {Key? key, required this.itemId, required this.itemName})
      : super(key: key);

  @override
  _DeleteItemDialogState createState() => new _DeleteItemDialogState();
}

class _DeleteItemDialogState extends State<DeleteItemDialog> {
  void deleteItem(String itemId) {
    String url = urlBase + "/items/single";
    Map<String, String> content = {
      'id': itemId,
    };
    print(content);
    Register.deleteRegisterGetStatusCode(url, content);
  }

  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaY: 10.0, sigmaX: 10.0),
      child: AlertDialog(
        title: Text('Delete Item'),
        actions: <Widget>[
          Text('Are you sure you want to delete ${widget.itemName}?'),
          ElevatedButton(
            onPressed: () {
              deleteItem(widget.itemId);
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

class NewItemDialog extends StatefulWidget {
  _NewItemDialogState createState() => new _NewItemDialogState();
}

class _NewItemDialogState extends State<NewItemDialog> {
  bool isSwitched = false;
  String description = "", itemName = "";
  List<String> keys = [];
  List<String> tags = [];

  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaY: 10.0, sigmaX: 10.0),
      child: AlertDialog(
        title: Text('Add Item'),
        actions: <Widget>[
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter item name';
              else
                return null;
            },
            onChanged: (value) {
              itemName = value;
            },
            decoration: InputDecoration(labelText: 'Item name'),
          ),
          ElevatedButton(
            child: Text('Ok'),
            onPressed: () {
              _addItem();
              _ItemsRouteState().getItems();
              _ItemsRouteState()._buildList();
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  void _addItem() {
    String url = urlBase + "/items/create";
    String content = '{"name": "' +
        itemName +
        '", "description": ' +
        description +
        ', "keys": ' +
        keys.toString() +
        ',  "tags": ' +
        tags.toString() +
        ', "collectionID": ' +
        collectionId +
        '}';
    print(content);
    Register.postRegisterGetStatusCode(url, content).then((value) {
      print(value);
      _ItemsRouteState().getItems();
    });
  }
}
