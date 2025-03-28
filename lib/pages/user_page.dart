import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/db.dart'; // Importar la función `loadPlayerById` y `loadTeams`
import 'players_page.dart'; // Importar PlayersPage

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int? _idUsuario;
  String _userTypeText = 'Cargando...';
  Map<String, dynamic>? _playerData; // Datos del jugador
  List<Map<String, dynamic>> _teams = []; // Lista de equipos
  bool _isLoading = true; // Indicador de carga
  bool _showStats = false; // Controlar la expansión de las estadísticas

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUsuario = prefs.getInt('id_jugador'); // Obtener el id_jugador de SharedPreferences
      final userType = prefs.getInt('user_type');

      // Asignar el texto correspondiente al userType
      if (userType == 1) {
        _userTypeText = 'Admin';
      } else if (userType == 2) {
        _userTypeText = 'Capitán';
      } else if (userType == 3) {
        _userTypeText = 'Jugador';
      } else {
        _userTypeText = 'Desconocido';
      }
    });

    // Cargar los equipos desde la base de datos
    final teams = await loadTeams();
    setState(() {
      _teams = teams ?? []; // Guardar los equipos en la variable
    });

    // Buscar al jugador directamente desde la base de datos
    if (_idUsuario != null) {
      _fetchPlayerData(_idUsuario!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se encontró el ID del usuario en SharedPreferences')),
      );
    }
  }

  void _fetchPlayerData(int idJugador) async {
    setState(() {
      _isLoading = true; // Mostrar indicador de carga
    });

    // Llamar a la función para obtener los datos del jugador desde la base de datos
    final player = await loadPlayerById(idJugador);

    if (player != null) {
      setState(() {
        _playerData = player; // Guardar los datos del jugador
        _isLoading = false; // Finalizar la carga
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se encontraron datos del jugador.')),
      );
    }
  }

    /// Obtener la imagen del equipo según el `id_equipo`
  String _getTeamLogo(String? idEquipo) {
    return teamImages[idEquipo] ?? 'assets/images/logos/default.png';
  }

  Map<String, String>? _getTeamName(String? idEquipo) {
    if (idEquipo == null) return null;

    // Buscar el equipo en la lista de equipos
    final team = _teams.firstWhere(
      (team) => team['id_equipo'] == idEquipo,
      orElse: () => {},
    );

    if (team.isNotEmpty) {
      return {
        'Nombre_Equipo': team['Nombre_Equipo'],
        'grupo': team['grupo'],
        'image': team['image'],
      };
    }
    return null;
  }

  /// Función para obtener el logo de la plataforma
  String _getPlatformLogo(String? plataforma) {
    switch (plataforma) {
      case 'Xbox':
        return 'assets/images/logos/Xbox.png';
      case 'PlayStation':
        return 'assets/images/logos/PlayStation.png';
      case 'PC':
        return 'assets/images/logos/PC.png';
      default:
        return 'assets/images/logos/user.png'; // Logo predeterminado si no se encuentra la plataforma
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamInfo = _getTeamName(_playerData?['id_equipo']?.toString());
    final String teamId = _playerData?['id_equipo']?.toString() ?? '';
    final String teamLogo = _getTeamLogo(teamId);
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Fondo desvanecido con el logo del equipo
                Hero(
                  tag: 'teamLogo-$teamId', // Etiqueta única para la animación
                  child: Opacity(
                    opacity: 0.2, // Nivel de desvanecimiento
                    child: Image.asset(
                      teamLogo, // Logo del equipo
                      width: double.infinity,
                      height: 250, // Puedes ajustar esta altura
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Foto de perfil del jugador
                Positioned(
                  bottom: -50,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      _playerData?['playerImage'] ??
                          'https://cdn-icons-png.flaticon.com/256/64/64572.png', // Imagen de perfil
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 60), // Espacio para la imagen de perfil
            _isLoading
                ? CircularProgressIndicator()
                : _playerData != null
                    ? Column(
                        children: [
                          // Game ID
                          Text(
                            _playerData!['game_id'] ?? 'Sin Game ID',
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 54, 94, 139),
                            ),
                          ),
                          SizedBox(height: 1),

                          // Nombre del jugador
                          Text(
                            _playerData!['nombre'] ?? 'Sin nombre',
                            style: TextStyle(fontSize: 20, color: Colors.grey[800]),
                          ),
                          SizedBox(height: 8),

                          // Plataforma con logo
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_playerData!['plataforma'] != null)
                                Image.asset(
                                  _getPlatformLogo(_playerData!['plataforma']),
                                  width: 20,
                                ),
                              SizedBox(width: 8),
                              Text(
                                _playerData!['plataforma'] ?? 'Sin plataforma',
                                style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),

                          // Equipo con enlace
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Equipo:',
                                style: TextStyle(fontSize: 20, color: Colors.grey[800]),
                              ),
                              SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {
                                  if (teamInfo != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PlayersPage(
                                          teamName: teamInfo['Nombre_Equipo'] ?? 'Sin equipo',
                                          userType: _userTypeText,
                                          teamImage: teamLogo,
                                          teamId: _playerData!['id_equipo']?.toString() ?? '',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                
                                  
                                child: Text(
                                  teamInfo?['Nombre_Equipo'] ?? 'Sin equipo',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              
                              ),
                            ],
                          ),
                          SizedBox(height: 8),

                          // Posiciones
                          Text(
                            'Posiciones: ${_playerData!['posicion'] ?? 'No disponible'}',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),

                          // País
                          Text(
                            'País: ${_playerData!['pais'] ?? 'No disponible'}',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),

                          // Género
                          Text(
                            'Género: ${_playerData!['genero'] ?? 'No disponible'}',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),

                          // Edad
                          Text(
                            'Edad: ${_playerData!['edad'] ?? 'N/A'} años',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 16),

                          // Estadísticas del jugador (expandibles)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showStats = !_showStats; // Alternar expansión
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Estadísticas del jugador',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                Icon(
                                  _showStats ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                          if (_showStats)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 70.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: _playerData!.entries
                                    .where((entry) => [
                                          'apariciones',
                                          'goles',
                                          'asistencias',
                                          'tiros',
                                          'precision_tiros',
                                          'pases',
                                          'precision_pases',
                                          'regates',
                                          'precision_regates',
                                          'entradas',
                                          'precision_entradas',
                                          'tarjetas_amarillas',
                                          'tarjetas_rojas',
                                        ].contains(entry.key))
                                    .map((entry) {
                                  // Verificar si la estadística es un porcentaje
                                  final isPercentage = [
                                    'precision_tiros',
                                    'precision_pases',
                                    'precision_regates',
                                    'precision_entradas',
                                  ].contains(entry.key);

                                  // Formatear el valor
                                  final value = isPercentage
                                      ? '${entry.value}%' 
                                      : '${entry.value} .';
 
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Row(
                                          children: [
                                            // Nombre de la estadística alineado a la izquierda
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                entry.key.replaceAll('_', ' ').toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                            // Valor de la estadística alineado a la derecha
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                value,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Divider con longitud personalizable
                                      Divider(
                                        thickness: 1.0,
                                        indent: 1.0, // Cambia este valor para ajustar el largo del Divider
                                        endIndent: 1.0, // Cambia este valor para ajustar el largo del Divider
                                        color: Colors.grey[400],
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          if (_playerData!['facebook'] != null && _playerData!['facebook']!.isNotEmpty)
                            ListTile(
                              leading: Image.network(
                                'https://cdn-icons-png.flaticon.com/512/733/733547.png',
                                width: 30,
                              ), // Facebook logo
                              title: Text(_playerData!['facebook']),
                            ),
                          if (_playerData!['instagram'] != null && _playerData!['instagram']!.isNotEmpty)
                            ListTile(
                              leading: Image.network(
                                'https://cdn-icons-png.flaticon.com/512/2111/2111463.png',
                                width: 30,
                              ), // Instagram logo
                              title: Text(_playerData!['instagram']),
                            ),
                          if (_playerData!['youtube'] != null && _playerData!['youtube']!.isNotEmpty)
                            ListTile(
                              leading: Image.network(
                                'https://cdn-icons-png.flaticon.com/512/1384/1384060.png',
                                width: 30,
                              ), // YouTube logo
                              title: Text(_playerData!['youtube']),
                            ),
                          if (_playerData!['twitch'] != null && _playerData!['twitch']!.isNotEmpty)
                            ListTile(
                              leading: Image.network(
                                'https://cdn-icons-png.flaticon.com/512/2111/2111668.png',
                                width: 30,
                              ), // Twitch logo
                              title: Text(_playerData!['twitch']),
                            ),
                          SizedBox(height: 20),

                          // Botón de logout
                          ElevatedButton(
                            onPressed: () => _logout(context), // Llamar a la función de logout
                            child: Text('Logout'),
                          ),
                        ],
                      )
                    : Text('Jugador no encontrado'),
          ],
        ),
      ),
    );
  }
}