import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './login.dart';

class RegisterScreen extends StatefulWidget {
    final Widget Function(int id, String name) targetScreen;

    const RegisterScreen({super.key, required this.targetScreen});

    @override
    State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
    final _formKey = GlobalKey<FormState>();

    final _nicknameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _birthDateController = TextEditingController();
    DateTime? _selectedDate;
    bool? _isMale;

    @override
    void dispose() {
        _emailController.dispose();
        _passwordController.dispose();
        super.dispose();
    }

    Future<void> tryToRegister(String name, String email, String password, String birthday, String sex) async {
        final url = Uri.parse('http://57.131.197.202:28415/signup');

        try {
            final response = await http.post(
                url,
                headers: <String, String> {
                    'Content-Type' : 'application/json; charset=UTF-8'
                },
                body: jsonEncode(<String, String>{
                    'name': name,
                    'email': email,
                    'password': password,
                    'birthday': birthday,
                    'sex': sex
                }),
            ).timeout(const Duration(seconds: 5));

            if (!mounted) return;

            if (response.statusCode == 200) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen(
                        targetScreen: widget.targetScreen)
                    )
                );
            }
            else {
                final message = jsonDecode(response.body)['message'];

                _showErrorSnackBar('$message (Kod błędu: ${response.statusCode})');
            }
        }
        catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Błąd połączenia z bazą danych (Timeout): $e'),
                    backgroundColor: Colors.red,
                ),
            );
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

    void _register() {
        if (!_formKey.currentState!.validate()) return;

        final name = _nicknameController.text;
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        final birthday = _birthDateController.text;
        final sex = _isMale == true ? "M" : "F";

        tryToRegister(name, email, password, birthday, sex);
    }

    @override
    Widget build(BuildContext context) {
        final nameTextField = TextFormField(
            controller: _nicknameController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                labelText: 'Nazwa użytkownika',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
                if (value == null || value.isEmpty) return 'Wpisz nazwę użytkownika';
                return null;
            },
        );

        final emailTextField = TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
                if (value == null || value.isEmpty) return 'Wpisz e-mail';
                return null;
            },
        );

        final passwordTextField = TextFormField(
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

        final birthdayTextField = TextFormField(
            controller: _birthDateController,
            readOnly: true,
            decoration: const InputDecoration(
                labelText: 'Data urodzenia',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
            ),
            onTap: () async {
                final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                );
                if (picked != null && picked != _selectedDate) {
                    setState(() {
                        _selectedDate = picked;
                        _birthDateController.text = "${picked.toLocal()}".split(' ')[0];
                    });
                }
            },
            validator: (value) {
                if (value == null || value.isEmpty) return 'Wybierz datę urodzenia';
                return null;
            },
        );

        final sexTextField = DropdownButtonFormField<bool>(
            initialValue: _isMale,
            decoration: const InputDecoration(
                labelText: 'Płeć',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wc),
            ),
            items: const [
                DropdownMenuItem(
                    value: true,
                    child: Row(
                        children: [
                            Icon(Icons.male, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Mężczyzna'),
                        ],
                    ),
                ),
                DropdownMenuItem(
                    value: false,
                    child: Row(
                        children: [
                            Icon(Icons.female, color: Colors.pink),
                            SizedBox(width: 8),
                            Text('Kobieta'),
                        ],
                    ),
                ),
            ],
            onChanged: (value) {
                setState(() {
                    _isMale = value;
                });
            },
            validator: (value) {
                if (value == null) return 'Wybierz płeć';
                return null;
            },
        );

        final registerButton = ElevatedButton(
            onPressed: _register,
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
            ),
            child: const Text('Zarejestruj się', style: TextStyle(fontSize: 16)),
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
                                    'Zarejestruj się',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 32),
                                nameTextField,
                                const SizedBox(height: 16),
                                emailTextField,
                                const SizedBox(height: 16),
                                passwordTextField,
                                const SizedBox(height: 16),
                                birthdayTextField,
                                const SizedBox(height: 16),
                                sexTextField,
                                const SizedBox(height: 24),
                                registerButton
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}
