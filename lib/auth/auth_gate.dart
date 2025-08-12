import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lumo/auth/login_or_register.dart';

import '../home/home_view.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (context, snapshot) {
        if(snapshot.data != null){
          return  HomeWidget();
        }else{
          return  LoginOrRegister();
        }
      }),
    );
  }
}
