import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/api_service.dart';
import 'create_page.dart';

class ApiNotesPage extends StatefulWidget {
  const ApiNotesPage({super.key});

  @override
  State<ApiNotesPage> createState() => _ApiNotesPageState();
}

class _ApiNotesPageState extends State<ApiNotesPage> {
  final ApiService _apiService = ApiService();

  // Les 3 états de la page
  List<Note> _notes = [];
  bool _isLoading = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _chargerNotes(); // charger au démarrage
  }

  // Charger les notes depuis le serveur
  Future<void> _chargerNotes() async {
    setState(() {
      _isLoading = true;
      _erreur = null;
    });

    try {
      final notes = await _apiService.getAllNotes();
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _erreur = e.toString();
        _isLoading = false;
      });
    }
  }

  // Créer une note via le serveur
  Future<void> _creerNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePage()),
    );

    if (result != null && result is Note) {
      final succes = await _apiService.createNote(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(succes
                ? '✅ Note créée sur le serveur !'
                : '❌ Erreur lors de la création'),
            backgroundColor: succes ? Colors.green : Colors.red,
          ),
        );
        if (succes) _chargerNotes(); // recharger la liste
      }
    }
  }

  // Supprimer une note via le serveur
  Future<void> _supprimerNote(Note note) async {
    final succes = await _apiService.deleteNote(note.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(succes
              ? '✅ Note supprimée du serveur !'
              : '❌ Erreur lors de la suppression'),
          backgroundColor: succes ? Colors.green : Colors.red,
        ),
      );
      if (succes) {
        setState(() {
          _notes.removeWhere((n) => n.id == note.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes API'),
        backgroundColor: Colors.blue,
        actions: [
          // Bouton rafraîchir
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _chargerNotes,
          ),
        ],
      ),

      body: _buildBody(),

      floatingActionButton: FloatingActionButton(
        onPressed: _creerNote,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    // État 1 — Chargement
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text('Chargement depuis le serveur...'),
          ],
        ),
      );
    }

    // État 2 — Erreur
    if (_erreur != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Erreur de connexion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _erreur!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _chargerNotes,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    // État 3 — Liste des notes
    return ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return Dismissible(
          key: Key(note.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) => _supprimerNote(note),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  note.id,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              title: Text(
                note.titre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                note.contenu.length > 50
                    ? '${note.contenu.substring(0, 50)}...'
                    : note.contenu,
              ),
            ),
          ),
        );
      },
    );
  }
}