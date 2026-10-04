import 'package:flutter/material.dart';
import 'package:mysql_dart/mysql_dart.dart';
import 'package:intl/intl.dart';

class Diet extends StatefulWidget {
  const Diet({super.key});

  @override
  State<Diet> createState() => _DietState();
}

class _DietState extends State<Diet> {
  DateTime _selectedDate = DateTime.now();
  late Future<List<Map<String, dynamic>>> _dietDataFuture;

  @override
  void initState() {
    super.initState();
    _dietDataFuture = _fetchDietData();
  }

  Future<List<Map<String, dynamic>>> _fetchDietData() async {
    MySQLConnection? conn;
    try {
      conn = await MySQLConnection.createConnection(
        host: '57.131.197.202',
        port: 3306,
        userName: 'root',
        password: 'asdf1234',
        databaseName: 'dragon',
      );

      await conn.connect();

      final result = await conn.execute('''
        SELECT 
          d.id, 
          d.user_id, 
          f.name AS food_name, 
          d.quantity, 
          d.weight, 
          d.date 
        FROM dragon.ActualDiet d
        LEFT JOIN dragon.Foods f ON d.food_id = f.id
        ORDER BY d.date ASC -- Sortujemy od najwcześniejszych posiłków
      ''');

      await conn.close();

      List<Map<String, dynamic>> items = [];
      for (final row in result.rows) {
        items.add(row.assoc());
      }
      return items;
    } catch (e) {
      if (conn != null) {
        await conn.close().catchError((_) => null);
      }
      rethrow;
    }
  }

  List<Map<String, dynamic>> _filterDietByDate(List<Map<String, dynamic>> allItems, DateTime date) {
    return allItems.where((item) {
      if (item['date'] == null) return false;
      try {
        final itemDate = item['date'] is DateTime 
            ? item['date'] as DateTime 
            : DateTime.parse(item['date'].toString());
            
        return itemDate.year == date.year &&
            itemDate.month == date.month &&
            itemDate.day == date.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> _groupEntriesByTime(List<Map<String, dynamic>> dayItems) {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final item in dayItems) {
      String timeKey = 'Brak godziny';
      if (item['date'] != null) {
        try {
          final itemDate = item['date'] is DateTime 
              ? item['date'] as DateTime 
              : DateTime.parse(item['date'].toString());
          
          timeKey = "${itemDate.hour.toString().padLeft(2, '0')}:${itemDate.minute.toString().padLeft(2, '0')}";
        } catch (_) {}
      }

      if (grouped[timeKey] == null) {
        grouped[timeKey] = [];
      }
      grouped[timeKey]!.add(item);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final String formattedHeaderDate = 
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalendarz Diety'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dietDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Błąd pobierania danych: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final allDietList = snapshot.data ?? [];
          final filteredList = _filterDietByDate(allDietList, _selectedDate);
          
          final groupedDiet = _groupEntriesByTime(filteredList);
          final sortedHours = groupedDiet.keys.toList()..sort();

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(12.0),
                elevation: 4,
                child: CalendarDatePicker(
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  onDateChanged: (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                  },
                ),
              ),
              
              const Divider(thickness: 1, height: 1),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Wpisy z dnia: $formattedHeaderDate',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Chip(
                      label: Text('Suma pozycji: ${filteredList.length}'),
                      backgroundColor: Colors.blue.shade50,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: filteredList.isEmpty
                    ? const Center(
                        child: Text(
                          'Brak wpisów w diecie dla tego dnia.',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      )
                    : ListView.builder(
                        itemCount: sortedHours.length,
                        itemBuilder: (context, index) {
                          final hour = sortedHours[index];
                          final productsInHour = groupedDiet[hour]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 18.0, top: 14.0, bottom: 6.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 18, color: Colors.blueGrey),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Godzina $hour',
                                      style: TextStyle(
                                        fontSize: 15, 
                                        fontWeight: FontWeight.bold, 
                                        color: Colors.blueGrey.shade700
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...productsInHour.map((item) {
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                  child: ListTile(
                                    leading: const Icon(Icons.restaurant, color: Colors.green),
                                    title: Text(
                                      item['food_name'] ?? 'Nieznany produkt',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text('Ilość: ${item['quantity'] ?? 0} szt.'),
                                    trailing: Text(
                                      '${item['weight'] ?? 0} g',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

