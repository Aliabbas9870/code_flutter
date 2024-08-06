import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:indriver_app/methods/associate_method.dart';
import 'package:indriver_app/views/home_view.dart';
import 'package:indriver_app/widget/constant.dart';
import 'package:indriver_app/widget/loading_dialog.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class SingupView extends StatefulWidget {
  const SingupView({super.key});
  @override
  State<SingupView> createState() => _SingupViewState();
}

class _SingupViewState extends State<SingupView> {
  final Constant constant = Constant();
  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  final AssociateMethod ASM = AssociateMethod();
  validateSignUpForm() {
    if (nameController.text.trim().length < 3) {
      ASM.showSnackBarmsg("Name Character must be at least 3 or more", context);
    } else if (phoneController.text.trim().length < 8) {
      ASM.showSnackBarmsg(
          "Phone number  must be at least 8 or more numbers", context);
    } else if (!emailController.text.contains("@")) {
      ASM.showSnackBarmsg("Email not valid", context);
    } else if (passwordController.text.trim().length < 5) {
      ASM.showSnackBarmsg("Password must be at least 5 or more", context);
    } else {
      signupUserNow();
    }
  }

  signupUserNow() async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            LoadingDialog(textMessage: "Please wait....."));
    try {
      final User? firebaseuser = (await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim())
              .catchError((c) {
        Navigator.pop(context);
        ASM.showSnackBarmsg(c.toString(), context);
      }))
          .user;

      Map userDataMap = {
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'id': firebaseuser!.uid,
        'blockStatus': "no"
      };
      FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(firebaseuser!.uid)
          .set(userDataMap);
      Navigator.pop(context);
      ASM.showSnackBarmsg("Account created successfully!", context);
      Navigator.push(context, MaterialPageRoute(builder: (c) => HomeView()));
      QuickAlert.show(
        context: context,
        onConfirmBtnTap: () async {
          await Future.delayed(Duration(seconds: 1));
          Navigator.pop(context);
        },
        type: QuickAlertType.success,
        text: 'Account Created Successfully!',
      );
    } on FirebaseAuthException catch (e) {
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
      ASM.showSnackBarmsg(e.toString(), context);
    }
  }

  @override
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
                height: 75,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 35.0),
                child: Image.asset(
                  "assets/images/signup.png",
                  width: size.width * .68,
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18),
                child: Column(
                  children: [
                    TextField(
                        controller: nameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: "Enter the Name",
                          suffixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                        )),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: "Enter the phone number",
                          suffixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                        )),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Enter the email",
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
                          hintText: "Enter the password",
                          suffixIcon: Icon(Icons.password_sharp),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16))),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: 222,
                      decoration: BoxDecoration(
                          color: constant.secondaryColor,
                          borderRadius: BorderRadius.circular(16)),
                      child: TextButton(
                        onPressed: () {
                          validateSignUpForm();
                        },
                        child: Text(
                          "Register",
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
                      height: 40,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have a account",
                          style: TextStyle(fontSize: 14),
                        ),
                        TextButton(
                            onPressed: () {},
                            child: Text(
                              "Login here",
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
