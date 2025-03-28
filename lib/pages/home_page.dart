import 'package:flutter/material.dart';
import 'package:my_first_real_app/pages/statistics_page.dart';
import 'package:my_first_real_app/pages/teams_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'calendar_page.dart';
import 'user_page.dart';
import 'package:my_first_real_app/utils/db.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Map<String, dynamic>? user; // Datos del usuario cargados desde la base de datos
  bool _isLoading = true; // Indicador de carga

  final List<Widget> _widgetOptions = <Widget>[
    const Placeholder(), // Placeholder temporal, se actualizará en initState
    CalendarPage(),
    StatisticsPage(),
    TeamsPage(),
    UserPage(),
  ];

  static const List<String> _titles = <String>[
    'Inicio',
    'Calendario - Segunda Temporada',
    'Estadísticas',
    'Equipos',
    'Usuario',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('id_jugador'); // Obtener el ID del usuario desde SharedPreferences

    if (userId != null) {
      final userData = await loadPlayerById(userId); // Cargar datos del usuario desde la base de datos
      setState(() {
        user = userData;
        _widgetOptions[0] = WelcomeWidget(user: user); // Pasar los datos del usuario al widget de bienvenida
        _isLoading = false; // Finalizar la carga
      });
    } else {
      setState(() {
        _isLoading = false; // Finalizar la carga incluso si no hay usuario
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el ID del usuario en SharedPreferences')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Mostrar indicador de carga
          : Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class WelcomeWidget extends StatelessWidget {
  final Map<String, dynamic>? user;

  const WelcomeWidget({super.key, required this.user});

  // Función para obtener el logo del equipo
  String _getTeamLogo(String? idEquipo) {
    return teamImages[idEquipo] ?? 'assets/images/logos/default.png';
  }

  // Función para abrir enlaces
  void _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Intentando abrir en el navegador: $url');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el enlace: $url')),
        );
      }
    } catch (e) {
      debugPrint('Error al intentar abrir el enlace: $url. Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al intentar abrir el enlace: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // Ancho de la pantalla
    final screenHeight = MediaQuery.of(context).size.height; // Alto de la pantalla

    // Obtener el logo del equipo al que pertenece el usuario
    final String teamLogo = _getTeamLogo(user?['id_equipo']?.toString());
    final String logoApp = 'assets/images/logos/LOGOLIGALEMC.png';

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Logo de la aplicación
          Divider(),
          SizedBox(height: screenHeight * 0.05), // Espaciado dinámico
          // Texto de bienvenida
          Text(
            '¡Bienvenido, ${user?['nombre'] ?? 'Usuario'}!', // Mostrar el nombre del usuario
            style: TextStyle(
              fontSize: screenWidth * 0.08, // Tamaño dinámico del texto
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 54, 94, 139),
            ),
            textAlign: TextAlign.center,
          ),
          // Mostrar el logo del equipo
          Opacity(
            opacity: 0.5, // Nivel de desvanecimiento
            child: Image.asset(
              teamLogo,
              width: screenWidth * 0.6, // Tamaño dinámico del logo
              height: screenWidth * 0.6, // Tamaño dinámico del logo
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: screenHeight * 0.05), // Espaciado dinámico
          Divider(),
          Opacity(
            opacity: 0.9, // Nivel de desvanecimiento
            child: Image.asset(
              logoApp,
              width: screenWidth * 0.25, // Tamaño dinámico del logo
              height: screenWidth * 0.25, // Tamaño dinámico del logo
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: screenHeight * 0.02), // Espaciado dinámico

          Text(
            'No olvides seguirnos en nuestras redes sociales',
            style: TextStyle(
              fontSize: screenWidth * 0.037, // Tamaño dinámico del texto
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center, // Centrar el texto
          ),
          SizedBox(height: screenHeight * 0.02), // Espaciado dinámico
          // Redes sociales
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Image.network(
                  'https://cdn-icons-png.flaticon.com/512/733/733547.png', // Logo de Facebook
                  width: screenWidth * 0.1, // Tamaño dinámico del icono
                  height: screenWidth * 0.1, // Tamaño dinámico del icono
                ),
                onPressed: () => _launchURL(context, 'https://www.facebook.com'),
              ),
              SizedBox(width: screenWidth * 0.04), // Espaciado dinámico
              IconButton(
                icon: Image.network(
                  'https://cdn-icons-png.flaticon.com/512/2111/2111463.png', // Logo de Instagram
                  width: screenWidth * 0.1, // Tamaño dinámico del icono
                  height: screenWidth * 0.1, // Tamaño dinámico del icono
                ),
                onPressed: () => _launchURL(context, 'https://www.instagram.com/ligalemc'),
              ),
              SizedBox(width: screenWidth * 0.04), // Espaciado dinámico
              IconButton(
                icon: Image.network(
                  'https://cdn-icons-png.flaticon.com/512/1384/1384060.png', // Logo de YouTube
                  width: screenWidth * 0.1, // Tamaño dinámico del icono
                  height: screenWidth * 0.1, // Tamaño dinámico del icono
                ),
                onPressed: () => _launchURL(context, 'https://www.youtube.com/ligalemc'),
              ),
              SizedBox(width: screenWidth * 0.04), // Espaciado dinámico
              IconButton(
                icon: Image.network(
                  'https://cdn-icons-png.flaticon.com/512/2111/2111668.png', // Logo de Twitch
                  width: screenWidth * 0.1, // Tamaño dinámico del icono
                  height: screenWidth * 0.1, // Tamaño dinámico del icono
                ),
                onPressed: () => _launchURL(context, 'https://www.twitch.tv/ligalemc'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}