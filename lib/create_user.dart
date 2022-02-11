import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateUser extends StatefulWidget {
  const CreateUser({Key? key}) : super(key: key);

  @override
  _CreateUserState createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  final databaseReference = FirebaseDatabase.instance.ref();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();

  final TextEditingController _passFieldController = TextEditingController();
  final TextEditingController _passConfirmFieldController =
      TextEditingController();

  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
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
                  const Text("Crete User",
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
                          return 'Please enter a strong password';
                        }

                        return null;
                      }),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                      controller: _passConfirmFieldController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Confirm Password",
                        isDense: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 0.1,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty ||
                            value != _passFieldController.text) {
                          return 'Password did not match';
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
                          if (!event.snapshot.exists) {
                            databaseReference
                                .child("users")
                                .child(_userNameController.text.toLowerCase())
                                .set({
                              'name': _userNameController.text,
                              'password': _passFieldController.text
                            });
                            Navigator.pop(context);
                          } else {
                            Fluttertoast.showToast(
                                msg: "User Nane already taken",
                                toastLength: Toast.LENGTH_LONG,
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
                      "SignUp",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                  TextButton(
                    child: const Text(
                      "Already Registered ? SignIn",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
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
