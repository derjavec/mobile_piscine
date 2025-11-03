import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DateTime _selectedDate = DateTime.now(); // Fecha seleccionada
  DateTime _focusedDate = DateTime.now(); // Fecha mostrada en el calendario

  /// Stream de entradas filtradas por fecha seleccionada
  Stream<QuerySnapshot> _getEntriesByDate(DateTime date) {
    // Creamos rango de inicio y fin del día
    final start = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 0, 0, 0));
    final end = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59));

    return _db
        .collection('diary_entries')
        .where('email', isEqualTo: user.email)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .orderBy('date', descending: true)
        .snapshots();
  }

  /// Icono según feeling
  IconData _getFeelingIcon(String feeling) {
    switch (feeling) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_dissatisfied;
      case 'neutral':
        return Icons.sentiment_neutral;
      case 'angry':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  /// Ver detalle de entrada
  void _showEntry(DocumentSnapshot entry) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(entry['title'], textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getFeelingIcon(entry['feeling']), size: 40, color: Colors.pinkAccent),
            const SizedBox(height: 8),
            Text(entry['content']),
            const SizedBox(height: 8),
            Text(
              "Date: ${entry['date'].toDate()}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  /// Eliminar entrada
  Future<void> _deleteEntry(String id) async {
    await _db.collection('diary_entries').doc(id).delete();
    setState(() {}); // Refresca la UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agenda"),
        backgroundColor: const Color(0xFFFFC1CC),
      ),
      body: Column(
        children: [
          // Calendario
          TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDate,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _focusedDate = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.pinkAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepOrange,
                shape: BoxShape.circle,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Lista de entradas del día seleccionado
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getEntriesByDate(_selectedDate),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final entries = snapshot.data!.docs;
                if (entries.isEmpty) {
                  return const Center(child: Text("No entries for this day."));
                }

                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final date = (entry['date'] as Timestamp).toDate();

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Icon(_getFeelingIcon(entry['feeling']), color: Colors.pinkAccent),
                        title: Text(entry['title']),
                        subtitle: Text(
                          "${entry['content'].toString().length > 50 ? entry['content'].toString().substring(0, 50) + '...' : entry['content']}\n${date.day}/${date.month}/${date.year}",
                        ),
                        isThreeLine: true,
                        onTap: () => _showEntry(entry),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEntry(entry.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
