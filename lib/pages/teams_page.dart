import 'dart:async'; // Importar para usar Stream
import 'package:flutter/material.dart';
import 'package:my_first_real_app/utils/db.dart'; // Importar las variables globales
import 'players_page.dart'; // Importar PlayersPage

class TeamsPage extends StatefulWidget {
  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  String userType = 'jugador'; // Tipo de usuario
  bool _isLoading = true; // Variable para mostrar el indicador de carga

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTeams(); // Cargar los equipos cada vez que la página se selecciona
  }

  Future<void> _loadTeams() async {
    setState(() {
      _isLoading = true; // Mostrar el indicador de carga
    });
    await loadTeams(); // Llama a la función para cargar los equipos desde la base de datos
    setState(() {
      _isLoading = false; // Ocultar el indicador de carga
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // Ancho de la pantalla
    final screenHeight = MediaQuery.of(context).size.height; // Alto de la pantalla

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Mostrar indicador de carga si no hay datos
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Grupo A
                  Card(
                    margin: EdgeInsets.all(screenWidth * 0.03),
                    child: ExpansionTile(
                      title: Text(
                        'Grupo A',
                        style: TextStyle(
                          fontSize: screenWidth * 0.06, // Tamaño dinámico del texto
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: globalTeams
                          .where((team) => team['grupo'] == 'A')
                          .map((team) {
                        return Card(
                          margin: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.01,
                            horizontal: screenWidth * 0.03,
                          ),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(screenWidth * 0.04),
                            leading: Hero(
                              tag: 'teamLogo-${team['id_equipo']}', // Etiqueta única para la animación
                              child: Container(
                                width: screenWidth * 0.2, // Tamaño dinámico del ancho de la imagen
                                height: screenWidth * 0.2, // Tamaño dinámico del alto de la imagen
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8), // Bordes redondeados opcionales
                                ),
                                child: Image.asset(
                                  team['image'] ?? 'assets/images/logos/default.png',
                                  fit: BoxFit.contain, // Mostrar la imagen completa
                                ),
                              ),
                            ),
                            title: Text(
                              team['Nombre_Equipo'] ?? 'Nombre no disponible',
                              style: TextStyle(
                                fontSize: screenWidth * 0.05, // Tamaño dinámico del texto
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () async {
                              // Cargar jugadores del equipo seleccionado
                              await loadPlayersByTeam(team['id_equipo'].toString());
                              // Navegar a la pantalla de jugadores
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlayersPage(
                                    teamName: team['Nombre_Equipo'] ?? 'Nombre no disponible',
                                    userType: userType,
                                    teamImage: team['image'] ?? 'assets/images/logos/default.png',
                                    teamId: team['id_equipo'].toString(),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Grupo B
                  Card(
                    margin: EdgeInsets.all(screenWidth * 0.03),
                    child: ExpansionTile(
                      title: Text(
                        'Grupo B',
                        style: TextStyle(
                          fontSize: screenWidth * 0.06, // Tamaño dinámico del texto
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: globalTeams
                          .where((team) => team['grupo'] == 'B')
                          .map((team) {
                        return Card(
                          margin: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.01,
                            horizontal: screenWidth * 0.03,
                          ),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(screenWidth * 0.04),
                            leading: Hero(
                              tag: 'teamLogo-${team['id_equipo']}', // Etiqueta única para la animación
                              child: Container(
                                width: screenWidth * 0.2, // Tamaño dinámico del ancho de la imagen
                                height: screenWidth * 0.2, // Tamaño dinámico del alto de la imagen
                                child: Image.asset(
                                  team['image'] ?? 'assets/images/logos/default.png',
                                  fit: BoxFit.contain, // Mostrar la imagen completa
                                ),
                              ),
                            ),
                            title: Text(
                              team['Nombre_Equipo'] ?? 'Nombre no disponible',
                              style: TextStyle(
                                fontSize: screenWidth * 0.05, // Tamaño dinámico del texto
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () async {
                              // Cargar jugadores del equipo seleccionado
                              await loadPlayersByTeam(team['id_equipo'].toString());
                              // Navegar a la pantalla de jugadores
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlayersPage(
                                    teamName: team['Nombre_Equipo'] ?? 'Nombre no disponible',
                                    userType: userType,
                                    teamImage: team['image'] ?? 'assets/images/logos/default.png',
                                    teamId: team['id_equipo'].toString(),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}