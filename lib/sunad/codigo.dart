class Codigo {
  String extraerContenidoEntreTagString(
      String cadena, int posicion, String nombreInicio, String nombreFin) {
    String respuesta = "";
    int posicionInicio = cadena.indexOf(nombreInicio, posicion);

    if (posicionInicio > -1) {
      posicionInicio += nombreInicio.length;
      if (nombreFin == "") {
        respuesta =
            cadena.substring(posicionInicio, cadena.length - posicionInicio);
      } else {
        int posicionFin = cadena.indexOf(nombreFin, posicionInicio);
        if (posicionFin > -1) {
          respuesta =
              cadena.substring(posicionInicio, posicionFin - posicionInicio);
        }
      }
    }

    return respuesta;
  }

  List<String> extraerContenidoEntreTag(
      String cadena, int posicion, String nombreInicio, String nombreFin) {
    List<String> arrRespuesta = [];
    int posicionInicio = cadena.indexOf(nombreInicio, posicion);
    if (posicionInicio > -1) {
      posicionInicio += nombreInicio.length;
      if (nombreFin == "") {
        List<String> arrRespuesta = [];
        arrRespuesta[0] = cadena.length.toString();
        arrRespuesta[1] =
            cadena.substring(posicionInicio, cadena.length - posicionInicio);
      } else {
        int posicionFin = cadena.indexOf(nombreFin, posicionInicio);
        if (posicionFin > -1) {
          posicion = posicionFin + nombreFin.length;
          List<String> arrRespuesta = [];
          arrRespuesta[0] = posicion.toString();
          arrRespuesta[1] =
              cadena.substring(posicionInicio, posicionFin - posicionInicio);
        }
      }
    }

    return arrRespuesta;
  }
}
