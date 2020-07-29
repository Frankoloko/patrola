import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:masked_text/masked_text.dart';
import 'package:Patrola/dialogs/dialog-input.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  String phoneNumber, verificationId, smsCode;
  final phoneNumberController = TextEditingController();

  @override
  void initState() {
    _revalidateUser();

    super.initState();
  }

  void _revalidateUser() async {
    // This gets the FirebaseUser saved on the device
    final FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    if (firebaseUser == null) return;
    // This rechecks the user (reloads the user)
    await firebaseUser.reload();
    // This now checks if the rechecked user is still valid (hasn't been deleted or deactivated)
    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        print(user);
        Navigator.pushReplacementNamed(context, '/patrols');
      }
    });
  }

  void login(BuildContext pContext) {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    signIn() {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      FirebaseAuth.instance.signInWithCredential(credential).then((user) {
        Navigator.pushReplacementNamed(pContext, '/patrols');
      }).catchError((e) {
        Scaffold.of(pContext).showSnackBar(SnackBar(
            content: Text(
          'Invalid code. Please try again.',
          style: TextStyle(color: Colors.black),
        )));
      });
    }

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      asyncInputDialog(
              context: context,
              keyboardType: TextInputType.number,
              title: 'Enter SMS Code',
              doneText: 'Done')
          .then((response) {
        this.smsCode = response;
        // this will check the user's device and sign them in automatically
        FirebaseAuth.instance.currentUser().then((user) {
          if (user != null) {
            Navigator.pushReplacementNamed(pContext, '/patrols');
          } else {
            signIn();
          }
        });
      });
    };

    final PhoneVerificationCompleted verifySuccess = (FirebaseUser user) {
      // verify successful
      Navigator.pushReplacementNamed(pContext, '/patrols');
    };

    final PhoneVerificationFailed verifyFailed = (AuthException exception) {
      print('${exception.message}');
    };

    FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumberController.value.text,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifySuccess,
        verificationFailed: verifyFailed);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomPadding: true,
          body: Builder(
            builder: (BuildContext context2) {
              return Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'assets/app-icon.png',
                          height: 150.0,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text(
                            'PATROLA',
                            style: TextStyle(fontSize: 25.0),
                          ),
                        ),
                        MaskedTextField(
                          maskedTextFieldController: phoneNumberController,
                          mask: '+27 xx xxx xxxx',
                          maxLength: 15,
                          keyboardType: TextInputType.phone,
                          inputDecoration: InputDecoration(
                              labelText: 'Phone Number', hintText: '+27'),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: RaisedButton(
                            textColor: Colors.black,
                            child: Text('Login'),
                            onPressed: () {
                              login(context2);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }
}
