import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'package:dart_frog/dart_frog.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;

  final method = request.method.value;

  switch (method) {
    case 'GET':
      final params = request.uri.queryParameters;

      final kVerificationToken = '1234567890';
      final hubMode = params['hub.mode'] ?? 'NA';
      final hubVerifyToken = params['hub.verify_token'] ?? 'NA';
      final hubChallenge = params['hub.challenge'] ?? 'NA';
      // return Response(body: 'Params are $params');
      if (hubVerifyToken == kVerificationToken) {
        return Response(body: hubChallenge);
      } else {
        return Response(statusCode: 400, body: 'Invalid Verification Token');
      }
    case 'POST':
      final body = jsonDecode(await request.body()) as Map<String, dynamic>;
      final valueMap = body['value'] as Map<String, dynamic>? ?? {};
      final contacts = valueMap['contacts'] as List? ?? [];

      log('Body of the request: $body');

      String nameOfSender = '';
      if (contacts.isNotEmpty) {
        final profileDetails =
            contacts.first['profile'] as Map<String, dynamic>? ?? {};
        nameOfSender = (profileDetails['name'] ?? 'NA').toString();
      }
      final messages = valueMap['messages'] as List? ?? [];
      String messageFrom = '';
      String messageBody = '';
      if (messages.isNotEmpty) {
        messageFrom = (messages.first['from'] ?? 'NA').toString();
        messageBody = (messages.first['text']['body'] ?? 'NA').toString();
      }
      // String responseText = await replyToUser(nameOfSender, messageBody);
      return Response(body: 'Sending $body to Mansi');
    default:
      return Response(body: 'Invalid Method');
  }
}

Future<String> replyToUser(String name, String messageBody) async {
  try {
    final messageSendEndpoint =
        Uri.parse('https://graph.facebook.com/v20.0/390332304171825/messages');
    final mansiEndpoint =
        Uri.parse('https://whxmgbtb-8000.inc1.devtunnels.ms/query');
    final mansiResponse = await http.post(
      mansiEndpoint,
      body: jsonEncode({
        'query': messageBody,
        'uid': 'RQ2pIEzjVsb3zbKkckms7a3iOnC3',
        'name': name,
        'goal_weight': 70,
        'current_weight': 75,
        'bmi': 24,
        'age': 22,
        'gender': 'male',
        'docid': Uuid().v4().replaceAll('-', ''),
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final response = await http.post(
      messageSendEndpoint,
      headers: {
        'Authorization':
            'Bearer EAAHoI1o82mEBOZB8cUCFU6HYy4NReByjI1f3YMuFBP4qPpa7P9rvZBDlB1Gkb5s2NocuBjQyVcgeJB99WXcdG9e4JFxpglnYAkDLP1HB6UwoUrDPt7Kr0r7AXCaMHxEs8pV5WU093CZAsnVKGF7VVwlWGBJ0ooc0CL19qbIA1vgZCasnY6CZBpH6TjeJ8XN2XqftYrrehj7Q2qZCun8NwbRQkoFblbXa3ZBAP4ZD',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'messaging_product': 'whatsapp',
        'recipient_type': 'individual',
        'to': '+916200052309',
        'type': 'text',
        'text': {
          'preview_url': false,
          'body': jsonDecode(mansiResponse.body)['answer'] ??
              'No Response from Mansi',
        },
      }),
    );
    return response.body;
  } catch (er) {
    return 'Caught Er: $er';
  }
}
