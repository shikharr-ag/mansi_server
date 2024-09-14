import 'dart:convert';
import 'dart:developer';

import 'package:dart_frog_request_logger/dart_frog_request_logger.dart';
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
      final entries = body['entry'] as List? ?? [];
      final logger = context.read<RequestLogger>();
      if (entries.isEmpty) {
        logger
            .info('No Entries..\n\nThe Body of incoming message was $body\n\n');
        return Response(statusCode: 400, body: 'No Entries');
      } else {
        final changesList = entries.first['changes'] as List? ?? [];
        if (changesList.isEmpty) {
          logger.info(
              'No Changes.\n\nThe body of incoming message was $body\n\n');
          return Response(body: 'No Changes', statusCode: 400);
        } else {
          final msgBody = changesList.first as Map<String, dynamic>;
          final valueMap = msgBody['value'] as Map<String, dynamic>? ?? {};
          final contacts = valueMap['contacts'] as List? ?? [];
          logger.info('\n\nMessage Body is: $msgBody\n\n');
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
          logger.info(
              '\nBody of the message is $messageBody\n\nSender of the message is $messageFrom\n\n');

          String responseText = await replyToUser(
            nameOfSender,
            messageBody,
            logger: logger,
          );
          return Response(body: 'Mansi responded');
        }
      }

    default:
      return Response(body: 'Invalid Method');
  }
}

Future<String> replyToUser(String name, String messageBody,
    {required RequestLogger logger}) async {
  try {
    logger.debug('\n\nMessage sent to Mansi for processing\n\n');
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
    ).catchError((er) {
      logger.error('\n\nCaught Error in Mansi Response => $er');
      return Future(() => http.Response("{'answer': 'error'}", 200));
    });
    logger.debug('\n\nMansi Response is: ${mansiResponse.body}\n\n');
    final bearer =
        'EAAHoI1o82mEBO4XLgCIHOtFUNthQJU6ZBGmWKBeXacU0kGemeFTXevbaiJZCfCPCqlXTzsnbXnem20hysfStJfHPRYFeTBH4dJIa5RH9k2qK3XGjuC2E4SgHZCJGOIOLkFmBBzyot1SrKClFqJu28XcteO0GB1oC9kAxbcDukLCabkp2gWzvZBPUEZCfTucm11dYfpk6flNX7me98GMEAVpbX2QrZAlht47s8ZD';
    logger.debug('\n\nSending message to user..\n\n');
    final response = await http.post(
      messageSendEndpoint,
      headers: {
        'Authorization': 'Bearer $bearer',
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
    logger.error('\n\nError while getting response from Mansi: $er\n\n');
    return 'Caught Er: $er';
  }
}
