import 'dart:async';
import 'dart:convert';

import 'package:flutter_scrapper/sunad/codigo.dart';
import 'package:flutter_scrapper/sunad/inforuc.dart';
import 'package:flutter_scrapper/sunad/sunat.dart';
import 'package:http/http.dart' as http;

class SunatService {
  // Función para obtener información del RUC

  SUNAT obtenerDatos(String contenidoHTML) {
    Codigo oCuTexto = Codigo();
    SUNAT oEnSUNAT = SUNAT();
    String nombreInicio = "<HEAD><TITLE>";
    String nombreFin = "</TITLE></HEAD>";
    String contenidoBusqueda = oCuTexto.extraerContenidoEntreTagString(
        contenidoHTML, 0, nombreInicio, nombreFin);
    if (contenidoBusqueda == ".:: Pagina de Mensajes ::.") {
      nombreInicio = "<p class=\"error\">";
      nombreFin = "</p>";
      oEnSUNAT.tipoRespuesta = 2;
      oEnSUNAT.mensajeRespuesta = oCuTexto.extraerContenidoEntreTagString(
          contenidoHTML, 0, nombreInicio, nombreFin);
    } else if (contenidoBusqueda == ".:: Pagina de Error ::.") {
      nombreInicio = "<p class=\"error\">";
      nombreFin = "</p>";
      oEnSUNAT.tipoRespuesta = 3;
      oEnSUNAT.mensajeRespuesta = oCuTexto.extraerContenidoEntreTagString(
          contenidoHTML, 0, nombreInicio, nombreFin);
    } else {
      oEnSUNAT.tipoRespuesta = 2;
      nombreInicio = "<div class=\"list-group\">";
      nombreFin = "<div class=\"panel-footer text-center\">";
      contenidoBusqueda = oCuTexto.extraerContenidoEntreTagString(
          contenidoHTML, 0, nombreInicio, nombreFin);
      if (contenidoBusqueda == "") {
        nombreInicio = "<strong>";
        nombreFin = "</strong>";
        oEnSUNAT.mensajeRespuesta = oCuTexto.extraerContenidoEntreTagString(
            contenidoHTML, 0, nombreInicio, nombreFin);
        if (oEnSUNAT.mensajeRespuesta == "") {
          oEnSUNAT.mensajeRespuesta =
              "No se encuentra las cabeceras principales del contenido HTML";
        }
      } else {
        contenidoHTML = contenidoBusqueda;
        oEnSUNAT.mensajeRespuesta = "Mensaje del inconveniente no especificado";
        nombreInicio = "<h4 class=\"list-group-item-heading\">";
        nombreFin = "</h4>";
        int resultadoBusqueda = contenidoHTML.indexOf(
          nombreInicio,
          0,
        );
        if (resultadoBusqueda > -1) {
          // Modificar cuando el estado del Contribuyente es "BAJA DE OFICIO", porque se agrega un elemento con clase "list-group-item"
          resultadoBusqueda += nombreInicio.length;
          List<String> arrResultado = oCuTexto.extraerContenidoEntreTag(
              contenidoHTML, resultadoBusqueda, nombreInicio, nombreFin);
          if (arrResultado != null) {
            oEnSUNAT.razonSocial = arrResultado[1];

            // Tipo Contribuyente
            nombreInicio = "<p class=\"list-group-item-text\">";
            nombreFin = "</p>";
            arrResultado = oCuTexto.extraerContenidoEntreTag(contenidoHTML,
                int.parse(arrResultado[0]), nombreInicio, nombreFin);
            if (arrResultado != null) {
              oEnSUNAT.tipoContribuyente = arrResultado[1];

              // Nombre Comercial
              arrResultado = oCuTexto.extraerContenidoEntreTag(contenidoHTML,
                  int.parse(arrResultado[0]), nombreInicio, nombreFin);
              if (arrResultado != null) {
                if (oEnSUNAT.razonSocial!.substring(0, 2) == "10") {
                  oEnSUNAT.tipoDocumento = arrResultado[1];

                  // Tipo Documento
                  arrResultado = oCuTexto.extraerContenidoEntreTag(
                      contenidoHTML,
                      int.parse(arrResultado[0]),
                      nombreInicio,
                      nombreFin);
                }
                if (arrResultado != null) {
                  oEnSUNAT.nombreComercial = arrResultado[1]
                      .replaceAll("\r\n", "")
                      .replaceAll("\t", "")
                      .trim();

                  // Fecha de Inscripción
                  arrResultado = oCuTexto.extraerContenidoEntreTag(
                      contenidoHTML,
                      int.parse(arrResultado[0]),
                      nombreInicio,
                      nombreFin);
                  if (arrResultado != null) {
                    oEnSUNAT.fechaInscripcion = arrResultado[1];

                    // Fecha de Inicio de Actividades:
                    arrResultado = oCuTexto.extraerContenidoEntreTag(
                        contenidoHTML,
                        int.parse(arrResultado[0]),
                        nombreInicio,
                        nombreFin);
                    if (arrResultado != null) {
                      oEnSUNAT.fechaInicioActividades = arrResultado[1];

                      // Estado del Contribuyente
                      arrResultado = oCuTexto.extraerContenidoEntreTag(
                          contenidoHTML,
                          int.parse(arrResultado[0]),
                          nombreInicio,
                          nombreFin);
                      if (arrResultado != null) {
                        oEnSUNAT.estadoContribuyente = arrResultado[1].trim();

                        // Condición del Contribuyente
                        arrResultado = oCuTexto.extraerContenidoEntreTag(
                            contenidoHTML,
                            int.parse(arrResultado[0]),
                            nombreInicio,
                            nombreFin);
                        if (arrResultado != null) {
                          oEnSUNAT.condicionContribuyente =
                              arrResultado[1].trim();

                          // Domicilio Fiscal
                          arrResultado = oCuTexto.extraerContenidoEntreTag(
                              contenidoHTML,
                              int.parse(arrResultado[0]),
                              nombreInicio,
                              nombreFin);
                          if (arrResultado != null) {
                            oEnSUNAT.domicilioFiscal = arrResultado[1].trim();

                            // Actividad(es) Económica(s)
                            nombreInicio = "<tbody>";
                            nombreFin = "</tbody>";
                            arrResultado = oCuTexto.extraerContenidoEntreTag(
                                contenidoHTML,
                                int.parse(arrResultado[0]),
                                nombreInicio,
                                nombreFin);
                            if (arrResultado != null) {
                              oEnSUNAT.actividadesEconomicas = arrResultado[1]
                                  .replaceAll("\r\n", "")
                                  .replaceAll("\t", "")
                                  .trim();

                              // Comprobantes de Pago c/aut. de impresión (F. 806 u 816)
                              arrResultado = oCuTexto.extraerContenidoEntreTag(
                                  contenidoHTML,
                                  int.parse(arrResultado[0]),
                                  nombreInicio,
                                  nombreFin);
                              if (arrResultado != null) {
                                oEnSUNAT.comprobantesPago = arrResultado[1]
                                    .replaceAll("\r\n", "")
                                    .replaceAll("\t", "")
                                    .trim();

                                // Sistema de Emisión Electrónica
                                arrResultado =
                                    oCuTexto.extraerContenidoEntreTag(
                                        contenidoHTML,
                                        int.parse(arrResultado[0]),
                                        nombreInicio,
                                        nombreFin);
                                if (arrResultado != null) {
                                  oEnSUNAT.sistemaEmisionComprobante =
                                      arrResultado[1]
                                          .replaceAll("\r\n", "")
                                          .replaceAll("\t", "")
                                          .trim();

                                  // Afiliado al PLE desde
                                  nombreInicio =
                                      "<p class=\"list-group-item-text\">";
                                  nombreFin = "</p>";
                                  arrResultado =
                                      oCuTexto.extraerContenidoEntreTag(
                                          contenidoHTML,
                                          int.parse(arrResultado[0]),
                                          nombreInicio,
                                          nombreFin);
                                  if (arrResultado != null) {
                                    oEnSUNAT.afiliadoPLEDesde = arrResultado[1];

                                    // padrones
                                    nombreInicio = "<tbody>";
                                    nombreFin = "</tbody>";
                                    arrResultado =
                                        oCuTexto.extraerContenidoEntreTag(
                                            contenidoHTML,
                                            int.parse(arrResultado[0]),
                                            nombreInicio,
                                            nombreFin);
                                    if (arrResultado != null) {
                                      oEnSUNAT.padrones = arrResultado[1]
                                          .replaceAll("\r\n", "")
                                          .replaceAll("\t", "")
                                          .trim();
                                    }
                                  }

                                  oEnSUNAT.tipoRespuesta = 1;
                                  oEnSUNAT.mensajeRespuesta = "Ok";
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return oEnSUNAT;
  }

  Future<InfoRuc?> obtenerInfoPorRucAsync(String ruc) async {
    const url =
        'https://e-consultaruc.sunat.gob.pe/cl-ti-itmrconsruc/jcrS00Alias';

    final headers = {
      'Host': 'e-consultaruc.sunat.gob.pe',
      'sec-ch-ua':
          ' " Not A;Brand";v="99", "Chromium";v="90", "Google Chrome";v="90"',
      'sec-ch-ua-mobile': '?0',
      'Sec-Fetch-Dest': 'document',
      'Sec-Fetch-Mode': 'navigate',
      'Sec-Fetch-Site': 'none',
      'Sec-Fetch-User': '?1',
      'Upgrade-Insecure-Requests': '1',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.150 Safari/537.36'
    };
    final cliente = http.Client();
    //final cliente = IOClient();
    final respuesta = await cliente.get(Uri.parse(url), headers: headers);

    if (respuesta.statusCode == 200) {
      await Future.delayed(const Duration(milliseconds: 100));
      headers.remove('Sec-Fetch-Site');
      headers['Origin'] = 'https://e-consultaruc.sunat.gob.pe';
      headers['Referer'] = url;
      headers['Sec-Fetch-Site'] = 'same-origin';

      String numeroDNI = '12345678';
      final datos = {
        'accion': 'consPorTipdoc',
        'razSoc': '',
        'nroRuc': '',
        'nrodoc': numeroDNI,
        'contexto': 'ti-it',
        'modo': '1',
        'search1': '',
        'rbtnTipo': '2',
        'tipdoc': '1',
        'search2': numeroDNI,
        'search3': '',
        'codigo': ''
      };

      final respuestaRandom =
          await cliente.post(Uri.parse(url), headers: headers, body: datos);

      if (respuestaRandom.statusCode == 200) {
        await Future.delayed(const Duration(milliseconds: 100));
        final contenidoHTML = respuestaRandom.body;
        final numeroRandom = Codigo().extraerContenidoEntreTagString(
            contenidoHTML, 0, 'name="numRnd" value="', '">');

        final datosRuc = {
          'accion': 'consPorRuc',
          'actReturn': '1',
          'nroRuc': ruc,
          'numRnd': numeroRandom,
          'modo': '1'
        };

        int cConsulta = 0;
        int nConsulta = 3;
        while (cConsulta < nConsulta) {
          final respuestaDatos = await cliente.post(Uri.parse(url),
              headers: headers, body: datosRuc);

          if (respuestaDatos.statusCode == 200) {
            final contenidoHTML = respuestaDatos.body;
            final contenidoHTMLDecodificado =
                utf8.decode(contenidoHTML.codeUnits);

            final sunat = obtenerDatos(contenidoHTMLDecodificado);
            if (sunat.tipoRespuesta == 1) {
              final infoRuc = InfoRuc(
                ruC: sunat.numeroRUC!,
                razonSocial: sunat.razonSocial!,
                tipoContribuyente: sunat.tipoContribuyente!,
                tipoDocumento: sunat.tipoDocumento,
                estadoContribuyente: sunat.estadoContribuyente!,
                condicionContribuyente: sunat.condicionContribuyente!,
                domicilioFiscal: sunat.domicilioFiscal!,
                fechaInscripcion: sunat.fechaInscripcion!,
                fechaInicioActividades: sunat.fechaInicioActividades!,
              );
              return infoRuc;
            } else {
              throw Exception(
                  'No se pudo realizar la consulta del número de RUC $ruc.\nDetalle: ${sunat.mensajeRespuesta}');
            }
          } else {
            throw Exception(
                'Ocurrió un inconveniente al consultar los datos del RUC $ruc.\nDetalle: ${respuestaDatos.statusCode}');
          }
        }
      } else {
        throw Exception(
            'Ocurrió un inconveniente al consultar los datos del RUC $ruc.\nDetalle: ${respuestaRandom.statusCode}');
      }
    } else {
      throw Exception(
          'Ocurrió un inconveniente al consultar los datos del RUC $ruc.\nDetalle: ${respuesta.statusCode}');
    }
    return null;
  }

/*   Future<SUNAT> obtenerInfoSunatByRuc(String ruc) async {
    final client = http.Client();

    try {
      final url = Uri.parse(
          'https://e-consultaruc.sunat.gob.pe/cl-ti-itmrconsruc/jcrS00Alias');

      // Realizamos el primer GET para obtener el estado inicial
      final response = await client.get(url);
      if (response.statusCode == 200) {
        // Realizamos el segundo POST con los parámetros requeridos
        final postUrl = Uri.parse(
            'https://e-consultaruc.sunat.gob.pe/cl-ti-itmrconsruc/jcrS00Alias');
        final body = {
          'accion': 'consPorRuc',
          'nroRuc': ruc,
          // Aquí deberás agregar más parámetros según sea necesario
        };
        final postResponse = await client.post(postUrl, body: body);

        if (postResponse.statusCode == 200) {
          // Parsear el contenido HTML
          var document = parse(postResponse.body);

          // Aquí es donde deberías extraer los datos relevantes
          var tipoRespuesta = document.querySelector('...')?.text ?? '';
          var mensajeRespuesta = document.querySelector('...')?.text ?? '';
          var razonSocial = document.querySelector('...')?.text ?? '';
          // Continúa extrayendo el resto de los datos

          // Retornar los datos en un objeto SUNAT
          return SUNAT(
            tipoRespuesta: int.parse(tipoRespuesta),
            mensajeRespuesta: mensajeRespuesta,
            numeroRUC: ruc,
            razonSocial: razonSocial,
            tipoContribuyente: '...',
            tipoDocumento: '...',
            nombreComercial: '...',
            fechaInscripcion: '...',
            fechaInicioActividades: '...',
            estadoContribuyente: '...',
            condicionContribuyente: '...',
            domicilioFiscal: '...',
            sistemaEmisionComprobante: '...',
            actividadComercioExterior: '...',
            sistemaContabilidad: '...',
            actividadesEconomicas: '...',
            comprobantesPago: '...',
            sistemaEmisionElectronica: '...',
            emisorElectronicoDesde: '...',
            comprobantesElectronicos: '...',
            afiliadoPLEDesde: '...',
            padrones: '...',
          );
        } else {
          throw Exception('Error al consultar el RUC');
        }
      } else {
        throw Exception('Error en la solicitud GET');
      }
    } finally {
      client.close();
    }
  } */
}
