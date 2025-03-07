import 'package:flutter/material.dart';
import 'package:food_app/color.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'merchant_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode(); // Focus for password field
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, String>> credentials = await fetchUserCredentials();

      // Check if the widget is still mounted before proceeding
      if (!mounted) return;

      String enteredEmail = _emailController.text.trim();
      String enteredPassword = _passwordController.text.trim();

      bool isValidUser = credentials.any((user) =>
      user['email'] == enteredEmail ||
          user['username'] == enteredEmail &&
              user['password'] == enteredPassword);

      if (isValidUser) {
        // Check if the widget is still mounted before navigating
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MerchantPage()),
          );
        }
      } else if (enteredEmail.isEmpty || enteredPassword.isEmpty) {
        // Check if the widget is still mounted before showing the SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Please enter email and password',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: AppColors.jet,
            ),
          );
        }
      } else {
        // Check if the widget is still mounted before showing the SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid email or password', style: TextStyle(color: Colors.white)),
              backgroundColor: AppColors.jet,
            ),
          );
        }
      }
    } catch (error) {
      // Check if the widget is still mounted before showing the SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching user data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Check if the widget is still mounted before updating the state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 80),
              Image.asset('assets/images/logo.png', height: 150, width: 150),
              SizedBox(height: 20),
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.russianViolet,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Sign in to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 40),

              // Email Field
              TextField(
                controller: _emailController,
                textInputAction: TextInputAction.next, // Moves to the next field
                onSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_passwordFocusNode); // Move focus to password field
                },
                decoration: InputDecoration(
                  labelText: 'Email or Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 20),

              // Password Field
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: !_isPasswordVisible,
                textInputAction: TextInputAction.done, // Triggers login on Enter
                onSubmitted: (value) {
                  _login(); // Pressing Enter will call _login()
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 50),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: AppColors.airforceBlue,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<List<Map<String, String>>> fetchUserCredentials() async {
  final response = await http.get(Uri.parse('https://dummyjson.com/users'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> users = data['users'];

    return users.map((user) {
      return {
        'email': user['email'].toString(),
        'username': user['username'].toString(),
        'password': user['password'].toString(),
      };
    }).toList();
  } else {
    throw Exception('Failed to load users');
  }
}
