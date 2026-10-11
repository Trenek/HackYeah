import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import './currentDate.dart';

class Measure extends StatefulWidget {
    final int userID;

    const Measure({super.key, required this.userID});

    @override
    State<Measure> createState() => MeasureState();
}

class MeasureState extends State<Measure> {
    late Future<String> _titleFuture;

    List data = [];

    @override
    void initState() {
        super.initState();
        _titleFuture = checkMeasurements(widget.userID);
    }

    Future<String> checkMeasurements(int userID) async {
        final url = Uri.parse('http://57.131.197.202:28415/measure');
        
        try {
            final response = await http.post(
                url,
                headers: <String, String> {
                    'Content-Type' : 'application/json; charset=UTF-8'
                },
                body: jsonEncode(<String, dynamic>{
                    'userID': userID
                }),
            ).timeout(const Duration(seconds: 5));

            if (response.statusCode == 200) {
                final decoded = jsonDecode(response.body);
                setState(() {
                    data = decoded['data'] ?? [];
                });

                if (data.isEmpty) {
                    return "Brak pomiarów";
                }
                else {
                    return "Ostatni pomiar - ${data[0]['date']}";
                }
            } 
        }
        catch (e) {
            debugPrint("Błąd pobierania danych: $e");
        }

        return "Dziwne";
    }

    void showAddMeasurementDialog() {
        showDialog(
            context: context,
            builder: (BuildContext context) {
                return AddMeasurementDialog(
                    userID: widget.userID,
                    onSuccess: () {
                        setState(() {
                            _titleFuture = checkMeasurements(widget.userID);
                        });
                    },
                );
            },
        );
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

    void askBackendForRemoval(Map<String, dynamic> measurement) async {
        final url = Uri.parse('http://57.131.197.202:28415/deleteRecord');
        
        try {
            final response = await http.delete(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8'
                },
                body: jsonEncode(<String, dynamic>{
                    'userID': widget.userID,
                    'date': measurement['date'],
                }),
            ).timeout(const Duration(seconds: 5));

            if (response.statusCode != 200) {
                showErrorSnackBar('Błąd połączenia z serwerem 2');
            }
            else {
                if (mounted) {
                    setState(() {
                        _titleFuture = checkMeasurements(widget.userID);
                    });
                    Navigator.pop(context);
                }
            }
        }
        catch (e) {
            showErrorSnackBar('Błąd połączenia z serwerem 1');
        }
    }

    void removeRecord(Map<String, dynamic> measurement) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: Text('Czy chcesz usunąć rekord ${measurement['date']}?'),
                    actions: [
                        TextButton(
                            onPressed: () {
                                Navigator.pop(context);
                            },
                            child: const Text('Anuluj'),
                        ),
                        FilledButton(
                            onPressed: () {
                                askBackendForRemoval(measurement);
                            },
                            child: const Text('Tak!'),
                        ),
                    ],
                );
            },
        );
    }

    DataColumn styledHeader(String text) {
        return DataColumn(
            label: Text(
                text,
                style: const TextStyle(
                    fontWeight: FontWeight.bold
                )
            )
        );
    }

    DataCell alignedCell(String text) {
        return DataCell(
            Align(
                alignment: Alignment.centerRight,
                child: Text(
                    text,
                    style: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()]
                    ),
                )
            )
        );
    }

    @override
    Widget build(BuildContext context) {
        final table = Expanded(
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                        ),
                        child: DataTable(
                            headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                            columns: [
                                styledHeader('Data'),
                                styledHeader('Waga'),
                                styledHeader('BMI'),
                                styledHeader('Tkanka tłuszczowa'),
                                styledHeader('Tkanka mięśniowa'),
                                styledHeader('RM'),
                                styledHeader('vFat'),
                            ],
                            rows: data.map((measurement) {
                                return DataRow(
                                    cells: [
                                        alignedCell(measurement['date']!),
                                        alignedCell('${measurement['weight']!} kg'),
                                        alignedCell(measurement['bmi']!),
                                        alignedCell('${measurement['fat']!} %'),
                                        alignedCell('${measurement['muscle']!} %'),
                                        alignedCell(measurement['rm']!),
                                        alignedCell(measurement['vFat']!),
                                    ],
                                    onLongPress: () => removeRecord(measurement)
                                );
                            }).toList(),
                        ),
                    ),
                ),
            ),
        );

        return FutureBuilder<String>(
            future: _titleFuture,
            builder: (context, snapshot) {
                String titleText = "Ładowanie...";

                if (snapshot.connectionState == ConnectionState.done) {
                    titleText = snapshot.data ?? "Dziwne";
                }

                return Scaffold(
                    appBar: AppBar(
                        title: Text(titleText),
                        centerTitle: true,
                        elevation: 2,
                    ),
                    body: SafeArea(
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                                children: [
                                    const Text(
                                        'Historia Twoich Pomiarów',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 12),
                                    table,
                                    const SizedBox(height: 16),
                                    SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: FilledButton(
                                            onPressed: showAddMeasurementDialog,
                                            child: const Text('Dodaj nowy pomiar', style: TextStyle(fontSize: 16)),
                                        ),
                                    ),
                                ]
                            ),
                        ),
                    ),
                );
            },
        );
    }
}
