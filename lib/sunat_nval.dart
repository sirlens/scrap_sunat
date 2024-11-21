import 'dart:developer';

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
      final initialResponse = await http.get(initialUrl);

      // Extraer cookies de la respuesta inicial
      final cookies = initialResponse.headers['set-cookie'] ?? '';

      // Configurar los headers para la solicitud de consulta
      final headers = {
        'Cookie': cookies,
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      // URL del formulario de consulta
      final consultUrl = Uri.parse(
          'https://e-consultaruc.sunat.gob.pe/cl-ti-itmrconsruc/FrameCriterioBusquedaWeb.jsp');

      // Datos del formulario
      final body = {
        'accion': 'consPorRuc',
        'razSoc': '',
        'nroRuc': ruc,
        'nroRuc2': ruc,
        'tQuery': 'internet',
        'tipdoc': '1',
        'search1': 'BUSCAR',
        'codigo': '',
        'tipcam': '1',
      };

      // Realizar la solicitud POST
      final response = await http.post(
        consultUrl,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // Parsear el HTML de la respuesta
        final document = parse(response.body);

        log('=========================== $document');
        final addressElement = document.querySelector('list-group-item-text');

        if (addressElement != null) {
          // Extraer y limpiar la dirección
          String rawAddress = addressElement.text.trim();

          setState(() {
            _response = 'Consulta realizada con éxito';
            _fiscalAddress = rawAddress;
          });
        } else {
          setState(() {
            _response = 'No se pudo encontrar la dirección fiscal';
            _fiscalAddress = '';
          });
        }
      } else {
        setState(() {
          _response = 'Error al consultar el RUC.';
          _fiscalAddress = '';
        });
      }
    } catch (e) {
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
