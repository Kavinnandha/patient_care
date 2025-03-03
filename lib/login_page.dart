import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget{
    const LoginPage({Key? key}) : super(key: key);

    @override
    State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    @override
    Widget build(BuildContext context){
        return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.grey[300],
            body: SafeArea(
                child: Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(Icons.badge,size:100),
                        SizedBox(height: 50),
                        Text(
                        'Welcome Back',
                        style: GoogleFonts.bebasNeue(
                            fontSize: 50,
                            ),
                        ), //text
                        SizedBox(height: 10),
                        Text(
                            'please enter your email and password',
                            style: TextStyle(
                                fontSize: 20,
                            ),
                        ), // text

                        SizedBox(height: 25),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                            ), // Boxdecoration
                        child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextField(
                            decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Email',
                            ),
                        ), // textfield
                        ), // Padding
                        ), // Container
                    ), //Padding
                        SizedBox(height: 20),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                            ), // Boxdecoration
                        child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
                            ),
                        ), // Textfield
                        ), // Padding
                        ), // Container
                    ), //Padding
                    SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                        padding: EdgeInsets.all(17),
                        decoration: BoxDecoration(color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                            child: Text('Sign In',
                            style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,),
                            ),
                        ) // Center
                        ) // container
                        ) // Padding
                    ],
                ), // column
                ), // center
            ), // SafeArea
            ); // scaffold
    }
}

