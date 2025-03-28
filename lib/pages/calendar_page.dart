import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import '../utils/db.dart'; // Importar la función fetchRawMatches y globalTeams

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<Map<String, dynamic>> jornadas = []; // Lista para almacenar las jornadas
  bool isLoading = true; // Estado de carga

  @override
  void initState() {
    super.initState();
    loadMatches(); // Llamar a la función para cargar los partidos
  }

  // Función para cargar los partidos y procesarlos
  Future<void> loadMatches() async {
    try {
      final rawMatches = await fetchRawMatches(); // Llamar a la función de db.dart
      if (rawMatches != null) {
        final List<Map<String, dynamic>> processedJornadas = [];
        for (var match in rawMatches) {
          // Buscar el equipo local por su ID
          final localTeam = globalTeams.firstWhere(
            (team) => team['id_equipo'] == match['equipo_local'].toString(),
            orElse: () => {'Nombre_Equipo': 'Desconocido', 'image': 'assets/images/logos/default.png'},
          );

          // Buscar el equipo visitante por su ID
          final visitanteTeam = globalTeams.firstWhere(
            (team) => team['id_equipo'] == match['equipo_visitante'].toString(),
            orElse: () => {'Nombre_Equipo': 'Desconocido', 'image': 'assets/images/logos/default.png'},
          );

          // Agregar los datos procesados a la lista
          processedJornadas.add({
            'id_partido': match['id_partido'],
            'team1': localTeam['Nombre_Equipo'],
            'team2': visitanteTeam['Nombre_Equipo'],
            'team1Image': localTeam['image'],
            'team2Image': visitanteTeam['image'],
            'team1Id': match['equipo_local'],
            'team2Id': match['equipo_visitante'],
            'date': match['fecha'],
            'time': match['hora'],
            'resultado_local': match['resultado_local'],
            'resultado_visitante': match['resultado_visitante'],
          });
        }

        setState(() {
          jornadas = processedJornadas;
          isLoading = false; // Finalizar la carga
        });
      } else {
        throw Exception('No se pudieron cargar los partidos.');
      }
    } catch (e) {
      print('Error al procesar los partidos: $e');
      setState(() {
        isLoading = false; // Finalizar la carga incluso si hay un error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // Ancho de la pantalla
    final screenHeight = MediaQuery.of(context).size.height; // Alto de la pantalla

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Mostrar un indicador de carga
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: jornadas.length,
        itemBuilder: (context, index) {
          final match = jornadas[index];
          final DateFormat formatter = DateFormat('dd/MM/yyyy');
          final String formattedDate = formatter.format(DateTime.parse(match['date']));

          return Card(
            margin: EdgeInsets.all(screenWidth * 0.03), // Margen dinámico
            elevation: 5.0,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Equipo local
                    Expanded(
                      flex: 4, // Ajustar el espacio proporcionalmente
                      child: Column(
                        children: [
                          SizedBox(
                            width: screenWidth * 0.2, // Tamaño dinámico del ancho de la imagen
                            height: screenWidth * 0.2, // Tamaño dinámico del alto de la imagen
                            child: Image.asset(
                              match['team1Image'],
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01), // Espaciado dinámico
                          Text(
                            match['team1'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04, // Tamaño dinámico del texto
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Texto "VS"
                    Expanded(
                      flex: 2, // Ajustar el espacio proporcionalmente
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02), // Espaciado dinámico
                        child: Text(
                          'VS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.07, // Tamaño dinámico del texto
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Equipo visitante
                    Expanded(
                      flex: 4, // Ajustar el espacio proporcionalmente
                      child: Column(
                        children: [
                          SizedBox(
                            width: screenWidth * 0.2, // Tamaño dinámico del ancho de la imagen
                            height: screenWidth * 0.2, // Tamaño dinámico del alto de la imagen
                            child: Image.asset(
                              match['team2Image'],
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01), // Espaciado dinámico
                          Text(
                            match['team2'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04, // Tamaño dinámico del texto
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01), // Espaciado dinámico
                Text(
                  '$formattedDate - ${match['time']}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey[700],
                  ),
                ),
                Divider(),
              ],
            ),
          );
        },
      ),
    );
  }
}