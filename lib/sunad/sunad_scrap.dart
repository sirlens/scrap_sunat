import 'package:flutter/material.dart';
import 'package:flutter_scrapper/sunad/inforuc.dart';
import 'package:flutter_scrapper/sunad/service.dart';

class RucWidget extends StatefulWidget {
  const RucWidget({super.key});

  @override
  State<RucWidget> createState() => _RucWidgetState();
}

class _RucWidgetState extends State<RucWidget> {
  final _rucController = TextEditingController();
  InfoRuc? _infoRuc;
  SunatService sunatService = SunatService();
  Future<void> _obtenerInfo() async {
    try {
      final ruc = _rucController.text;
      final info = await sunatService.obtenerInfoPorRucAsync(ruc);
      setState(() {
        _infoRuc = info;
      });
    } catch (e) {
      // Manejar errores, por ejemplo, mostrar un mensaje al usuario
      debugPrint('---Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de RUC'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _rucController,
              decoration: const InputDecoration(labelText: 'Ingrese el RUC'),
            ),
            ElevatedButton(
              onPressed: _obtenerInfo,
              child: const Text('Consultar'),
            ),
            if (_infoRuc != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RUC: 1  ${_infoRuc!.ruC}'),
                      Text('Razón Social: ${_infoRuc!.razonSocial}'),
                      Text('Razón Social: ${_infoRuc!.domicilioFiscal}'),
                      Text('Razón Social: ${_infoRuc!.tipoContribuyente}'),
                      Text('Razón Social: ${_infoRuc!.tipoDocumento}'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
