import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'package:crypto_tutorial/Home/Home.dart' as StartPage;
import 'changePassword.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final user = FirebaseAuth.instance.currentUser;
  String name = '';
  String email = '';

  bool _isEditing = false;
  String _newName = '';

  @override
  void initState() {
    super.initState();
    name = user?.displayName ?? 'Unknown';
    email = user?.email ?? 'Unknown';
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _newName = name;
    });
  }

  Future<void> _saveName() async {
    setState(() {
      _isEditing = false;
      name = _newName;
    });

    try {
      await user?.updateProfile(displayName: _newName);
      // TODO: Handle successful update
    } catch (e) {
      // TODO: Handle error
      print('Failed to update name: $e');
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoURL;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.yellow[700],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white,
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey[300],
                  )
                      : null,
                ),
              ),
              SizedBox(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 8),
                      Expanded(
                        child: _isEditing
                            ? TextFormField(
                          initialValue: name,
                          onChanged: (value) {
                            setState(() {
                              _newName = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter new name',
                          ),
                          style: TextStyle(fontSize: 20),
                        )
                            : Text(
                          name,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 8),
                      _isEditing
                          ? IconButton(
                        onPressed: _saveName,
                        icon: Icon(Icons.save),
                      )
                          : IconButton(
                        onPressed: _startEditing,
                        icon: Icon(Icons.edit),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.email),
                      SizedBox(width: 8),
                      Text(
                        email,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lock),
                          SizedBox(width: 8),
                          Text(
                            'Change Password',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChangePassword()),
                          );
                        },
                        icon: Icon(Icons.edit),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => StartPage.HomePage()),
                        (Route<dynamic> route) => false,
                  );
                },
                icon: Icon(Icons.logout),
                label: Text(
                  'LOG OUT',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.yellow[700],
                  onPrimary: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
