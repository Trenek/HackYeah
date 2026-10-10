import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import './register.dart';

class LoginScreen extends StatefulWidget {
    final Widget targetScreen;

    const LoginScreen({super.key, required this.targetScreen});

    @override
    State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    int times = 0;

    @override
    void dispose() {
        _emailController.dispose();
        _passwordController.dispose();
        super.dispose();
    }

    Future<void> _register() async {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RegisterScreen(
                targetScreen: widget.targetScreen)
            )
        );
    }

    Future<void> tryToLogin(String email, String password) async {
        final url = Uri.parse('http://57.131.197.202:28415/login');
        
        try {
            final response = await http.post(
                url,
                headers: <String, String> {
                    'Content-Type' : 'application/json; charset=UTF-8'
                },
                body: jsonEncode(<String, String>{
                    'email': email,
                    'password': password
                }),
            ).timeout(const Duration(seconds: 5));

            if (!mounted) return;

            if (response.statusCode == 200) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => widget.targetScreen),
                );
            } else {
                final message = jsonDecode(response.body)['message'];

                _showErrorSnackBar('$message (Kod błędu: ${response.statusCode})');
            }
        } catch (e) {
            if (!mounted) return;
            _showErrorSnackBar('Błąd połączenia z serwerem');
        }
    }

    void _showErrorSnackBar(String message) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
            ),
        );
    }

    void _login() async {
        if (!_formKey.currentState!.validate()) return;

        final email = _emailController.text.trim();
        final password = _passwordController.text;

        tryToLogin(email, password);
    }

    String? emailValidator(String? email) {
        if (email == null || email.isEmpty) return 'Wpisz email';

        return null;
    }

    TextFormField emailTextForm() {
        return TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
            ),
            validator: emailValidator,
        );
    }

    TextFormField passwordTextForm() {
        return TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: 'Hasło',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
            ),
            validator: (value) {
                if (value == null || value.isEmpty) return 'Wpisz hasło';
                return null;
            },
        );
    }

    @override
    Widget build(BuildContext context) {
        final buttonStyle = ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white
        );

        return Scaffold(
            body: Center(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                        key: _formKey,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                const Icon(Icons.lock_person, size: 80, color: Colors.green),
                                const SizedBox(height: 16),
                                const Text(
                                    'Zaloguj się',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 32),
                                emailTextForm(),
                                const SizedBox(height: 16),
                                passwordTextForm(),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                    onPressed: _login,
                                    style: buttonStyle,
                                    child: const Text('Zaloguj', style: TextStyle(fontSize: 16)),
                                ),
                                const SizedBox(height: 15),
                                ElevatedButton(
                                    onPressed: _register,
                                    style: buttonStyle,
                                    child: const Text('Zarejestruj się', style: TextStyle(fontSize: 16)),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}
