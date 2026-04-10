import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:rukin_cafeteria/features/auth/presentation/screens/singup_screen.dart';
import '../data/user_provider.dart';
import '../../../home/presentation/screens/home_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late Timer _timer;
  int _resendSeconds = 60; // 1 min resend
  int _autoDeleteSeconds = 300; // 5 min auto delete
  bool _canResend = false;

  final HttpsCallable deleteUserCallable =
  FirebaseFunctions.instance.httpsCallable('deleteUser');

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
    _startTimer();
  }

  Future<void> _sendVerificationEmail() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await currentUser.sendEmailVerification();
        Fluttertoast.showToast(msg: "Verification email sent!");
        setState(() {
          _resendSeconds = 60;
          _canResend = false;
        });
      } catch (e) {
        Fluttertoast.showToast(msg: "Error sending email verification!");
      }
    } else {
      print("User not logged in!");
    }
  }

  Future<void> _deleteUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("User not logged in!");
      return;
    }
    try {
      await deleteUserCallable.call({'uid': currentUser.uid});
      await FirebaseAuth.instance.signOut();
      Fluttertoast.showToast(msg: "Signup canceled.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignupScreen()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_resendSeconds > 0) _resendSeconds--;
      else if (!_canResend) _canResend = true;

      if (_autoDeleteSeconds > 0) _autoDeleteSeconds--;
      else {
        timer.cancel();
        await _deleteUser();
        return;
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) await currentUser.reload();
      if (currentUser?.emailVerified ?? false) {
        timer.cancel();
        final uid = FirebaseAuth.instance.currentUser!.uid;
        Provider.of<UserProvider>(context, listen: false).init(uid);
        Fluttertoast.showToast(msg: "✅ Email Verified!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }

      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height * 0.35,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
              child: const Center(
                child: Text(
                  "Verify Your Email",
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "We have sent a verification email to your account.",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "If you don't verify your email within 5 minutes, your signup will be canceled.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: _autoDeleteSeconds / 300,
                            color: Colors.red,
                            backgroundColor: Colors.red.shade100,
                            strokeWidth: 8,
                          ),
                          Center(
                            child: Text(
                              _formatTime(_autoDeleteSeconds),
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Resend email available in: ${_formatTime(_resendSeconds)}",
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: (_resendSeconds / 60),
                          backgroundColor: Colors.grey.shade300,
                          valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _canResend ? _sendVerificationEmail : null,
                        child: const Text(
                          "Resend Verification Email",
                          style: TextStyle(
                              fontSize: 16,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _deleteUser,
                      child: const Text(
                        "Cancel & Signup Again",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
