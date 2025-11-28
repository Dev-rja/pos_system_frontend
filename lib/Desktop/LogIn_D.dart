import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Responsive_Page.dart';
import 'Main_D.dart';              // 👈 D_Dashboad_Page is here


class D_Log_In_Page extends StatefulWidget {
  const D_Log_In_Page({super.key});

  @override
  State<D_Log_In_Page> createState() => _D_Log_In_PageState();
}

class _D_Log_In_PageState extends State<D_Log_In_Page> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isAdminSelected = true; // true = Admin, false = Cashier
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final role = _isAdminSelected ? 'admin' : 'cashier';

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://localhost:5000/api/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'role': role,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // ✅ Login success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login successful')),
        );

        // 👉 Go to dashboard and PASS USERNAME
        Widget nextPage;
        if (data['role'] == 'admin') {
          nextPage = D_Dashboad_Page(
            username: data['username'], // e.g. "Admin"
          );
        } else {
          // later you can route cashier to a different dashboard
          nextPage = D_Dashboad_Page(
            username: data['username'],
          );
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to server: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          // background image
          Positioned.fill(
            child: Image.asset(
              'assets/DeskBG.png',
              fit: BoxFit.cover,
            ),
          ),

          Scaffold(
            backgroundColor: Colors.transparent,
            body: Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: 700,
                width: 700,
                margin: const EdgeInsets.only(right: 150, left: 150),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'POS Log in',
                        style: GoogleFonts.outfit(
                          fontSize: 60,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // don't have an acc
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          alignment: const Alignment(-1, 0),
                          child: const Text(
                            'Don\'t have an account?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const Responsive_Sign_In_Page(),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // admin or cashier btn
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 40.0,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isAdminSelected = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.green,
                                width: 1.0,
                              ),
                              backgroundColor: _isAdminSelected
                                  ? Colors.green
                                  : Colors.white,
                            ),
                            child: Text(
                              'Admin',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w300,
                                color: _isAdminSelected
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          height: 40.0,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isAdminSelected = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.green,
                                width: 1.0,
                              ),
                              backgroundColor: !_isAdminSelected
                                  ? Colors.green
                                  : Colors.white,
                            ),
                            child: Text(
                              'Cashier',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w300,
                                color: !_isAdminSelected
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // username or email
                    TextField(
                      controller: _usernameController,
                      obscureText: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'UserName/Email',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.green,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blueAccent,
                            width: 2.0,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.green,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // password
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Password',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.green,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blueAccent,
                            width: 2.0,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.green,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // forgot password
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 5),
                      alignment: const Alignment(-1, 0),
                      child: InkWell(
                        onTap: () {
                          // TODO: forgot password logic
                        },
                        child: const Text(
                          'Forgot your Password?',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // login btn
                    Container(
                      width: 900.0,
                      height: 40.0,
                      margin: const EdgeInsets.only(left: 30, right: 30),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
