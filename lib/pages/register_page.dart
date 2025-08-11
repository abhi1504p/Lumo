import 'package:flutter/material.dart';
import 'package:lumo/core/widgets/app_button.dart';
import 'package:lumo/core/widgets/app_input_field.dart';
import 'package:lumo/core/widgets/app_text.dart';

class RegisterPage extends StatelessWidget {
  // Create a text controller and use it to retrieve the current value
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();


  RegisterPage({super.key, required this.ontap});
  final void Function()? ontap;

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
              AppText.body("Let's create an account for you."),
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
                labeltext: "Password",

                keyboardType: TextInputType.text,
                obscureTexts: true,
              ),
              SizedBox(height: 10),
              AppInputField(
                controller: _passwordController,
                labeltext: "Confirm password",

                keyboardType: TextInputType.text,
                obscureTexts: true,
              ),
              SizedBox(height: 30),
              AppButton(
                type: ButtonType.filled,
                text: "Register",
                width: double.infinity,
                onPressed: () {},
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText.body(
                    "Already have an account?  ",
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  GestureDetector(
                    onTap: ontap,
                    child: AppText.body(
                      "Login now",
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
