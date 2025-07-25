import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

//HttpService se usa para realizar solicitudes HTTP (GET, POST, DELETE) según lo que se necesite.
//La responsabilidad de HttpService es hacer las solicitudes y manejar los errores asociados a esas solicitudes, no gestionar la configuración directamente.

//Funciones principales de HttpService:
//Autenticación con token (Bearer):
//	Todas las solicitudes incluyen un token JWT en el encabezado HTTP con el formato Authorization: Bearer <token>,
//  lo cual es requerido por muchas APIs para autenticar al usuario.

//Solicitudes HTTP con manejo de errores:
//	getRequest(): Realiza una solicitud GET con token y maneja errores comunes como token inválido, acceso prohibido o problemas de red.
//	postRequest(): Envía datos al servidor (en formato JSON) mediante POST y valida la respuesta.
//	deleteRequest(): Elimina recursos protegidos, incluyendo el token en la cabecera.
//	putRequest(): Actualiza recursos existentes en el servidor con datos en formato JSON.

//Encabezados personalizados:
//Usa un método privado _buildHeaders() para construir los encabezados con el token y Content-Type: application/json.

//Pondremos el token en el header Authorization con el prefijo Bearer para que la API lo reconozca como un token de acceso
class HttpService {
// Función para realizar una solicitud GET con token
  Future<http.Response> getRequest(String url, String? token) async {
    if (token == null) {
      throw Exception(
          'No se encontró el token. El usuario no está autenticado.');
    }

    try {
      // Realizamos la solicitud GET con los headers necesarios
      final response = await http.get(
        Uri.parse(url),
        headers: _buildHeaders(token),
      );

      // Comprobamos si la respuesta fue exitosa
      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw Exception('Token inválido o expirado');
      } else if (response.statusCode == 403) {
        throw Exception('Acceso prohibido');
      } else {
        throw Exception(
            'Error en GET. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      // Manejo de errores más detallado
      if (e is SocketException) {
        throw Exception('Error de conexión: $e');
      } else if (e is TimeoutException) {
        throw Exception('Tiempo de espera agotado: $e');
      } else {
        throw Exception('Error desconocido: $e');
      }
    }
  }

  // Función para realizar una solicitud POST con token
  Future<http.Response> postRequest(
      Uri url, Map<String, dynamic> body, String? token) async {
    if (token == null) {
      throw Exception(
          'No se encontró el token. El usuario no está autenticado.');
    }

    try {
      // Se añaden los headers con el token de autorización
      final response = await http.post(
        url,
        headers: _buildHeaders(token),
        body: json.encode(body), // Convertimos el cuerpo en JSON
      );
      // Comprobamos si la respuesta fue exitosa
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Error en POST. Código de estado: ${response.statusCode}');
      }

      return response;
    } catch (e) {
      throw Exception('Error de conexión o de servidor: $e');
    }
  }

  // Función para realizar una solicitud DELETE con token
  Future<http.Response> deleteRequest(String url, String? token) async {
    if (token == null) {
      throw Exception(
          'No se encontró el token. El usuario no está autenticado.');
    }

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: _buildHeaders(token),
      );

      // Simplemente devuelve la respuesta, sin lanzar error
      return response;
    } catch (e) {
      throw Exception('Error de conexión o de servidor: $e');
    }
  }

  Future<http.Response> putRequest(
      String url, Map<String, dynamic> body, String token) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: _buildHeaders(token),
        body: json.encode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            'Error en PUT. Código de estado: ${response.statusCode}');
      }

      return response;
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Error de conexión: $e');
      } else if (e is TimeoutException) {
        throw Exception('Tiempo de espera agotado: $e');
      } else {
        throw Exception('Error desconocido: $e');
      }
    }
  }

  // Método privado para construir los headers con el token
  Map<String, String> _buildHeaders(String token) {
    return {
      "Authorization": "Bearer $token", // Incluimos el token en el header
      "Content-Type":
          "application/json", // Establecemos el tipo de contenido como JSON
    };
  }
}

//EXPLICACION
//_buildHeaders: Este método privado construye los headers de la solicitud.
//Acepta un token y lo agrega al header Authorization como Bearer <token>.
//Además, se incluye el header Content-Type: application/json para asegurarse de que los datos sean interpretados como JSON.
//Métodos getRequest y postRequest:
//En ambos métodos, primero se obtiene el token desde el AuthProvider usando Provider.of<AuthProvider>(context, listen: false).token.
//Si el token no está presente (es decir, el usuario no está autenticado), se lanza una excepción.
//Luego, se llama a la función _buildHeaders para obtener los headers configurados con el token y otros detalles necesarios.
//Finalmente, se realiza la solicitud HTTP (GET o POST) con los headers apropiados.
