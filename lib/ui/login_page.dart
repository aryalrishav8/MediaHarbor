import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mediaharbor/ui/home_page.dart';
import 'register_page.dart';
import 'package:mediaharbor/admin/adminpage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscure3 = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    emailController.text = '';
    passwordController.text = '';
    visible = false;
  }

  // final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // color: Color.fromARGB(255, 138, 109, 87),
        color: Colors.black,
        child: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/maprishav_longmap.png'),
                    opacity: 0.2)),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // const SizedBox(height: 16),
                // Image.asset(
                //   'assets/login.png',
                //   height: 250,
                //   width: 300,
                // ),
                Container(
                  // color: Colors.orangeAccent[700],
                  // width: MediaQuery.of(context).size.width,
                  // height: MediaQuery.of(context).size.height,
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 60, 60, 60),
                        borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formkey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              "Welcome",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 35,
                              ),
                            ),

                            Text(
                              "Please login and join the ride",
                              style: TextStyle(
                                // fontWeight: Fo,
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              width: 330,
                              height: 50,
                              child: TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Email',
                                  enabled: true,
                                  contentPadding: const EdgeInsets.only(
                                      left: 14.0, bottom: 8.0, top: 8.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.white),
                                    borderRadius: new BorderRadius.circular(10),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.white),
                                    borderRadius: new BorderRadius.circular(5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.length == 0) {
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
                                onSaved: (value) {
                                  emailController.text = value!;
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 330,
                              height: 50,
                              child: TextFormField(
                                controller: passwordController,
                                obscureText: _isObscure3,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      icon: Icon(_isObscure3
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {
                                          _isObscure3 = !_isObscure3;
                                        });
                                      }),
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Password',
                                  enabled: true,
                                  contentPadding: const EdgeInsets.only(
                                      left: 14.0, bottom: 8.0, top: 15.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.white),
                                    borderRadius: new BorderRadius.circular(10),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.white),
                                    borderRadius: new BorderRadius.circular(5),
                                  ),
                                ),
                                validator: (value) {
                                  RegExp regex = RegExp(r'^.{6,}$');
                                  if (value!.isEmpty) {
                                    return "Password cannot be empty";
                                  }
                                  if (!regex.hasMatch(value)) {
                                    return ("please enter valid password min. 6 character");
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  passwordController.text = value!;
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: 330,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    visible = true;
                                  });
                                  signIn(emailController.text,
                                      passwordController.text);
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5.0), // Circular border
                                  ),
                                  backgroundColor: Colors.blue,
                                ),
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 10,
                            ),
                            Visibility(
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              visible: visible,
                              child: Container(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            // MaterialButton(
                            //   shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.all(
                            //       Radius.circular(20.0),
                            //     ),
                            //   ),
                            //   elevation: 5.0,
                            //   height: 40,
                            //   onPressed: () {
                            //     Navigator.pushReplacement(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) => Register(),
                            //       ),
                            //     );
                            //   },
                            //   color: Colors.blue[900],
                            //   child: Text(
                            //     "Register Now",
                            //     style: TextStyle(
                            //       color: Colors.white,
                            //       fontSize: 20,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Text(
                    //   "Do not have an account?",
                    //   style:
                    //       TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    // ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Register(),
                          ),
                        );
                      },
                      child: Text(
                        "Register now",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    // var kk =
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  // void signIn(String email, String password) async {
  //   if (_formkey.currentState!.validate()) {
  //     try {
  //       UserCredential userCredential =
  //           await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: email,
  //         password: password,
  //       );
  //       route();
  //     } on FirebaseAuthException catch (e) {
  //       if (e.code == 'user-not-found') {
  //         print('No user found for that email.');
  //       } else if (e.code == 'wrong-password') {
  //         print('Wrong password provided for that user.');
  //       }
  //     }
  //   }
  // }

  // void signIn(String email, String password) async {
  //   if (_formkey.currentState!.validate()) {
  //     try {
  //       // Show the progress indicator when login starts
  //       setState(() {
  //         visible = true;
  //       });

  //       await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: email,
  //         password: password,
  //       );
  //       if (email == "admin@gmail.com") {
  //         routeAdmin();
  //       }

  //       route();
  //     } on FirebaseAuthException catch (e) {
  //       // Hide the progress indicator when an error occurs
  //       setState(() {
  //         visible = false;
  //       });

  //       if (e.code == 'user-not-found') {
  //         // Display an error snackbar for "No user found for that email."
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('No user found for that email.')),
  //         );
  //       } else if (e.code == 'wrong-password') {
  //         // Display an error snackbar for "Wrong password provided for that user."
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Wrong password provided for that user.')),
  //         );
  //       }
  //     }
  //   }
  // }

  void signIn(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        // Show the progress indicator when login starts
        setState(() {
          visible = true;
        });

        // Check if the user exists in the Firestore users collection
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isEmpty) {
          // Hide the progress indicator
          setState(() {
            visible = false;
          });

          // Show snackbar for "User not found"
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not found')),
          );
          return; // Exit the function early if user not found
        }

        // User found, proceed with sign-in
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (email == "admin@gmail.com") {
          routeAdmin();
        }

        route();
      } on FirebaseAuthException catch (e) {
        // Hide the progress indicator when an error occurs
        setState(() {
          visible = false;
        });

        if (e.code == 'user-not-found') {
          // Display an error snackbar for "No user found for that email."
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No user found for that email.')),
          );
        } else if (e.code == 'wrong-password') {
          // Display an error snackbar for "Wrong password provided for that user."
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wrong password provided for that user.')),
          );
        }
      }
    }
  }

  void routeAdmin() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AdminPage()));
  }
}
