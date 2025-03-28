import 'package:flutter/material.dart';
import 'package:my_first_real_app/utils/db.dart';
import 'package:my_first_real_app/pages/player_detail_page.dart';
import 'package:my_first_real_app/pages/players_page.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  // IDs de los máximos goleadores
  final List<String> topScorerIds = [
    'carlos_hernandez',
    'alejandro_torres',
  ];

  // IDs de los máximos asistentes
  final List<String> topAssistIds = [
    'gabriel_jimenez',
    'roberto_vargas',
  ];

  // Resultados ficticios de partidos
  final List<Map<String, String>> matchResults = [
    {
      'date': '2025-03-14',
      'team1': 'Jicalán Esports',
      'team2': 'Santos Grifos FC',
      'score': '2-1',
      'team1Image': 'assets/images/logos/JICALÁN.png',
      'team2Image': 'assets/images/logos/SANTOSGRIFOS.png',
    },
    {
      'date': '2025-03-15',
      'team1': 'JOGO COIT DRK',
      'team2': 'Kings of the North',
      'score': '1-3',
      'team1Image': 'assets/images/logos/JOGO.png',
      'team2Image': 'assets/images/logos/KingsOfTheNorth.png',
    },
  ];

  bool _isLoading = true; // Indicador de carga
  List<Map<String, dynamic>> teams = []; // Lista de equipos desde la base de datos
  List<Map<String, dynamic>> players = []; // Lista de jugadores desde la base de datos

  @override
  void initState() {
    super.initState();
    _loadData(); // Cargar equipos y jugadores al iniciar
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true; // Mostrar indicador de carga
    });

    // Cargar equipos y jugadores desde la base de datos
    await loadTeams();
    await loadPlayers();

    setState(() {
      teams = globalTeams; // Asignar equipos cargados
      players = globalPlayersByTeam.values.expand((list) => list).toList(); // Convertir a una lista plana
      _isLoading = false; // Ocultar indicador de carga
    });
  }

  Future<void> loadPlayers() async {
    // Implementación ficticia para cargar jugadores
    await Future.delayed(Duration(seconds: 1)); // Simular tiempo de carga
    globalPlayersByTeam = {
      'team1': [
        {'id_jugador': 'carlos_hernandez', 'nombre': 'Carlos Hernández', 'teamName': 'Jicalán Esports', 'playerImage': ''},
        {'id_jugador': 'alejandro_torres', 'nombre': 'Alejandro Torres', 'teamName': 'Jicalán Esports', 'playerImage': ''},
      ],
      'team2': [
        {'id_jugador': 'gabriel_jimenez', 'nombre': 'Gabriel Jiménez', 'teamName': 'Santos Grifos FC', 'playerImage': ''},
        {'id_jugador': 'roberto_vargas', 'nombre': 'Roberto Vargas', 'teamName': 'Santos Grifos FC', 'playerImage': ''},
      ],
    };
  }

  void _navigateToPlayerProfile(BuildContext context, String playerId) {
    // Obtener los datos completos del jugador usando su ID
    final player = players.firstWhere(
      (player) => player['id_jugador'].toString() == playerId,
      orElse: () => {},
    );
  }

  void _navigateToTeamPage(BuildContext context, String teamName) {
    final team = teams.firstWhere(
      (team) => team['Nombre_Equipo'] == teamName,
      orElse: () => {'image': 'assets/images/logos/default.png'},
    );
    final teamImage = team['image']!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayersPage(
          teamName: teamName,
          userType: 'jugador',
          teamImage: teamImage,
          teamId: team['id_equipo'].toString(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Mostrar indicador de carga mientras se obtienen los datos
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Resultados de los Partidos',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: matchResults.length,
                    itemBuilder: (context, index) {
                      final match = matchResults[index];
                      final score = match['score']?.split('-') ?? ['0', '0'];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage(match['team1Image'] ?? ''),
                                backgroundColor: Colors.transparent,
                              ),
                              SizedBox(width: 8),
                              Text(
                                score[0],
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('${match['team1']} vs ${match['team2']}'),
                              Text('Fecha: ${match['date']}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                score[1],
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              CircleAvatar(
                                backgroundImage: AssetImage(match['team2Image'] ?? ''),
                                backgroundColor: Colors.transparent,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Máximos Goleadores',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: topScorerIds.length,
                    itemBuilder: (context, index) {
                      final player = players.firstWhere(
                        (player) => player['id_jugador'].toString() == topScorerIds[index],
                        orElse: () => {},
                      );
                      if (player.isEmpty) return SizedBox.shrink();
                      player['goals'] = (index == 0 ? 12 : 10).toString(); // Asignar goles ficticios
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(player['playerImage'] ?? ''),
                            backgroundColor: Colors.transparent,
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Jugador: ',
                                    style: TextStyle(fontSize: 15, color: Colors.black),
                                  ),
                                  GestureDetector(
                                    onTap: () => _navigateToPlayerProfile(context, player['id_jugador'].toString()),
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: Text(
                                        player['nombre'] ?? '',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text('Goles: ${player['goals']}'),
                              Row(
                                children: [
                                  Text(
                                    'Equipo: ',
                                    style: TextStyle(fontSize: 15, color: Colors.black),
                                  ),
                                  GestureDetector(
                                    onTap: () => _navigateToTeamPage(context, player['teamName'] ?? ''),
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: Text(
                                        player['teamName'] ?? 'Desconocido',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}