import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukin_cafeteria/Ui/Widget/Page_Title_widget.dart';
import '../../Data/Model/user_model.dart';
import '../Provider/user_provider.dart';
import '../Widget/appbar_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromKeyPassword = GlobalKey<FormState>();


  late TextEditingController _nameController= TextEditingController();
  late TextEditingController _emailController= TextEditingController();
  late TextEditingController _phoneController= TextEditingController();
  late TextEditingController _cafeteriaController= TextEditingController();
  late TextEditingController _locationController= TextEditingController();
  late TextEditingController _passwordController= TextEditingController();
  late TextEditingController _confirmPasswordController= TextEditingController();
  late TextEditingController _oldPasswordController= TextEditingController();

  bool _isPasswordVisible = false;
  bool _changePasswordLoading = false;
  bool _updateProfileLoading = false;
  bool _userLoading = false;


  UserProvider? _userProvider;
  UserModel? _currentUser;


  @override
  void initState() {
    super.initState();

    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _userLoading = true);

    _currentUser = _userProvider?.currentUser;

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      print("No logged in user!");
      setState(() => _userLoading = false);
      return;
    }

    if (_currentUser == null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!doc.exists) {
        print("User document not found in Firestore");
        setState(() => _userLoading = false);
        return;
      }

      _currentUser = UserModel.fromMap(doc.data()!);

      // Save in provider so it can be reused elsewhere
      await _userProvider!.updateUser(_currentUser!);
    }

    // Fill controllers
    _nameController.text = _currentUser!.name;
    _emailController.text = _currentUser!.email;
    _phoneController.text = _currentUser!.phone;
    _cafeteriaController.text = _currentUser!.cafeteriaName;
    _locationController.text = _currentUser!.location;

    setState(() => _userLoading = false);
  }

  /// Save profile using _currentUser
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user found")),
      );
      return;
    }

    setState(() => _updateProfileLoading = true);

    try {
      final updatedUser = UserModel(
        uid: _currentUser!.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        cafeteriaName: _cafeteriaController.text.trim(),
        location: _locationController.text.trim(),
        createdAt: _currentUser!.createdAt,
      );

      // Update provider and Firestore
      await _userProvider!.updateUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    } finally {
      setState(() => _updateProfileLoading = false);
    }
  }


  Future<void> _changePassword() async {
    if (!_fromKeyPassword.currentState!.validate()) return;

    setState(() => _changePasswordLoading = true);

    final newPassword = _passwordController.text.trim();
    final oldPassword = _oldPasswordController.text.trim();


    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final credential = EmailAuthProvider.credential(
        email: firebaseUser!.email!,
        password: oldPassword,
      );
      await firebaseUser.reauthenticateWithCredential(credential);

      if (firebaseUser != null) {
        await firebaseUser.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password updated successfully")),
        );
      }
      setState(() => _changePasswordLoading = false);
      _oldPasswordController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _isPasswordVisible = false;
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Your old password is incorrect")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update password: $e")),
        );
      }
      setState(() => _changePasswordLoading = false);
    }
    catch (e) {
      setState(() => _changePasswordLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update password: $e")),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppbarWidget(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Visibility(
                    visible: _userLoading == false,
                    replacement: const Center(child: CircularProgressIndicator()),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.green.shade300,
                            child: Text(
                              _nameController.text.isNotEmpty
                                  ? _nameController.text[0].toUpperCase()
                                  : '',
                              style: const TextStyle(fontSize: 40, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: "Full Name",
                            border: OutlineInputBorder(),
                          ),
                          validator: (String? value){
                            if (value?.trim().isEmpty ?? true) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _emailController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: "Phone",
                              border: OutlineInputBorder(),
                            ),
                            validator: (String? value){
                              if (value?.trim().isEmpty ?? true) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            }),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _cafeteriaController,
                          decoration: const InputDecoration(
                            labelText: "Cafeteria Name",
                            border: OutlineInputBorder(),
                          ),
                          validator: (String? value){
                            if (value?.trim().isEmpty ?? true) {
                              return 'Please enter your cafeteria name';
                            }
                            return null;
                          },),
                        const SizedBox(height: 12),

                        TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: "Location",
                              border: OutlineInputBorder(),
                            ),
                            validator: (String? value){
                              if (value?.trim().isEmpty ?? true) {
                                return 'Please enter your location';
                              }
                              return null;
                            }
                        ),
                        const SizedBox(height: 12),

                        Visibility(
                          visible: _updateProfileLoading == false,
                          replacement: CircularProgressIndicator(),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Update Profile",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                                  ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Form(
                key: _fromKeyPassword,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PageTitleWidget(title: 'Change Password',),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _oldPasswordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "Old Password",
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter your old password";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "New Password",
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                          validator: (String? value){
                            if (value?.trim().isEmpty ?? true) {
                              return 'Please enter your password';
                            } else if (value!.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          }
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (String? value){
                            if (value?.trim().isEmpty ?? true) {
                              return 'Please enter your password';
                            } else if (value!.length < 6) {
                              return 'Password must be at least 6 characters long';
                            } else if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          }
                      ),
                      SizedBox(height: 12),
                      Visibility(
                        visible: _changePasswordLoading == false,
                        replacement: CircularProgressIndicator(),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Update Password",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cafeteriaController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _oldPasswordController.dispose();
    super.dispose();
  }
}

