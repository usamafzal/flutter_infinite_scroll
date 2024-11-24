import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_infinite_scroll/mode.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  // Fetches news data from the API for a given page number
  static Future<NewsModel> fetchNews(int page, http.Client client) async {
    // Constructs the API URL with the page parameter
    Uri url = Uri.parse("ENTER_HERE_OWN_URL?page=$page"); // Enter Own URL

    // Sends an HTTP GET request to the API
    final response = await client.get(url);

    if (response.statusCode == 200) {
      // Parses the response body using a separate isolate for better performance
      return compute(parseNews, response.body);
    } else {
      // Throws an exception if the response status code is not 200
      throw Exception("Unexpected Error Occured");
    }
  }
}

// Parses the JSON response into a NewsModel object
Future<NewsModel> parseNews(String responseBody) async {
  // Decodes the JSON response and creates a NewsModel instance
  return NewsModel.fromJson(jsonDecode(responseBody));
}
