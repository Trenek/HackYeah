import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddMeasurementDialog extends StatefulWidget {
    final int userID;
    final VoidCallback onSuccess;

    const AddMeasurementDialog({
        super.key,
        required this.userID,
        required this.onSuccess,
    });

    @override
    State<AddMeasurementDialog> createState() => AddMeasurementDialogState();
}

class AddMeasurementDialogState extends State<AddMeasurementDialog> {
    final TextEditingController weightController = TextEditingController();
    final TextEditingController bmiController = TextEditingController();
    final TextEditingController fatController = TextEditingController();
    final TextEditingController muscleController = TextEditingController();
    final TextEditingController rmController = TextEditingController();
    final TextEditingController vFatController = TextEditingController();
    final TextEditingController dateController = TextEditingController(
        text: "${DateTime.now().toLocal()}".split(' ')[0],
    );

    @override
    void dispose() {
        weightController.dispose();
        bmiController.dispose();
        dateController.dispose();
        fatController.dispose();
        muscleController.dispose();
        rmController.dispose();
        vFatController.dispose();
        super.dispose();
    }

    void showErrorSnackBar(String message) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
            ),
        );
    }
    void onPressed() async {
        String wartosc = weightController.text;
        if (wartosc.isNotEmpty) {
            final url = Uri.parse('http://57.131.197.202:28415/recordMeasure');
            
            try {
                final response = await http.post(
                    url,
                    headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8'
                    },
                    body: jsonEncode(<String, dynamic>{
                        'id': widget.userID,
                        'date': dateController.text,
                        'weight': double.tryParse(weightController.text) ?? 0.0,
                        'bmi': double.tryParse(bmiController.text) ?? 0.0,
                        'fat': double.tryParse(fatController.text) ?? 0.0,
                        'muscle': double.tryParse(muscleController.text) ?? 0.0,
                        'rm': double.tryParse(rmController.text) ?? 0.0,
                        'vfat': int.tryParse(vFatController.text) ?? 0
                    }),
                ).timeout(const Duration(seconds: 5));

                if (response.statusCode == 200) {
                    widget.onSuccess();
                    if (mounted) Navigator.pop(context);
                }
                else {
                    showErrorSnackBar('Błąd połączenia z serwerem 2');
                }
            }
            catch (e) {
                showErrorSnackBar('Błąd połączenia z serwerem 1');
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        DateTime? selectedDate = DateTime.now();

        final dateTextField = TextFormField(
            controller: dateController,
            readOnly: true,
            decoration: const InputDecoration(
                labelText: 'Data pomiaru',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
            ),
            onTap: () async {
                final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                );
                if (picked != null && picked != selectedDate) {
                    setState(() {
                        selectedDate = picked;
                        dateController.text = "${picked.toLocal()}".split(' ')[0];
                    });
                }
            },
            validator: (value) {
                if (value == null || value.isEmpty) return 'Wybierz datę urodzenia';
                return null;
            },
        );

        final weightTextField = TextFormField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Waga',
                border: OutlineInputBorder(),
            ),
        );

        final bmiTextField = TextField(
            controller: bmiController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: "BMI",
                border: OutlineInputBorder(),
            ),
        );

        final fatTextField = TextField(
            controller: fatController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: "Poziom tkanki tłuszczowej",
                border: OutlineInputBorder(),
            ),
        );

        final muscleTextField = TextField(
            controller: muscleController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: "Poziom tkanki mięśniowej",
                border: OutlineInputBorder(),
            ),
        );

        final rmTextField = TextField(
            controller: rmController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: "RM",
                border: OutlineInputBorder(),
            ),
        );

        final vFatTextField = TextField(
            controller: vFatController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: "Tłuszcz Trzewny",
                border: OutlineInputBorder(),
            ),
        );

        return AlertDialog(
            title: const Text('Dodaj pomiar'),
            content: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        dateTextField,
                        const SizedBox(height: 10),
                        weightTextField,
                        const SizedBox(height: 10),
                        bmiTextField,
                        const SizedBox(height: 10),
                        fatTextField,
                        const SizedBox(height: 10),
                        muscleTextField,
                        const SizedBox(height: 10),
                        rmTextField,
                        const SizedBox(height: 10),
                        vFatTextField
                    ],
                ),
            ),
            actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Anuluj'),
                ),
                FilledButton(
                    onPressed: onPressed,
                    child: const Text('Zapisz'),
                ),
            ],
        );
    }
}
