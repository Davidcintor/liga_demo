import 'package:flutter/material.dart';
import 'package:my_first_real_app/utils/db.dart'; // Importar db.dart para acceder a las variables globales

class PlayerDetailPage extends StatefulWidget {
  final String playerId; // ID del jugador
  final String userType;
  final String teamId; // ID del equipo

  PlayerDetailPage({
    required this.playerId,
    required this.userType,
    required this.teamId,
  });

  @override
  _PlayerDetailPageState createState() => _PlayerDetailPageState();
}

class _PlayerDetailPageState extends State<PlayerDetailPage> {
  bool _isExpanded = false; // Controlar el estado de expansión

  void _navigateToTeamPage(BuildContext context, String teamName) {
    // Navegar a la página del equipo
    Navigator.pushNamed(context, '/teams', arguments: {'teamName': teamName});
  }

  @override
  Widget build(BuildContext context) {
    // Obtener los datos del jugador desde la base de datos global
    final player = globalPlayersByTeam[widget.teamId]?.firstWhere(
      (p) => p['id_jugador'].toString() == widget.playerId,
      orElse: () => {},
    );

    final team = globalTeams.firstWhere(
      (team) => team['id_equipo'].toString() == widget.teamId,
      orElse: () => {'Nombre_Equipo': 'No disponible', 'image': 'assets/images/logos/default.png'},
    );

    if (player == null || player.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalles del Jugador'),
        ),
        body: Center(
          child: Text(
            'No se encontraron datos del jugador.',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto de portada y perfil
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Foto de portada (logo del equipo desvanecido)
                Hero(
                  tag: 'teamLogo-${widget.teamId}', // Etiqueta única para la animación
                  child: Opacity(
                    opacity: 0.2, // Nivel de desvanecimiento
                    child: Image.asset(
                      team['image'] ?? 'assets/images/logos/default.png', // Logo del equipo
                      width: screenWidth, // Ajustar al ancho de la pantalla
                      height: screenWidth * 0.6, // Relación de aspecto 2:1
                      fit: BoxFit.contain, // Mostrar todo el logo
                    ),
                  ),
                ),
                // Foto de perfil del jugador
                Positioned(
                  bottom: -50, // Superponer la foto de perfil sobre la portada
                  child: Hero(
                    tag: 'playerLogo-${player['id_jugador']}', // Etiqueta única para la animación
                    child: CircleAvatar(
                      radius: screenWidth * 0.15, // Tamaño relativo al ancho de la pantalla
                      backgroundImage: NetworkImage(
                        player['playerImage'] ?? 'https://cdn-icons-png.flaticon.com/256/64/64572.png',
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.130),
            // Game ID del jugador
            Text(
              '${player['game_id'] ?? 'No disponible'}',
              style: TextStyle(fontSize: screenWidth * 0.08, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 96, 118, 139)),
            ),
            SizedBox(height: screenWidth * 0.001),
            // Plataforma con logo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (player['plataforma'] != null && player['plataforma']!.isNotEmpty)
                  Image.asset(
                    'assets/images/logos/${player['plataforma']}.png', // Ruta del logo de la plataforma
                    width: screenWidth * 0.05,
                    height: screenWidth * 0.05,
                    fit: BoxFit.contain,
                  ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  player['plataforma'] ?? 'No disponible',
                  style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            // Posiciones del jugador
            Text(
              'Posiciones: ${player['posicion'] ?? 'No disponible'}',
              style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.grey[600]),
            ),
            SizedBox(height: screenWidth * 0.02),
            // País del jugador
            Text(
              'País: ${player['pais']?.toString() ?? 'No disponible'}',
              style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.grey[600]),
            ),
            SizedBox(height: screenWidth * 0.02),
            // Equipo al que pertenece
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Equipo: ',
                  style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.grey[600]),
                ),
                GestureDetector(
      onTap: () => _navigateToTeamPage(
        context,
        team['Nombre_Equipo'] ?? 'No disponible',
      ),
      child: Text(
        team['Nombre_Equipo'] ?? 'No disponible',
        style: TextStyle(
          fontSize: screenWidth * 0.045,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),

            Divider(),
            SizedBox(height: screenWidth * 0.02),
            // Estadísticas del jugador con expansión
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded; // Alternar el estado de expansión
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Estadísticas del Jugador',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Colors.grey[800],
                  ),
                ],
              ),
            ),
            if (_isExpanded)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildStatRow('Apariciones', player['apariciones']?.toString() ?? '0', screenWidth),
                    Divider(color: Colors.grey[400]),
                    _buildStatRow('Goles', player['goles']?.toString() ?? '0', screenWidth),
                    Divider(color: Colors.grey[400]),
                    _buildStatRow('Asistencias', player['asistencias']?.toString() ?? '0', screenWidth),
                    Divider(color: Colors.grey[400]),
                    _buildStatRow('Tiros', player['tiros']?.toString() ?? '0', screenWidth),
                    Divider(color: Colors.grey[400]),
                    _buildStatRow('Precisión de Tiros', '${player['precision_tiros']?.toString() ?? '0'}%', screenWidth),
                    Divider(color: Colors.grey[400]),
                    _buildStatRow('Pases', player['pases']?.toString() ?? '0', screenWidth),
                    Divider(color: Colors.grey[400]),
                    _buildStatRow('Precisión de Pases', '${player['precision_pases']?.toString() ?? '0'}%', screenWidth),
                    Divider(color: Colors.grey[400]),
                    _buildStatRow('Regates', player['regates']?.toString() ?? '0', screenWidth),
                    Divider(color: Colors.grey[400]),
                    _buildStatRow('Precisión de Regates', '${player['precision_regates']?.toString() ?? '0'}%', screenWidth),
                    Divider(color: Colors.grey[400]),
                    _buildStatRow('Entradas', player['entradas']?.toString() ?? '0', screenWidth),
                    Divider(color: Colors.grey[400]),
                    _buildStatRow('Precisión de Entradas', '${player['precision_entradas']?.toString() ?? '0'}%', screenWidth),
                    Divider(color: Colors.grey[400]),
                    _buildStatRow('Tarjetas Amarillas', player['tarjetas_amarillas']?.toString() ?? '0', screenWidth),
                    Divider(color: Colors.grey[400]),
                    _buildStatRow('Tarjetas Rojas', player['tarjetas_rojas']?.toString() ?? '0', screenWidth),
                  ],
                ),
              ),
            SizedBox(height: screenWidth * 0.04),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String title, String value, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}