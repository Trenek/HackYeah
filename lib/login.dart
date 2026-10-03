import 'package:flutter/material.dart';
import 'package:mysql_dart/mysql_dart.dart';
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
  int times=0;
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
    ));
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

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

      final result = await conn!.execute(
        'SELECT id FROM dragon.Users WHERE email = :email AND password = :password LIMIT 1', {
            'email': email, 
            'password': password
        },
      ).timeout(const Duration(seconds: 5));

      await conn!.close();

      if (mounted) Navigator.pop(context);

      if (result.rows.isNotEmpty) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => widget.targetScreen),
          );
        }
      }
      else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Niepoprawny email lub hasło'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
// <<<<<<< HEAD
//   catch (e) {
//     if (mounted) Navigator.pop(context);
//
//     if (conn != null) {
//       await conn!.close().catchError((_) => null);
//     }
//
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Błąd połączenia z bazą danych (Timeout): $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       times+=1;
//       if(times>3){
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => widget.targetScreen),
//         );
//       }
//
//
//
//
//
//
//     }
//   }
// }
// =======
// >>>>>>> 4abb76d (Git temp)

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
                  'Zaloguj się',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
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
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Zaloguj', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 15),
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
