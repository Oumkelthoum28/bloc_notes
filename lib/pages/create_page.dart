import 'package:flutter/material.dart';
import '../models/note.dart';

class CreatePage extends StatefulWidget {
  final Note? note; // null = création, sinon = modification
  const CreatePage({super.key, this.note});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _titreController = TextEditingController();
  final _contenuController = TextEditingController();
  String _couleurChoisie = '#FFE082'; // jaune par défaut

  // Les 6 couleurs disponibles
  final List<String> _couleurs = [
    '#FFE082', // jaune
    '#EF9A9A', // rouge
    '#A5D6A7', // vert
    '#90CAF9', // bleu
    '#CE93D8', // violet
    '#FFCC80', // orange
  ];

  @override
  void initState() {
    super.initState();
    // Si on modifie une note existante → pré-remplir les champs
    if (widget.note != null) {
      _titreController.text = widget.note!.titre;
      _contenuController.text = widget.note!.contenu;
      _couleurChoisie = widget.note!.couleur;
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _contenuController.dispose();
    super.dispose();
  }

  void _sauvegarder() {
    // Validation : titre obligatoire
    if (_titreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le titre est obligatoire !')),
      );
      return;
    }

    final note = Note(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      titre: _titreController.text.trim(),
      contenu: _contenuController.text.trim(),
      couleur: _couleurChoisie,
      dateCreation: widget.note?.dateCreation ?? DateTime.now(),
      dateModification: widget.note != null ? DateTime.now() : null,
    );

    // Retourner la note à la page précédente
    Navigator.pop(context, note);
  }

  @override
  Widget build(BuildContext context) {
    final estModification = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(estModification ? 'Modifier la note' : 'Nouvelle Note'),
        backgroundColor: const Color.fromARGB(255, 7, 238, 255),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _sauvegarder,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Champ Titre
            TextField(
              controller: _titreController,
              maxLength: 60,
              decoration: const InputDecoration(
                labelText: 'Titre',
                hintText: 'Titre de la note...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Champ Contenu
            TextField(
              controller: _contenuController,
              minLines: 4,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Contenu',
                hintText: 'Écrivez votre note ici...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Sélecteur de couleur
            const Text(
              'Couleur :',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: _couleurs.map((couleur) {
                final estSelectionnee = couleur == _couleurChoisie;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _couleurChoisie = couleur;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse('0xFF${couleur.replaceAll('#', '')}'),
                      ),
                      shape: BoxShape.circle,
                      border: estSelectionnee
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}