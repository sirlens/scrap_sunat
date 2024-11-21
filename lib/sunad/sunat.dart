class SUNAT {
  int? tipoRespuesta;
  String? mensajeRespuesta;
  String? numeroRUC;
  String? razonSocial;
  String? tipoContribuyente;
  String? tipoDocumento;
  String? nombreComercial;
  String? fechaInscripcion;
  String? fechaInicioActividades;
  String? estadoContribuyente;
  String? condicionContribuyente;
  String? domicilioFiscal;
  String? sistemaEmisionComprobante;
  String? actividadComercioExterior;
  String? sistemaContabilidad;
  String? actividadesEconomicas;
  String? comprobantesPago;
  String? sistemaEmisionElectronica;
  String? emisorElectronicoDesde;
  String? comprobantesElectronicos;
  String? afiliadoPLEDesde;
  String? padrones;

  SUNAT({
    this.tipoRespuesta,
    this.mensajeRespuesta,
    this.numeroRUC,
    this.razonSocial,
    this.tipoContribuyente,
    this.tipoDocumento,
    this.nombreComercial,
    this.fechaInscripcion,
    this.fechaInicioActividades,
    this.estadoContribuyente,
    this.condicionContribuyente,
    this.domicilioFiscal,
    this.sistemaEmisionComprobante,
    this.actividadComercioExterior,
    this.sistemaContabilidad,
    this.actividadesEconomicas,
    this.comprobantesPago,
    this.sistemaEmisionElectronica,
    this.emisorElectronicoDesde,
    this.comprobantesElectronicos,
    this.afiliadoPLEDesde,
    this.padrones,
  });

  factory SUNAT.fromJson(Map<String, dynamic> json) {
    return SUNAT(
      tipoRespuesta: json['tipoRespuesta'],
      mensajeRespuesta: json['mensajeRespuesta'],
      numeroRUC: json['numeroRUC'],
      razonSocial: json['razonSocial'],
      tipoContribuyente: json['tipoContribuyente'],
      tipoDocumento: json['tipoDocumento'],
      nombreComercial: json['nombreComercial'],
      fechaInscripcion: json['fechaInscripcion'],
      fechaInicioActividades: json['fechaInicioActividades'],
      estadoContribuyente: json['estadoContribuyente'],
      condicionContribuyente: json['condicionContribuyente'],
      domicilioFiscal: json['domicilioFiscal'],
      sistemaEmisionComprobante: json['sistemaEmisionComprobante'],
      actividadComercioExterior: json['actividadComercioExterior'],
      sistemaContabilidad: json['sistemaContabilidad'],
      actividadesEconomicas: json['actividadesEconomicas'],
      comprobantesPago: json['comprobantesPago'],
      sistemaEmisionElectronica: json['sistemaEmisionElectronica'],
      emisorElectronicoDesde: json['emisorElectronicoDesde'],
      comprobantesElectronicos: json['comprobantesElectronicos'],
      afiliadoPLEDesde: json['afiliadoPLEDesde'],
      padrones: json['padrones'],
    );
  }
}
