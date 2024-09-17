import 'dart:async';
import 'dart:convert';
import 'package:dart_frog_request_logger/dart_frog_request_logger.dart';
import 'package:http/http.dart' as http;
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return (context) async {
    RequestLogger logger = context.read<RequestLogger>();
    try {
      logger.alert('Starting to process in Middleware..');
      final body =
          jsonDecode(await context.request.body()) as Map<String, dynamic>;
      logger.info('Body of the request is :$body');
      final entries = body['entry'] as List? ?? [];

      if (entries.isEmpty) {
        logger
            .info('No Entries..\n\nThe Body of incoming message was $body\n\n');
        final response = await handler(context);
        return response;
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
          final statuses = valueMap['statuses'] as List? ?? [];

          if (statuses.isNotEmpty) {
            final status = statuses.first['status'] ?? 'NA';
            logger.info(
                '\n\nStatus of the message is $status\nSkipping sending message...\n\n');
          } else {
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
            logger.info('\n\nForwarding for Processing\n\n');

            unawaited(http.post(
                Uri.parse(
                    'https://mansi-server.globeapp.dev/processAndSendMessage'
                    // 'http://localhost:8080/processAndSendMessage',
                    ),
                body: jsonEncode({'body': messageBody, 'from': messageFrom})));
          }

          final response = await handler(context);
          return response;
        }
      }
    } catch (er) {
      logger.error('Something went wrong $er');
      return Response(body: er.toString(), statusCode: 400);
    }
  };
}
