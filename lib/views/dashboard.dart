import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterfire/utils/styles.dart';
import 'package:flutterfire/views/user_details.dart';
import 'package:flutterfire/main.dart';
import 'package:flutterfire/utils/util.dart';

class DashBoard extends StatefulWidget {
  DashBoard({Key key}) : super(key: key);

  @override
  _DashBoardState createState() {
    return _DashBoardState();
  }
}

class _DashBoardState extends State<DashBoard> {
  SlidableController _slidableController;
  @override
  void initState() {
    _slidableController = SlidableController(
      onSlideAnimationChanged: slideAnimationChanged,
      onSlideIsOpenChanged: slideIsOpenChanged,
    );
    super.initState();
  }

  Animation<double> _rotationAnimation;
  Color _fabColor = Colors.redAccent;
  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 75,
                  ),
                  Text(
                    "User List",
                    textAlign: TextAlign.left,
                    style: themeData(context).textTheme.headline6,
                  ),

                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Swipe from left to edit a user account and swipe from right to delete it.",
                    textAlign: TextAlign.left,
                    style: themeData(context).textTheme.bodyText2,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('users')
              //.orderBy("time", descending: true)
               .snapshots(),
              builder: (BuildContext context,
               AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return new Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SpinKitThreeBounce(
                        color: themeData(context).primaryColor,
                        size: 20.0,
                      ),
                      Text('Loading posts', style: TextStyle
                        (fontSize: 18, color: themeData(context).primaryColor),),
                    ],
                  ),);
                final int feedCount = snapshot.data.documents.length;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: feedCount,
                  itemBuilder: (_, int index) {
                    final DocumentSnapshot document = snapshot.data.documents[index];

                    // document['userRef'] exists here
                    // UserSnapshot[document['userRef']]['userName'} is accessible here

                    return document['full_name'] != null ?  Slidable(
                      delegate: new SlidableDrawerDelegate(),
                      actionExtentRatio: 0.25,
                      child:

                      new Container(
                        child: new ListTile(
                          leading: document['profile_photo_url'] != null ?
                          CircleAvatar(
                            child: ClipOval(
                             clipper: SmallClip(),
                             child: CachedNetworkImage(
                               fadeInCurve: Curves.fastLinearToSlowEaseIn,
                               fadeOutCurve: Curves.easeInOutSine,
                               colorBlendMode: BlendMode.srcOver,
                               color: Colors.black12,
                               // here `bytes` is a Uint8List containing the bytes for the in-memory image

                               imageUrl:
                               document['profile_photo_url'] == null || document['profile_photo_url'] == "" ?
                               "" : document['profile_photo_url'],
                               fit: BoxFit.cover,
                               height: 48,
                               width: 48,
                             )
                            ),
                          ) : CircleAvatar(
                            backgroundColor: themeData(context).accentColor,
                            child: new Text(index.toString()),
                            foregroundColor: themeData(context).primaryColorLight,
                          ),
                          title: new Text(document['full_name']),
                          subtitle: Row(
                            children: [
                              Icon(Icons.mail_outline_rounded, size: 16,color: themeData(context).accentColor,),
                              SizedBox(width:5),
                              Text(document['email'], style: TextStyle(color: themeData(context).accentColor,),)
                            ],
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                             builder: (context) => UserDetails(
                               userID: document['userID'],
                               profilePhotoURL: document['profile_photo_url'],
                               editMode: false,
                             ))
                            );
                          },
                        ),
                      ),
                      actions: <Widget>[
                        new IconSlideAction(
                          caption: 'Edit',
                          foregroundColor: themeData(context).primaryColorLight,
                          color: themeData(context).primaryColorDark,
                          icon: Icons.edit,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                             builder: (context) => UserDetails(
                              userID: document['userID'],
                              profilePhotoURL: document['profile_photo_url'],
                              editMode: true,
                            )));
                          },
                        ),
                      ],
                      secondaryActions: <Widget>[
                        new IconSlideAction(
                          caption: 'Delete',
                          color: Colors.redAccent,
                          icon: Icons.delete,
                          onTap: () async =>
                          await Firestore.instance.runTransaction((Transaction myTransaction) async {
                            await myTransaction.delete(snapshot.data.documents[index].reference);
                          }).whenComplete(() =>
                           Scaffold.of(context).showSnackBar(SnackBar(content: Text("Deleted")))),
                        ),
                      ],
                    ) : Container();
                  },
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FirebaseAuth.instance.signOut().then((result) => Navigator.push(context, MaterialPageRoute(
             builder: (context) => LoginPage()
          )));
        },
        backgroundColor: themeData(context).primaryColorDark,
        child: Icon(Icons.exit_to_app, color: themeData(context).primaryColorLight,),
      ),

    );
  }

  void slideAnimationChanged(Animation<double> slideAnimation) {
    setState(() {
      _rotationAnimation = slideAnimation;
    });
  }

  void slideIsOpenChanged(bool isOpen) {
    setState(() {
      _fabColor = isOpen ? Colors.orange : Colors.redAccent;
    });
  }
}