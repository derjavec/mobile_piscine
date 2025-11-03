import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'agenda_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final GlobalKey entriesListKey = GlobalKey(); // Key para scroll
  bool _showAllEntries = false;

  /// Stream de todas las entradas
  Stream<QuerySnapshot> _getEntries() {
    return _db
        .collection('diary_entries')
        .where('email', isEqualTo: user.email)
        .orderBy('date', descending: true)
        .snapshots();
  }

  /// Stream solo últimas 2 entradas
  Stream<QuerySnapshot> _getLastTwoEntries() {
    return _db
        .collection('diary_entries')
        .where('email', isEqualTo: user.email)
        .orderBy('date', descending: true)
        .limit(2)
        .snapshots();
  }

  /// Agregar entrada
  Future<void> _addEntry() async {
    final titleController = TextEditingController();
    String? selectedFeeling;
    final contentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setInnerState) {
          return AlertDialog(
            title: const Text("New Entry"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: "Content"),
                ),
                const SizedBox(height: 10),
                const Text("How do you feel?"),
                Wrap(
                  spacing: 10,
                  children: [
                    IconButton(
                      icon: Icon(Icons.sentiment_very_satisfied,
                          color: selectedFeeling == "happy"
                              ? Colors.pink
                              : Colors.grey),
                      onPressed: () =>
                          setInnerState(() => selectedFeeling = "happy"),
                    ),
                    IconButton(
                      icon: Icon(Icons.sentiment_dissatisfied,
                          color: selectedFeeling == "sad"
                              ? Colors.pink
                              : Colors.grey),
                      onPressed: () =>
                          setInnerState(() => selectedFeeling = "sad"),
                    ),
                    IconButton(
                      icon: Icon(Icons.sentiment_neutral,
                          color: selectedFeeling == "neutral"
                              ? Colors.pink
                              : Colors.grey),
                      onPressed: () =>
                          setInnerState(() => selectedFeeling = "neutral"),
                    ),
                    IconButton(
                      icon: Icon(Icons.sentiment_very_dissatisfied,
                          color: selectedFeeling == "angry"
                              ? Colors.pink
                              : Colors.grey),
                      onPressed: () =>
                          setInnerState(() => selectedFeeling = "angry"),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await _db.collection('diary_entries').add({
                    'email': user.email,
                    'title': titleController.text,
                    'feeling': selectedFeeling,
                    'content': contentController.text,
                    'date': Timestamp.now(),
                  });
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Eliminar entrada
  Future<void> _deleteEntry(String id) async {
    await _db.collection('diary_entries').doc(id).delete();
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

  /// Últimas 2 entries
  Widget _lastEntriesCard() {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFCDE4),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _getLastTwoEntries(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Your last diary entries",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                if (docs.isEmpty)
                  const Text(
                    "You have no diary entries yet",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ...docs.map((e) {
                  final title = e['title'];
                  final content = e['content'];
                  final date = (e['date'] as Timestamp).toDate();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "${date.day}/${date.month}/${date.year}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const Divider(color: Colors.black54),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 10),

                // Botón ver todas las entradas
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    elevation: 2,
                  ),
                  onPressed: () {
                    setState(() {
                      _showAllEntries = !_showAllEntries;
                    });

                    // Scroll después de reconstruir
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_showAllEntries &&
                          entriesListKey.currentContext != null) {
                        Scrollable.ensureVisible(
                          entriesListKey.currentContext!,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    });
                  },
                  child: Text(_showAllEntries ? "Hide entries" : "View all entries"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Últimos 7 feelings
  Widget _lastFeelingsCard() {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE9EE),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _db
              .collection('diary_entries')
              .where('email', isEqualTo: user.email)
              .orderBy('date', descending: true)
              .limit(7)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Your feel for the last 7 entries",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
                const SizedBox(height: 12),
                if (docs.isEmpty)
                  const Text(
                    "You have no diary entries yet",
                    style: TextStyle(color: Colors.black54),
                  ),
                if (docs.isNotEmpty)
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: docs.map((e) {
                      final feeling = e['feeling'];
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: Icon(
                          _getFeelingIcon(feeling),
                          size: 28,
                          color: Colors.pinkAccent,
                        ),
                      );
                    }).toList(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Ver entrada completa
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC1CC),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 5,
        title: Row(
          children: [
            if (user.photoURL != null)
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL!),
                radius: 18,
              )
            else
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white),
              ),
            const SizedBox(width: 10),
            Text(
              user.displayName ?? user.email ?? "My Diary",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFE4E9),
        child: Column(
          children: [
            _lastEntriesCard(),
            _lastFeelingsCard(),
            // Justo antes de la lista completa de entradas o después de _lastFeelingsCard()
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                ),
                onPressed: () {
                  // Navegar a la AgendaPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AgendaPage()),
                  );
                },
                child: const Text("Go to Agenda"),
              ),
            ),

            const SizedBox(height: 20),
            if (_showAllEntries)
              Expanded(
                key: entriesListKey,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getEntries(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final entries = snapshot.data!.docs;
                    if (entries.isEmpty) {
                      return const Center(child: Text("No entries yet."));
                    }
                    return ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              _getFeelingIcon(entry['feeling']),
                              color: Colors.pinkAccent,
                            ),
                            title: Text(entry['title']),
                            subtitle: Text(entry['content']),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}
