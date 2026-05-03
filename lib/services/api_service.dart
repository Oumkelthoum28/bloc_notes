import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';

class ApiService {
  // Serveur de test gratuit
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // GET → récupérer toutes les notes du serveur
  Future<List<Note>> getAllNotes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        // On prend seulement les 10 premiers pour ne pas surcharger
        return jsonList.take(10).map((json) => Note(
          id: json['id'].toString(),
          titre: json['title'] ?? 'Sans titre',
          contenu: json['body'] ?? '',
          couleur: '#FFE082',
          dateCreation: DateTime.now(),
        )).toList();
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau : $e');
    }
  }

  // POST → créer une note sur le serveur
  Future<bool> createNote(Note note) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': note.titre,
          'body': note.contenu,
          'userId': 1,
        }),
      );
      return response.statusCode == 201; // 201 = créé avec succès
    } catch (e) {
      return false;
    }
  }

  // DELETE → supprimer une note du serveur
  Future<bool> deleteNote(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/posts/$id'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}