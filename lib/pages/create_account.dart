import 'package:flutter/material.dart';
import 'package:fluttercircles/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {

  final _formkey = GlobalKey<FormState>();
  late String username;



  submit() {

    final form = _formkey.currentState;

    if (form!.validate()) {
      form.save();

      _formkey.currentState!.save();
      Navigator.pop(context, username);
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      appBar: header(context, titleText: "Set up your profile"),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(children: <Widget>[
              Padding(padding: EdgeInsets.only(top:25.0),
              child: Center(
                child: Text("Create a username", style: TextStyle(fontSize: 25.0),),
              ),),
              Padding(padding: EdgeInsets.all(16.0),
              child: Container(
                child: Form(
                  key: _formkey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: TextFormField(
                    validator: (val) {
                      if (val!.trim().length < 3 || val.isEmpty) {
                        return "Username too short";
                      } else if (val.trim().length > 12) {
                        return "Username too long";
                      } else
                        return null;
                    },
                    onSaved: (val) => username = val!,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "username",
                      labelStyle: TextStyle(fontSize: 15.0),
                      hintText: "Must be at least 3 characters"
                    ),
                  ),
                ),
              ),),
              GestureDetector(
                onTap: submit,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(7.0)
                  ),
                  child: Text(
                    "Submit",
                    style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                ),
              )

            ],),
          )
        ],
      ),
    );
  }
}
