import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

enum TriOption {
  dateRecent,
  dateAncien,
  titreAZ,
  titreZA,
}

class NoteService extends ChangeNotifier {
  final List<Note> _notes = [];
  final SharedPreferences _prefs;
  static const String _key = 'notes'; // clé de sauvegarde

  // Constructeur — reçoit l'instance SharedPreferences
  NoteService(this._prefs) {
    _loadNotes(); // charger les notes au démarrage
  }

  TriOption _tri = TriOption.dateRecent;
  TriOption get tri => _tri;

  void changerTri(TriOption option) {
    _tri = option;
    notifyListeners();
  }

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

  int get count => _notes.length;

  // Charger les notes depuis SharedPreferences
  void _loadNotes() {
    final String? data = _prefs.getString(_key);
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      _notes.clear();
      _notes.addAll(jsonList.map((e) => Note.fromJson(e)).toList());
      notifyListeners();
    }
  }

  // Sauvegarder les notes dans SharedPreferences
  Future<void> _saveNotes() async {
    final String data = jsonEncode(_notes.map((e) => e.toJson()).toList());
    await _prefs.setString(_key, data);
  }

  void addNote(Note note) {
    _notes.add(note);
    _saveNotes(); // sauvegarder
    notifyListeners();
  }

  void updateNote(Note note) {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      _saveNotes(); // sauvegarder
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    _saveNotes(); // sauvegarder
    notifyListeners();
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Note> search(String query) {
    if (query.isEmpty) return notes;
    return notes
        .where((n) =>
            n.titre.toLowerCase().contains(query.toLowerCase()) ||
            n.contenu.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}