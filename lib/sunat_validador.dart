import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart' as path;
import 'dart:io';

class SunatRucValidator extends StatefulWidget {
  const SunatRucValidator({super.key});

  @override
  State<SunatRucValidator> createState() => _SunatRucValidatorState();
}

class _SunatRucValidatorState extends State<SunatRucValidator> {
  final _rucController = TextEditingController();
  String _response = '';

  // Función para consultar el RUC en la SUNAT y guardar el HTML en un archivo
  Future<void> _consultarRuc() async {
    final ruc = _rucController.text.trim();

    // Asegúrate de que el RUC tenga la longitud correcta
    if (ruc.length != 11) {
      setState(() {
        _response = "El RUC debe tener 11 dígitos.";
      });
      return;
    }

    // URL del formulario de la SUNAT (esto podría variar dependiendo de la página exacta)
    final url = Uri.parse(
        'https://e-consultaruc.sunat.gob.pe/cl-ti-itmrconsruc/FrameCriterioBusquedaWeb.jsp');

    // Datos del formulario a enviar (esto es un ejemplo, debes inspeccionar la página web para confirmar los nombres de los campos)
    final data = {
      'ruc': ruc, // Aquí va el número de RUC que se ingresa en el formulario
      'accion':
          'consPorRuc' // Este es el valor para el botón de consulta en el formulario, puede variar
    };

    try {
      log('data: $data');
      final response = await http.post(url, body: data);
      log('res: ${response.body}');

      if (response.statusCode == 200) {
        // Aquí debes procesar la respuesta
        setState(() {
          _response = 'Consulta realizada con éxito';
        });

        // Guardar el contenido HTML en un archivo
        await _saveHtmlToFile(response.body);
      } else {
        setState(() {
          _response = 'Error al consultar el RUC.';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Ocurrió un error: $e';
      });
    }
  }

  // Función para guardar el contenido HTML en un archivo
  Future<void> _saveHtmlToFile(String htmlContent) async {
    try {
      // Obtener el directorio donde se puede guardar el archivo
      final directory = await path.getApplicationDocumentsDirectory();

      // Crear la ruta del archivo dentro del directorio de documentos
      final filePath =
          '${directory.path}/respuesta_sunat_${DateTime.now().millisecondsSinceEpoch}.html';

      // Crear el archivo y escribir el contenido HTML
      final file = File(filePath);
      await file.writeAsString(htmlContent);

      log('Archivo guardado en: $filePath');

      // Opcional: Mostrar un mensaje de éxito
      setState(() {
        _response = 'Archivo guardado en: $filePath';
      });
    } catch (e) {
      setState(() {
        _response = 'Error al guardar el archivo: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta RUC SUNAT'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _rucController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ingresa el número de RUC',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _consultarRuc,
              child: const Text('Consultar RUC'),
            ),
            const SizedBox(height: 20),
            Text(
              _response,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
