import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'create_page.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // uniquement pour la recherche
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final noteService = context.watch<NoteService>();
    // Si recherche vide → toutes les notes, sinon → notes filtrées
    final notes = _query.isEmpty
        ? noteService.notes
        : noteService.search(_query);

    return Scaffold(
      appBar: AppBar(
  backgroundColor: Colors.amber,
  title: const Text('Mes Notes'),
  actions: [
    // Bouton de tri
    PopupMenuButton<TriOption>(
      icon: const Icon(Icons.sort),
      onSelected: (option) {
        context.read<NoteService>().changerTri(option);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: TriOption.dateRecent,
          child: Row(
            children: [
              Icon(Icons.arrow_downward, size: 18),
              SizedBox(width: 8),
              Text('Plus récent d\'abord'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: TriOption.dateAncien,
          child: Row(
            children: [
              Icon(Icons.arrow_upward, size: 18),
              SizedBox(width: 8),
              Text('Plus ancien d\'abord'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: TriOption.titreAZ,
          child: Row(
            children: [
              Icon(Icons.sort_by_alpha, size: 18),
              SizedBox(width: 8),
              Text('Titre A → Z'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: TriOption.titreZA,
          child: Row(
            children: [
              Icon(Icons.sort_by_alpha, size: 18),
              SizedBox(width: 8),
              Text('Titre Z → A'),
            ],
          ),
        ),
      ],
    ),
    // Compteur de notes
    Consumer<NoteService>(
      builder: (context, service, child) {
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Text(
              '${service.count} notes',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    ),
  ],
),

      // Barre de recherche sous l'AppBar
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _query = value; // mettre à jour la recherche
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher une note...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _query = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Liste des notes
          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Text(
                      _query.isEmpty
                          ? 'Aucune note pour l\'instant'
                          : 'Aucun résultat pour "$_query"',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return _buildNoteCard(context, note);
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _ouvrirCreation(context),
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Color(
                int.parse('0xFF${note.couleur.replaceAll('#', '')}'),
              ),
              width: 5,
            ),
          ),
        ),
        child: ListTile(
          onTap: () => _ouvrirDetail(context, note),
          title: Text(
            note.titre,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            note.contenu.length > 30
                ? '${note.contenu.substring(0, 30)}...'
                : note.contenu,
          ),
          trailing: Text(
            '${note.dateCreation.day}/${note.dateCreation.month}/${note.dateCreation.year}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  void _ouvrirCreation(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePage()),
    );
    if (result != null && result is Note) {
      context.read<NoteService>().addNote(result);
    }
  }

  void _ouvrirDetail(BuildContext context, Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPage(note: note)),
    );
    if (result == 'deleted') {
      context.read<NoteService>().deleteNote(note.id);
    } else if (result is Note) {
      context.read<NoteService>().updateNote(result);
    }
  }
}