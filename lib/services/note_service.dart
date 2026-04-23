import 'package:flutter/material.dart';
import '../models/note.dart';

// Les options de tri
enum TriOption {
  dateRecent,   // plus récent d'abord
  dateAncien,   // plus ancien d'abord
  titreAZ,      // A → Z
  titreZA,      // Z → A
}

class NoteService extends ChangeNotifier {
  final List<Note> _notes = [];
  
  // Option de tri actuelle
  TriOption _tri = TriOption.dateRecent;
  TriOption get tri => _tri;

  // Changer le tri
  void changerTri(TriOption option) {
    _tri = option;
    notifyListeners();
  }

  // Retourner les notes triées
  List<Note> get notes {
    final liste = List<Note>.from(_notes);
    switch (_tri) {
      case TriOption.dateRecent:
        liste.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
        break;
      case TriOption.dateAncien:
        liste.sort((a, b) => a.dateCreation.compareTo(b.dateCreation));
        break;
      case TriOption.titreAZ:
        liste.sort((a, b) => a.titre.compareTo(b.titre));
        break;
      case TriOption.titreZA:
        liste.sort((a, b) => b.titre.compareTo(a.titre));
        break;
    }
    return List.unmodifiable(liste);
  }

  // Nombre de notes
  int get count => _notes.length;

  // Ajouter une note
  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }

  // Modifier une note
  void updateNote(Note note) {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      notifyListeners();
    }
  }

  // Supprimer une note
  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // Chercher une note par id
  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  // Rechercher des notes
  List<Note> search(String query) {
    if (query.isEmpty) return notes;
    return notes
        .where((n) =>
            n.titre.toLowerCase().contains(query.toLowerCase()) ||
            n.contenu.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}