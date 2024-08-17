import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_project/pages/edit_profil_page.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
      });
    }
  }

  Future<void> _navigateToEditProfile() async {
    bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage()),
    );
    if (updated == true) {
      _loadUserData(); // Refresh profil setelah kembali dari EditProfilePage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _navigateToEditProfile,
          ),
        ],
        backgroundColor: Colors.green[800],
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  _buildProfileInfo(),
                  SizedBox(height: 20),
                  _buildUpdateProfileWarning(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 200,
          color: Colors.green[800],
        ),
        Positioned(
          top: 50,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            backgroundImage: userData!['photoUrl'] != null
                ? NetworkImage(userData!['photoUrl'])
                : AssetImage('assets/default_avatar.png') as ImageProvider,
          ),
        ),
        Positioned(
          bottom: 20,
          child: Text(
            userData!['name'] ?? 'Nama Pengguna',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(Icons.email, color: Colors.green[800]),
            title: Text('Email'),
            subtitle: Text(userData!['email'] ?? 'Belum diisi'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.phone, color: Colors.green[800]),
            title: Text('Nomor HP'),
            subtitle: Text(userData!['phone'] ?? 'Belum diisi'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.location_on, color: Colors.green[800]),
            title: Text('Alamat'),
            subtitle: Text(userData!['address'] ?? 'Belum diisi'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateProfileWarning() {
    return userData!['name'] == null ||
            userData!['phone'] == null ||
            userData!['email'] == null ||
            userData!['address'] == null
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Profil Anda belum lengkap. Silakan perbarui profil Anda.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.green[800]),
                    onPressed: _navigateToEditProfile,
                  ),
                ],
              ),
            ),
          )
        : SizedBox.shrink();
  }
}
