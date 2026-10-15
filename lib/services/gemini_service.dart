import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../main.dart';
import '../models/food_record.dart';

class GeminiService {
  // Obtiene la API Key directamente del archivo .env
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static Future<FoodRecord?> analyzeAndSaveFood(File imageFile) async {
    try {
      if (_apiKey.isEmpty) {
        debugPrint('Error: No se encontró la GEMINI_API_KEY en el archivo .env');
        return null;
      }

      // Configurar el modelo Gemini 1.5 Flash forzando respuesta JSON
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      const prompt = '''
        Analiza esta imagen de comida. Estima los macronutrientes y calorías totales.
        Devuelve ÚNICAMENTE un objeto JSON con esta estructura exacta, sin texto adicional:
        {
          "foodName": "Nombre descriptivo en español",
          "calories": 500,
          "protein": 30.5,
          "carbs": 40.0,
          "fat": 15.2
        }
      ''';

      // Leer la foto en bytes para enviarla a la IA
      final imageBytes = await imageFile.readAsBytes();
      final imagePart = DataPart('image/jpeg', imageBytes);

      // Enviar el prompt y la imagen a Gemini
      final response = await model.generateContent([
        Content.multi([TextPart(prompt), imagePart])
      ]);

      if (response.text == null || response.text!.isEmpty) {
        debugPrint('Error: Gemini no devolvió ninguna respuesta.');
        return null;
      }

      // Parsear la respuesta JSON devuelta por la IA
      final Map<String, dynamic> data = jsonDecode(response.text!);

      // Crear el objeto del registro de comida
      final newRecord = FoodRecord()
        ..foodName = data['foodName'] ?? 'Comida sin nombre'
        ..calories = (data['calories'] as num).toInt()
        ..protein = (data['protein'] as num).toDouble()
        ..carbs = (data['carbs'] as num).toDouble()
        ..fat = (data['fat'] as num).toDouble()
        ..date = DateTime.now();

      // Guardar el registro directamente en la base de datos Isar
      await isar.writeTxn(() async {
        await isar.foodRecords.put(newRecord);
      });

      return newRecord;
    } catch (e) {
      debugPrint('Error en GeminiService: $e');
      return null;
    }
  }
}
