import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:indriver_app/auth/singup_view.dart';
import 'package:indriver_app/methods/associate_method.dart';
import 'package:indriver_app/views/home_view.dart';
import 'package:indriver_app/widget/constant.dart';
import 'package:indriver_app/widget/loading_dialog.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class SigninView extends StatefulWidget {
  const SigninView({super.key});

  @override
  State<SigninView> createState() => _SigninViewState();
}

class _SigninViewState extends State<SigninView> {
  @override
  final Constant constant = Constant();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  final AssociateMethod ASM = AssociateMethod();

  validateSignInForm() {
    if (!emailController.text.contains("@")) {
      ASM.showSnackBarmsg("Email not valid", context);
    } else if (passwordController.text.trim().length < 5) {
      ASM.showSnackBarmsg("Password must be at least 5 or more", context);
    } else {
      signInUserNow();
    }
  }

  signInUserNow() async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            LoadingDialog(textMessage: "Please wait....."));
    try {
      final User? firebaseuser = (await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim())
              .catchError((c) {
        Navigator.pop(context);
        ASM.showSnackBarmsg(c.toString(), context);
      }))
          .user;

      if (firebaseuser != null) {
        DatabaseReference ref = FirebaseDatabase.instance
            .ref()
            .child("users")
            .child(firebaseuser!.uid);
        await ref.once().then((dataSnapshot) {
          if (dataSnapshot.snapshot.value != null) {
            if ((dataSnapshot.snapshot.value as Map)["blockStatus"] == "no") {
              UserName = (dataSnapshot.snapshot.value as Map)["name"];
              UserPhone = (dataSnapshot.snapshot.value as Map)["phone"];
              //   UserEmail = (dataSnapshot.snapshot.value as Map)["email"];
              // UserPass = (dataSnapshot.snapshot.value as Map)["password"];
              Navigator.push(
                  context, MaterialPageRoute(builder: (c) => HomeView()));
              ASM.showSnackBarmsg("Signin successfully!", context);
              QuickAlert.show(
                context: context,
                autoCloseDuration: Duration(seconds: 1),
                type: QuickAlertType.success,
                text: 'signin Successfully!',
              );
            } else {
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
              ASM.showSnackBarmsg(
                  "You are Blocked please Contact  admin: aliabbascs59@gmail.com",
                  context);
            }
          } else {
            Navigator.pop(context);

            FirebaseAuth.instance.signOut();
            ASM.showSnackBarmsg("Your record not exit as  user", context);
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
      ASM.showSnackBarmsg(e.toString(), context);
    }
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: constant.bgColor,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 102,
              ),
              Image.asset(
                "assets/images/signin.png",
                width: size.width * .75,
              ),
              Text(
                "Login as user",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: constant.primaryColor,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18),
                child: Column(
                  children: [
                    TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Enter the email",
                          label: Text("Email"),
                          suffixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                        )),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          label: Text("Password"),
                          hintText: "Enter the email",
                          suffixIcon: Icon(Icons.password_sharp),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16))),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: 222,
                      decoration: BoxDecoration(
                          color: constant.secondaryColor,
                          borderRadius: BorderRadius.circular(16)),
                      child: TextButton(
                        onPressed: () {
                          validateSignInForm();
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: constant.primaryColor,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: constant.secondaryColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 80,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have a account",
                          style: TextStyle(fontSize: 14),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) => SingupView()));
                            },
                            child: Text(
                              "Sign up here",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ))
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
