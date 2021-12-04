import 'package:cuestionario_final/models/form.dart';
import 'package:cuestionario_final/models/responses.dart';
import 'package:cuestionario_final/models/token.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'constans.dart';

class ApiHelper {
  static Future<Responses> getForm(Token token) async {
    if (!_validToken(token)) {
      return Responses(
          isSuccess: false, message: 'Sus credenciales han vencido');
    }
    var url = Uri.parse('${Constans.apiUrl}/api/Finals');
    var response = await http.get(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${token.token}',
      },
    );

    var body = response.body;

    if (response.statusCode >= 400) {
      return Responses(isSuccess: false, message: body);
    }

    var decodejson = jsonDecode(body);

    Forms form = Forms.fromJson(decodejson);
    return Responses(isSuccess: true, result: form);
  }

  static Future<Responses> post(
      String controller, Map<String, dynamic> request, Token token) async {
    if (!_validToken(token)) {
      return Responses(
          isSuccess: false, message: 'Sus credenciales han vencido');
    }
    var url = Uri.parse('${Constans.apiUrl}$controller');
    var response = await http.post(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${token.token}',
      },
      body: jsonEncode(request),
    );
    if (response.statusCode >= 400) {
      return Responses(isSuccess: false, message: response.body);
    }
    return Responses(isSuccess: true);
  }

  static bool _validToken(Token token) {
    if (DateTime.parse(token.expiration).isAfter(DateTime.now())) {
      return true;
    }
    return false;
  }
}
