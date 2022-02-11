import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();

  final TextEditingController _passFieldController = TextEditingController();

  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final databaseReference = FirebaseDatabase.instance.ref();
    return Scaffold(
      appBar: AppBar(
        title: const Text("I-Spy"),
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  const Text("Login",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                      controller: _userNameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: "User Name",
                        isDense: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 0.1,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter an user-name';
                        }

                        return null;
                      }),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                      controller: _passFieldController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        isDense: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 0.1,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a valid password';
                        }

                        return null;
                      }),
                  const SizedBox(
                    height: 20,
                  ),
                  MaterialButton(
                    minWidth: 200,
                    color: Colors.blue,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isProcessing = true;
                        });
                        databaseReference
                            .child("users")
                            .child(_userNameController.text.toLowerCase())
                            .once()
                            .then((DatabaseEvent event) {
                          if (event.snapshot.exists &&
                              event.snapshot.child("password").value ==
                                  _passFieldController.text) {
                            Navigator.pushReplacementNamed(
                                context, "/active_user",
                                arguments: event.snapshot.child("name").value);
                            if (kDebugMode) {
                              print(
                                  "Welcome ${event.snapshot.child("name").value}");
                            }
                          } else {
                            Fluttertoast.showToast(
                                msg: "Invalid User-name/password",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 2,
                                textColor: Colors.white,
                                fontSize: 14.0);
                          }
                        });

                        setState(() {
                          isProcessing = false;
                        });
                      }
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                  TextButton(
                    child: const Text(
                      "New User ? SignUp",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/create");
                    },
                  ),
                ],
              ),
            ),
          ),
          isProcessing
              ? const Center(child: CircularProgressIndicator())
              : Container(),
        ],
      ),
    );
  }
}
