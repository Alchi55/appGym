import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/food_record.dart';
import 'screens/camera_screen.dart';

late Isar isar;
late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");  
  // Iniciar cámara
  cameras = await availableCameras();
  
  // Iniciar base de datos local
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [FoodRecordSchema],
    directory: dir.path,
  );

  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IA Fitness',
      theme: ThemeData.dark(), // Tema oscuro, ideal para fitness
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Diario')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Calorías consumidas: 0', style: TextStyle(fontSize: 24)),
            Text('Calorías quemadas: 0', style: TextStyle(fontSize: 24, color: Colors.orange)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CameraScreen(cameras: cameras)),
          );
        },
        icon: const Icon(Icons.restaurant),
        label: const Text('Escanear Comida'),
      ),
    );
  }
}
