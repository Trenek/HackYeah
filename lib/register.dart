import 'package:flutter/material.dart';
import 'package:mysql_dart/mysql_dart.dart';
import './login.dart';

class RegisterScreen extends StatefulWidget {
  final Widget targetScreen;

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

Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;

  final name = _nicknameController.text;
  final email = _emailController.text.trim();
  final password = _passwordController.text;
  final birth_date = _birthDateController.text;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  MySQLConnection? conn;

  try {
    await Future(() async {
      conn = await MySQLConnection.createConnection(
        host: '57.131.197.202',
        port: 3306,
        userName: 'root',
        password: 'asdf1234',
        databaseName: 'dragon',
      );

      await conn!.connect();
    }).timeout(const Duration(seconds: 5));

    await conn!.execute(
      'INSERT INTO dragon.Users (name, email, password, birth_date, sex) VALUES (:name, :email, :password, :birth_date, :sex);', {
          'name': name,
          'email': email, 
          'password': password,
          'birth_date': birth_date,
          'sex': (_isMale ?? true) ? 'M' : 'F'
      },
    ).timeout(const Duration(seconds: 5));

    await conn!.close();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(
      targetScreen: widget.targetScreen)
    ));
  }
  catch (e) {
    if (mounted) Navigator.pop(context);

    if (conn != null) {
      await conn!.close().catchError((_) => null);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Błąd połączenia z bazą danych (Timeout): $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
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
                const Icon(Icons.lock_person, size: 80, color: Colors.deepPurple),
                const SizedBox(height: 16),
                const Text(
                  'Zarejestruj się',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextFormField(
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
                ),
                const SizedBox(height: 16),
                TextFormField(
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
                ),
                const SizedBox(height: 16),
                TextFormField(
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
                ),
                const SizedBox(height: 16),
                TextFormField(
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
                ),

                const SizedBox(height: 16),
                DropdownButtonFormField<bool>(
                  value: _isMale,
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
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
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
