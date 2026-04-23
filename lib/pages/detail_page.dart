import 'package:flutter/material.dart';
import '../models/note.dart';
import 'create_page.dart';

class DetailPage extends StatelessWidget {
  final Note note;
  const DetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final couleur = Color(
      int.parse('0xFF${note.couleur.replaceAll('#', '')}'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(note.titre),
        backgroundColor: couleur,
        actions: [
          // Bouton Modifier
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _modifier(context),
          ),
          // Bouton Supprimer
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmerSuppression(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Text(
              note.titre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Date de création
            Text(
              'Créée le ${_formaterDate(note.dateCreation)}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const Divider(height: 24),
            // Contenu complet
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  note.contenu,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Formater la date : "21 avril 2026 à 22:30"
  String _formaterDate(DateTime date) {
    const mois = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${mois[date.month - 1]} ${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Navigation vers CreatePage pour modifier
  void _modifier(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePage(note: note),
      ),
    );
    if (result != null) {
      Navigator.pop(context, result); // retourner la note modifiée
    }
  }

  // Boîte de confirmation pour supprimer
  void _confirmerSuppression(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la note ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // annuler
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // fermer dialog
              Navigator.pop(context, 'deleted'); // retourner 'deleted'
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}