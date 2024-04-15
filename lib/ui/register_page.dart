import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mediaharbor/ui/home_page.dart';
import 'login_page.dart';

// import 'model.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  _RegisterState();

  bool showProgress = false;
  bool visible = false;

  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController username = TextEditingController();
  bool _isObscure = true;
  bool _isObscure2 = true;
  File? file;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.orange[900],
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
                image: AssetImage('assets/maprishav_longmap.png'),
                opacity: 0.2),
          ),
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    // height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: const Color.fromARGB(255, 60, 60, 60),
                              ),
                              // margin: const EdgeInsets.all(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Form(
                                  key: _formkey,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Image.asset(
                                      //   'assets/register.png',
                                      //   height: 250,
                                      //   width: 300,
                                      // ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        "Register ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 36,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      TextFormField(
                                        controller: emailController,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintText: 'Email',
                                          enabled: true,
                                          contentPadding: const EdgeInsets.only(
                                              left: 14.0,
                                              bottom: 8.0,
                                              top: 8.0),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.white),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.white),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Email cannot be empty";
                                          }
                                          if (!RegExp(
                                                  "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                              .hasMatch(value)) {
                                            return ("Please enter a valid email");
                                          } else {
                                            return null;
                                          }
                                        },
                                        onChanged: (value) {},
                                        keyboardType:
                                            TextInputType.emailAddress,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      TextFormField(
                                        controller: username,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintText: 'Username',
                                          enabled: true,
                                          contentPadding: const EdgeInsets.only(
                                              left: 14.0,
                                              bottom: 8.0,
                                              top: 8.0),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.white),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.white),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Username cannot be empty";
                                          } else {
                                            return null;
                                          }
                                        },
                                        onChanged: (value) {},
                                        keyboardType: TextInputType.text,
                                      ),
                                      const SizedBox(height: 20),
                                      TextFormField(
                                        obscureText: _isObscure,
                                        controller: passwordController,
                                        decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                              icon: Icon(_isObscure
                                                  ? Icons.visibility_off
                                                  : Icons.visibility),
                                              onPressed: () {
                                                setState(() {
                                                  _isObscure = !_isObscure;
                                                });
                                              }),
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintText: 'Password',
                                          enabled: true,
                                          contentPadding: const EdgeInsets.only(
                                              left: 14.0,
                                              bottom: 8.0,
                                              top: 15.0),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: new BorderSide(
                                                color: Colors.white),
                                            borderRadius:
                                                new BorderRadius.circular(10),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: new BorderSide(
                                                color: Colors.white),
                                            borderRadius:
                                                new BorderRadius.circular(5),
                                          ),
                                        ),
                                        validator: (value) {
                                          RegExp regex = new RegExp(r'^.{6,}$');
                                          if (value!.isEmpty) {
                                            return "Password cannot be empty";
                                          }
                                          if (!regex.hasMatch(value)) {
                                            return ("please enter valid password min. 6 character");
                                          } else {
                                            return null;
                                          }
                                        },
                                        onChanged: (value) {},
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      TextFormField(
                                        obscureText: _isObscure2,
                                        controller: confirmpassController,
                                        decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                              icon: Icon(_isObscure2
                                                  ? Icons.visibility_off
                                                  : Icons.visibility),
                                              onPressed: () {
                                                setState(() {
                                                  _isObscure2 = !_isObscure2;
                                                });
                                              }),
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintText: 'Confirm Password',
                                          enabled: true,
                                          contentPadding: const EdgeInsets.only(
                                              left: 14.0,
                                              bottom: 8.0,
                                              top: 15.0),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: new BorderSide(
                                                color: Colors.white),
                                            borderRadius:
                                                new BorderRadius.circular(10),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: new BorderSide(
                                                color: Colors.white),
                                            borderRadius:
                                                new BorderRadius.circular(5),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (confirmpassController.text !=
                                              passwordController.text) {
                                            return "Password did not match";
                                          } else {
                                            return null;
                                          }
                                        },
                                        onChanged: (value) {},
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),

                                      Container(
                                        width: 330,
                                        height: 45,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              showProgress = true;
                                            });
                                            signUp(
                                                emailController.text,
                                                passwordController.text,
                                                username.text);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      5.0), // Circular border
                                            ),
                                            backgroundColor: Colors.blue,
                                          ),
                                          child: const Text(
                                            "Register",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextButton(
                              onPressed: () {
                                const CircularProgressIndicator();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signUp(String email, String password, String username) async {
    CircularProgressIndicator();
    if (_formkey.currentState!.validate()) {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        postDetailsToFirestore(email, username);

        // If the user registered as a driver, also add driver-specific data to the 'drivers' collection
      }).catchError((e) {});
    }
  }

  void postDetailsToFirestore(String email, String username) async {
    var user = _auth.currentUser;
    CollectionReference ref = FirebaseFirestore.instance.collection('users');
    Map<String, dynamic> data = {
      'email': emailController.text,
      'username': username,
      'id': _firebaseAuth.currentUser!.uid,
      'profilePictureUrl': '',
      'following': []
    };

    ref.doc(user!.uid).set(data);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }
}
