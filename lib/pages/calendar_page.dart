import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart'; // Importar intl para formatear fechas
import '../utils/db.dart'; // Importar las variables globales
import 'players_page.dart'; // Importar PlayersPage

class CalendarPage extends StatelessWidget {
  final Random random = Random();

  // Generar jornadas al azar usando los equipos de las variables globales
  List<Map<String, dynamic>> generateJornadas() {
    final List<Map<String, dynamic>> jornadas = [];

    for (int i = 1; i <= 5; i++) {
      final List<Map<String, dynamic>> matches = [];
      final List<Map<String, dynamic>> shuffledTeams = List.from(globalTeams)..shuffle(random);

      for (int j = 0; j < shuffledTeams.length - 1; j += 2) {
        matches.add({
          'team1': shuffledTeams[j]['Nombre_Equipo'],
          'team2': shuffledTeams[j + 1]['Nombre_Equipo'],
          'team1Image': shuffledTeams[j]['image'] ?? 'assets/images/logos/default.png',
          'team2Image': shuffledTeams[j + 1]['image'] ?? 'assets/images/logos/default.png',
          'team1Id': shuffledTeams[j]['id_equipo'],
          'team2Id': shuffledTeams[j + 1]['id_equipo'],
          'date': '2025-03-${14 + i}', // Fechas consecutivas
          'time': '${18 + j % 3}:00', // Horas aleatorias
          'league': 'LEMC',
        });
      }

      jornadas.add({
        'jornada': 'Jornada $i',
        'matches': matches,
      });
    }

    return jornadas;
  }

  // Obtener el rango de fechas de una jornada
  String getJornadaDateRange(List<Map<String, dynamic>> matches) {
    final List<DateTime> dates = matches.map((match) {
      return DateTime.parse(match['date']);
    }).toList();

    dates.sort(); // Ordenar las fechas

    final DateFormat formatter = DateFormat('dd/MM/yyyy'); // Formato de México
    final String startDate = formatter.format(dates.first); // Fecha mínima
    final String endDate = formatter.format(dates.last); // Fecha máxima

    return '$startDate - $endDate'; // Rango de fechas
  }

  @override
  Widget build(BuildContext context) {
    final jornadas = generateJornadas();
    final screenWidth = MediaQuery.of(context).size.width; // Ancho de la pantalla
    final screenHeight = MediaQuery.of(context).size.height; // Alto de la pantalla

    return Scaffold(
      body: ListView.builder(
        itemCount: jornadas.length,
        itemBuilder: (context, jornadaIndex) {
          final jornada = jornadas[jornadaIndex];
          final String dateRange = getJornadaDateRange(jornada['matches']); // Obtener rango de fechas

          return Card(
            margin: EdgeInsets.all(screenWidth * 0.03), // Margen dinámico
            elevation: 5.0,
            child: ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    jornada['jornada'],
                    style: TextStyle(
                      fontSize: screenWidth * 0.04, // Tamaño dinámico basado en el ancho de la pantalla
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateRange, // Mostrar rango de fechas
                    style: TextStyle(
                      fontSize: screenWidth * 0.03, // Tamaño dinámico
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              children: jornada['matches'].map<Widget>((match) {
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Equipo 1 con redirección
                        Expanded(
                          flex: 4, // Ajustar el espacio proporcionalmente
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlayersPage(
                                        teamName: match['team1'], // Pasar el nombre del equipo 1
                                        userType: 'jugador',
                                        teamImage: match['team1Image'], // Pasar la imagen del equipo 1
                                        teamId: match['team1Id'].toString(), // Pasar el ID del equipo 1
                                      ),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: screenWidth * 0.2, // Tamaño dinámico del ancho de la imagen
                                  height: screenWidth * 0.2, // Tamaño dinámico del alto de la imagen
                                  child: Image.asset(
                                    match['team1Image'],
                                    fit: BoxFit.contain,
                                  ),
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
                        // Equipo 2 con redirección
                        Expanded(
                          flex: 4, // Ajustar el espacio proporcionalmente
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlayersPage(
                                        teamName: match['team2'], // Pasar el nombre del equipo 2
                                        userType: 'jugador',
                                        teamImage: match['team2Image'], // Pasar la imagen del equipo 2
                                        teamId: match['team2Id'].toString(), // Pasar el ID del equipo 2
                                      ),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: screenWidth * 0.2, // Tamaño dinámico del ancho de la imagen
                                  height: screenWidth * 0.2, // Tamaño dinámico del alto de la imagen
                                  child: Image.asset(
                                    match['team2Image'],
                                    fit: BoxFit.contain,
                                  ),
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
                    SizedBox(height: screenHeight * 0.02), // Espaciado dinámico
                    Divider(),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}