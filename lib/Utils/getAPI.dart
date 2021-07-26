import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myuseum/Utils/userInfo.dart';

class Register {
  static Future<String> postRegisterGetStatusCode(String url,
      String content) async
  {
    String ret = "";

    try {
      http.Response response = await http.post(
          Uri.parse(url), body: utf8.encode(content),
          headers:
          {
            "Accept": "Application/json",
            "Authorization": "bearer ${getAccessToken()}",
            "Content-Type": "application/json",
          },
          encoding: Encoding.getByName("utf-8")
      );
      ret = response.statusCode.toString();
    }

    catch (e) {
      print(e.toString());
    }

    return ret;
  }

  static Future<String> postRegisterGetBody(String url, String content) async
  {
    String ret = "";

    try {
      http.Response response = await http.post(
          Uri.parse(url), body: utf8.encode(content),
          headers:
          {
            "Accept": "Application/json",
            "Authorization": "bearer ${getAccessToken()}",
            "Content-Type": "application/json",
          },
          encoding: Encoding.getByName("utf-8")
      );
      ret = response.body;
    }

    catch (e) {
      print(e.toString());
    }

    return ret;
  }
  static Future<String> getRegisterGetStatusCode(String url, Map<String, String> content) async
  {
    String ret = "";
    Uri uri = Uri.parse(url);
    uri = uri.replace(queryParameters: content);
    print(uri);
    try {
      http.Response response = await http.get(
        uri,
        headers:
        {
          "Accept": "Application/json",
          "Authorization": "bearer ${getAccessToken()}",
          "Content-Type": "application/json",
        },
      );
      ret = response.statusCode.toString();
    }

    catch (e) {
      print(e.toString());
    }

    return ret;
  }

  static Future<String> getRegisterGetBody(String url, Map<String, String> content) async
  {
    String ret = "";
    Uri uri = Uri.parse(url);
    uri = uri.replace(queryParameters: content);
    try {
      http.Response response = await http.get(
          uri,
          headers:
          {
            "Accept": "Application/json",
            "Authorization": "bearer ${getAccessToken()}",
            "Content-Type": "application/json",
          },
      );
      ret = response.body;
    }

    catch (e) {
      print(e.toString());
    }

    return ret;
  }

  static Future<String> deleteRegisterGetStatusCode(String url, Map<String, String> content) async
  {
    String ret = "";
    Uri uri = Uri.parse(url);
    uri = uri.replace(queryParameters: content);
    print(uri);
    try {
      http.Response response = await http.delete(
          uri,
          headers:
          {
            "Accept": "Application/json",
            "Authorization": "bearer ${getAccessToken()}",
            "Content-Type": "application/json",
          },
          encoding: Encoding.getByName("utf-8")
      );
      ret = response.statusCode.toString();
    }

    catch (e) {
      print(e.toString());
    }

    return ret;
  }

  static Future<String> putRegisterGetStatus(String url, Map<String, String> content, String body) async{
    String ret = "";
    Uri uri = Uri.parse(url);
    uri = uri.replace(queryParameters: content);

    try {
      http.Response response = await http.put(
          uri, body: utf8.encode(body),
          headers:
          {
            "Accept": "Application/json",
            "Authorization": "bearer ${getAccessToken()}",
            "Content-Type": "application/json",
          },
          encoding: Encoding.getByName("utf-8")
      );
      ret = response.statusCode.toString();
    }

    catch (e) {
      print(e.toString());
    }

    return ret;
  }

}