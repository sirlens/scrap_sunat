import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class SunatNval extends StatefulWidget {
  const SunatNval({super.key});

  @override
  State<SunatNval> createState() => _SunatRucValidatorState();
}

class _SunatRucValidatorState extends State<SunatNval> {
  final _rucController = TextEditingController();
  String _response = '';
  String _fiscalAddress = '';

  Future<void> _consultarRuc() async {
    final ruc = _rucController.text.trim();

    if (ruc.length != 11) {
      setState(() {
        _response = "El RUC debe tener 11 dígitos.";
        _fiscalAddress = '';
      });
      return;
    }

    try {
      // Primera solicitud para obtener la cookie de sesión
      final initialUrl = Uri.parse(
          'https://e-consultaruc.sunat.gob.pe/cl-ti-itmrconsruc/FrameCriterioBusquedaWeb.jsp');

      // Headers iniciales más realistas
      final initialHeaders = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3',
        'Connection': 'keep-alive',
      };

      final initialResponse =
          await http.get(initialUrl, headers: initialHeaders);
      debugPrint('Initial Response Status: ${initialResponse.statusCode}');
      debugPrint('Initial Response Headers: ${initialResponse.headers}');

      // Extraer cookies de la respuesta inicial
      final cookies = initialResponse.headers['set-cookie'] ?? '';
      debugPrint('Cookies obtenidas: $cookies');

      // Configurar los headers para la solicitud de consulta
      final consultHeaders = {
        'Cookie': cookies,
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Origin': 'https://e-consultaruc.sunat.gob.pe',
        'Referer':
            'https://e-consultaruc.sunat.gob.pe/cl-ti-itmrconsruc/FrameCriterioBusquedaWeb.jsp',
      };

      // URL del formulario de consulta
      final consultUrl = Uri.parse(
          'https://e-consultaruc.sunat.gob.pe/cl-ti-itmrconsruc/jcrS00Alias');

      // Datos del formulario actualizados según la estructura real
      final body = {
        'accion': 'consPorRuc',
        'razSoc': '',
        'nroRuc': ruc,
        'contexto': 'ti-it',
        'modo': '1',
        'tipdoc': '1',
        'search1': ruc,
        'rbtnTipo': '2',
      };

      debugPrint('Enviando solicitud con body: $body');

      // Realizar la solicitud POST
      final response = await http.post(
        consultUrl,
        headers: consultHeaders,
        body: body,
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('Response Body Length: ${response.body.length}');
      debugPrint(
          'Response Body Preview: ${response.body.substring(0, min(500, response.body.length))}');

      if (response.statusCode == 200) {
        // Parsear el HTML de la respuesta
        final document = parse(response.body);

        // Intentar múltiples selectores para encontrar la dirección
        final addressElement =
            document.querySelector('.list-group-item-text') ??
                document.querySelector('p.list-group-item-text') ??
                document.querySelector('.col-sm-7 p');

        if (addressElement != null) {
          String rawAddress = addressElement.text.trim();
          debugPrint('Dirección encontrada: $rawAddress');

          setState(() {
            _response = 'Consulta realizada con éxito';
            _fiscalAddress = rawAddress;
          });
        } else {
          debugPrint('No se encontró el elemento de dirección en el HTML');
          setState(() {
            _response = 'No se pudo encontrar la dirección fiscal';
            _fiscalAddress = '';
          });
        }
      } else {
        setState(() {
          _response =
              'Error al consultar el RUC. Status: ${response.statusCode}';
          _fiscalAddress = '';
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error completo: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _response = 'Ocurrió un error: $e';
        _fiscalAddress = '';
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
            const SizedBox(height: 10),
            const Text(
              'Dirección Fiscal:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _fiscalAddress,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
