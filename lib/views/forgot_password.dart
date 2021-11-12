import 'package:flutter/material.dart';
import 'package:unitext/helper/authenticate.dart';
import 'package:unitext/services/auth.dart';
import 'package:unitext/widgets/widgets.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailEditingController = new TextEditingController();

  AuthService authService = new AuthService();

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  resetPassword() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      formKey.currentState!.save();

      try {
        await authService
            .resetPass(emailEditingController.text)
            .timeout(Duration(seconds: 20));
      } catch (e) {
        print(e);
      }
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Authenticate()));
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text('UniText',
                          style: TextStyle(
                            color: const Color(0xff007EF4),
                            fontWeight: FontWeight.bold,
                            fontSize: 45,
                          )),
                      Container(
                        height: 150,
                        width: 150,
                        margin: EdgeInsets.only(top: 40, bottom: 100),
                        child: Image.asset('assets/images/chat.png'),
                      ),
                      Form(
                        key: formKey,
                        child: TextFormField(
                          controller: emailEditingController,
                          style: simpleTextStyle(),
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val!)
                                ? null
                                : "Enter correct email";
                          },
                          decoration: textFieldInputDecoration("Email"),
                        ),
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      GestureDetector(
                        onTap: () {
                          resetPassword();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xff007EF4),
                                  const Color(0xff2A75BC)
                                ],
                              )),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            "Reset Password",
                            style: biggerTextStyle(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Authenticate()));
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 16),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              "Back to Login",
                              style: simpleTextStyle(),
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
    ;
  }
}
