import 'package:flutter/material.dart';
import 'package:lumo/core/widgets/app_button.dart';
import 'package:lumo/core/widgets/app_input_field.dart';
import 'package:lumo/core/widgets/app_text.dart';

class LoginPage extends StatelessWidget {
  // Create a text controller and use it to retrieve the current value
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key, required this.ontap});

  final void Function(

      )? ontap;

  void tap(){
    print("heleo");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Icon(
                Icons.message,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              AppText.body("Sign in to continue chatting with people."),
              SizedBox(height: 20),
              AppInputField(
                controller: _emailController,
                labeltext: "Email",
                keyboardType: TextInputType.emailAddress,
                obscureTexts: false,
              ),
              SizedBox(height: 10),
              AppInputField(
                controller: _passwordController,
                labeltext: "password",

                keyboardType: TextInputType.text,
                obscureTexts: true,
              ),
              SizedBox(height: 30),
              AppButton(
                type: ButtonType.filled,
                text: "Login",
                width: double.infinity,
                onPressed: () {},
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText.body(
                    "Not a member?  ",
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  GestureDetector(
                    onTap: ontap,
                    child: AppText.body(
                      "Register now",
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
