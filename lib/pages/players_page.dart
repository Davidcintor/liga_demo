import 'package:flutter/material.dart';
import 'package:my_first_real_app/pages/player_detail_page.dart';
import 'package:my_first_real_app/utils/db.dart'; // Importar las variables globales

class PlayersPage extends StatefulWidget {
  final String teamName; // Nombre del equipo
  final String userType; // Tipo de usuario
  final String teamImage; // Imagen del equipo
  final String teamId; // ID del equipo para buscar jugadores en las variables globales

  PlayersPage({
    required this.teamName,
    required this.userType,
    required this.teamImage,
    required this.teamId,
  });

  @override
  _PlayersPageState createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  bool _isLoading = true; // Variable para mostrar el indicador de carga
  List<Map<String, dynamic>> players = []; // Lista de jugadores

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPlayers(); // Cargar los jugadores cada vez que se accede a la página
  }

  Future<void> _loadPlayers() async {
    setState(() {
      _isLoading = true; // Mostrar el indicador de carga
    });
    await loadPlayersByTeam(widget.teamId); // Cargar los jugadores desde la base de datos
    setState(() {
      players = globalPlayersByTeam[widget.teamId] ?? []; // Actualizar la lista de jugadores
      _isLoading = false; // Ocultar el indicador de carga
    });
  }

  void _navigateToPlayerProfile(BuildContext context, Map<String, dynamic> player) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerDetailPage(
          playerId: player['id_jugador'].toString(), // Pasar el ID del jugador
          userType: widget.userType, // Pasar el tipo de usuario
          teamId: widget.teamId, // Pasar el ID del equipo
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Equipo'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Mostrar indicador de carga mientras se obtienen los datos
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 16),
                  Hero(
                    tag: 'teamLogo-${widget.teamId}', // Etiqueta única para la animación
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: Image.asset(
                        widget.teamImage,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.teamName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  Text(
                    'Jugadores:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 64, 92, 117)),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          leading: Hero(
                            tag: 'playerLogo-${player['id_jugador']}', // Etiqueta única para la animación
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                              ),
                              child: Image.asset(
                                'assets/images/logos/user.png', // Imagen local para los jugadores
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                            player['game_id'] ?? 'Nombre no disponible',
                            style: TextStyle(
                              fontSize: 18, // Cambiar el tamaño del texto
                              color: const Color.fromARGB(255, 79, 116, 145),
                              fontWeight: FontWeight.bold, // Poner el texto en negritas
                            ),
                          ),
                          onTap: () => _navigateToPlayerProfile(context, player),
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