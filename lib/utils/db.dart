import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;

// Variable global para almacenar el tipo de usuario actual
String userType = '';

// Variable global que contiene los datos de los usuarios y sus roles
final Map<String, String> usersData = {
  'test@example.com': 'admin',
  'capitan@example.com': 'capitan',
  'jugador@example.com': 'jugador',
};

// Variables globales para equipos y jugadores
List<Map<String, dynamic>> globalTeams = [];
Map<String, List<Map<String, dynamic>>> globalPlayersByTeam = {};

// Mapa de imágenes por ID de equipo
final Map<String, String> teamImages = {
  '1': 'assets/images/logos/JICALÁN.png',
  '2': 'assets/images/logos/SANTOSGRIFOS.png',
  '3': 'assets/images/logos/JOGO.png',
  '4': 'assets/images/logos/KingsOfTheNorth.png',
  '5': 'assets/images/logos/ONCe33.png',
  '6': 'assets/images/logos/Inmigración.png',
  '7': 'assets/images/logos/RoyalFamily.png',
  '8': 'assets/images/logos/RedsPanthers.png',
  '9': 'assets/images/logos/Lqraa.png',
  '10': 'assets/images/logos/Quetzalcotal.png',
  '11': 'assets/images/logos/DARKETOS.png',
  '12': 'assets/images/logos/ManquesFC.png',
  '13': 'assets/images/logos/Forasteros.png',
  '14': 'assets/images/logos/Wolfgaming.png',
  '15': 'assets/images/logos/StreetEsports.png',
  '16': 'assets/images/logos/LaSantaGaming.png',
};

Future<List<Map<String, dynamic>>?> fetchRawMatches() async {
  final url = Uri.parse('https://dev-lemc.onrender.com/partidos');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // Decodificar la respuesta como una lista de mapas
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al cargar los partidos: ${response.statusCode}');
    }
  } catch (e) {
    print('Error al cargar los partidos: $e');
    return null;
  }
}


Future<Map<String, dynamic>?> loadPlayerById(int idJugador) async {
  final url = Uri.parse('https://dev-lemc.onrender.com/jugadores/estadisticas/$idJugador');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {

      // Decodificar la respuesta como una lista y obtener el primer elemento
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        return data[0] as Map<String, dynamic>; // Retornar el primer jugador como un mapa
      } else {
        print('La lista de jugadores está vacía.');
        return null;
      }
    } else {
      print('Error al obtener los datos del jugador: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error al conectar con el servidor: $e');
    return null;
  }
}



// Función para cargar los equipos desde la API y asignar imágenes
// Función para cargar los equipos desde la API y asignar imágenes
Future<List<Map<String, dynamic>>?> loadTeams() async {
  final url = Uri.parse('https://dev-lemc.onrender.com/equipos');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // Decodificar la respuesta y mapear los datos
      globalTeams = List<Map<String, dynamic>>.from(json.decode(response.body)).map((team) {
        final teamId = team['id_equipo']?.toString() ?? ''; // Convertir id_equipo a String
        return {
          'id_equipo': teamId,
          'Nombre_Equipo': team['Nombre_Equipo'] ?? 'Nombre no disponible',
          'image': teamImages[teamId] ?? 'assets/images/logos/default.png', // Asignar imagen según el ID
          'grupo': team['grupo'] ?? 'Sin grupo', // Agregar el grupo del equipo
        };
      }).toList();
      return globalTeams;
    } else {
      throw Exception('Error al cargar los equipos: ${response.statusCode}');
    }
  } catch (e) {
    print('Error al cargar los equipos: $e');
    return null;
  }
}

// Función para cargar los jugadores de un equipo y almacenarlos en `globalPlayersByTeam`
Future<void> loadPlayersByTeam(String teamId) async {
  final url = Uri.parse('https://dev-lemc.onrender.com/equipos/$teamId');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      globalPlayersByTeam[teamId] = List<Map<String, dynamic>>.from(json.decode(response.body)).map((player) {
        return {
          'id_jugador': player['id_jugador'] ?? '',
          'game_id': player['game_id'] ?? '',
          'plataforma': player['plataforma'] ?? 'No disponible',
          'nombre': player['nombre'] ?? 'Nombre no disponible',
          'playerImage': player['playerImage'] ?? 'https://cdn-icons-png.flaticon.com/256/64/64572.png',
          'posicion': player['posicion'] ?? 'No disponible',
          'edad': player['edad'] ?? 'N/A',
          'facebook': player['facebook'] ?? '',
          'instagram': player['instagram'] ?? '',
          'youtube': player['youtube'] ?? '',
          'twitch': player['twitch'] ?? '',
          'pais': player['pais'] ?? 'No disponible',
        };
      }).toList();
    } else {
      throw Exception('Error al cargar los jugadores: ${response.statusCode}');
    }
  } catch (e) {
    print('Error al cargar los jugadores: $e');
  }


  
}