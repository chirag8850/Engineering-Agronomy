import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:login/models/user_model.dart';
import 'package:login/view/screens/gps_measurement.dart';
import 'package:login/view/screens/polygone_screen.dart';
import 'package:login/view/screens/login_screen.dart';
import 'package:login/view/screens/profile.dart';


class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            // color:  Color.fromARGB(255, 4, 185, 59),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/profile-bg3.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    width:100,
                    height: 100,
                    margin: EdgeInsets.only(
                      top: 30,
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=580&q=80'
                        ),
                        fit: BoxFit.fill
                      )
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${loggedInUser.fullName}'.toUpperCase(),
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'RobotoMono',
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5), // Add a gap of 10 pixels
                      Text(
                        '${loggedInUser.phoneNumber}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${loggedInUser.email}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile',
            style: TextStyle(
              fontSize: 18
              ),
            ),
            onTap: (){
        //       Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => ImagePickerScreen()),
        // );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings',
            style: TextStyle(
              fontSize: 18
              ),
            ),
            onTap: null,
          ),
          ListTile(
            leading: Icon(Icons.search),
            title: Text('Land Measurement',
            style: TextStyle(
              fontSize: 18
              ),
            ),
            onTap: (){
              Navigator.of(context).pop();
               Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PolygonScreen()),
        );
            },
          ),
          ListTile(
            leading: Icon(Icons.gps_fixed),
            title: Text('GPS Measurement',
            style: TextStyle(
              fontSize: 18
              ),
            ),
            onTap: (){
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GpsMeasure()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout',
            style: TextStyle(
              fontSize: 18
              ),
            ),
            onTap: () async{
                logout(context);
            }
          ),
        ]
      ),
    );
  }
 // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Fluttertoast.showToast(msg: "Logout Successful");
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }

}