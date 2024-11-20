import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;

class ScrapingPage extends StatefulWidget {
  const ScrapingPage({super.key});

  @override
  State<ScrapingPage> createState() => _ScrapingPageState();
}

class _ScrapingPageState extends State<ScrapingPage> {
  List<String> _titles = [];

  @override
  void initState() {
    super.initState();
    //_scrapeData();
  }

  // Función para realizar el scraping
  Future<void> _scrapeData() async {
    log('Iniciar Scrapp');
    // URL de la página a scrapear
    const url =
        'https://e-consultaruc.sunat.gob.pe/cl-ti-itmrconsruc/FrameCriterioBusquedaWeb.jsp'; // Cambia esta URL por la página que desees scrapear
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Si la respuesta es exitosa, parseamos el HTML
      final document = htmlParser.parse(response.body);
      log(document.toString());

      // Buscamos los títulos, por ejemplo, de un elemento <h2> con clase 'title'
      final titles = document.querySelectorAll('h3');
      log('titles: $titles');
      // Extraemos el texto de cada título
      final List<String> titlesList =
          titles.map((element) => element.text.trim()).toList();
      log('lisTitles: $titlesList');
      setState(() {
        _titles = titlesList;
        log('termina Scrapp');
      });
    } else {
      throw Exception('Error al cargar la página');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scraping de Página'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _titles.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _titles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_titles[index]),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scrapeData(),
        child: const Icon(Icons.sanitizer_rounded),
      ),
    );
  }
}
