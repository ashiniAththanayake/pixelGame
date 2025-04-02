import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        setState(() {
          _userData = doc.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading user data: $e');
    }
  }

  int calculateLevel(int? exp) {
    exp ??= 0;
    
    if (exp < 0) return 0; 
    if (exp < 300) return 1;
    if (exp < 500) return 2;
    if (exp < 800) return 3;
    if (exp < 1000) return 4;
    if (exp < 1200) return 5;
    if (exp < 1400) return 6;
    if (exp < 1500) return 7;
    if (exp < 1700) return 8;
    if (exp < 2000) return 9;
    return 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/main_menu.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(color: Colors.black.withOpacity(0.4)),
            
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Profile image container
                  Image.asset(
                    'assets/images/profile.png',
                    height: 350,
                    width: 350,
                    fit: BoxFit.contain,
                  ),
                  
                  if (_isLoading)
                    const CircularProgressIndicator(color: Colors.white)
                  else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Name and High Score in same row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                _buildProfileLabel('NAME'),
                                const SizedBox(height: 5),
                                Text(
                                  getFirstName(_userData?['displayName']?.toString()),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 40),
                            Column(
                              children: [
                                _buildProfileLabel('H-SCORE'),
                                const SizedBox(height: 5),
                                Text(
                                  _userData?['highScore']?.toString() ?? '0',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Score and Level in same row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                _buildProfileLabel('SCORE'),
                                const SizedBox(height: 5),
                                Text(
                                  _userData?['exp']?.toString() ?? '0',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 60),
                            Column(
                              children: [
                                _buildProfileLabel('LEVEL'),
                                const SizedBox(height: 5),
                                Text(
                                  calculateLevel(_userData?['exp']).toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
            
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 166, 58, 170).withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  child: const Text(
                    'MAIN MENU',
                    style: TextStyle(
                      fontFamily: 'PixelifySans',
                      fontSize: 20,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileLabel(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 25,
          color: Colors.white,
          fontFamily: 'PixelifySans',
          letterSpacing: 1.0,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String getFirstName(String? displayName) {
    if (displayName == null || displayName.isEmpty) return 'Guest';
    
    // Split by whitespace and take first part
    final parts = displayName.trim().split(' ');
    return parts.first;
  }
}