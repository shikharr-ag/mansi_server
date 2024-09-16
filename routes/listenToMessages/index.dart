import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dart_frog_request_logger/dart_frog_request_logger.dart';
import 'package:http/http.dart' as http;

import 'package:dart_frog/dart_frog.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;

  final method = request.method.value;
  final logger = context.read<RequestLogger>();
  switch (method) {
    case 'GET':
      final params = request.uri.queryParameters;

      final kVerificationToken = '1234567890';
      final hubMode = params['hub.mode'] ?? 'NA';
      final hubVerifyToken = params['hub.verify_token'] ?? 'NA';
      final hubChallenge = params['hub.challenge'] ?? 'NA';
      // return Response(body: 'Params are $params');
      if (hubVerifyToken == kVerificationToken) {
        logger.info('Verified Token..');
        return Response(body: hubChallenge);
      } else {
        return Response(statusCode: 400, body: 'Invalid Verification Token');
      }
    case 'POST':
      final body = jsonDecode(await request.body()) as Map<String, dynamic>;
      final entries = body['entry'] as List? ?? [];

      if (entries.isEmpty) {
        logger
            .info('No Entries..\n\nThe Body of incoming message was $body\n\n');
        return Response(statusCode: 400, body: 'No Entries');
      } else {
        // final changesList = entries.first['changes'] as List? ?? [];
        // if (changesList.isEmpty) {
        //   logger.info(
        //       'No Changes.\n\nThe body of incoming message was $body\n\n');
        //   return Response(body: 'No Changes', statusCode: 400);
        // } else {
        //   final msgBody = changesList.first as Map<String, dynamic>;
        //   final valueMap = msgBody['value'] as Map<String, dynamic>? ?? {};
        //   final contacts = valueMap['contacts'] as List? ?? [];
        //   logger.info('\n\nMessage Body is: $msgBody\n\n');
        //   String nameOfSender = '';
        //   if (contacts.isNotEmpty) {
        //     final profileDetails =
        //         contacts.first['profile'] as Map<String, dynamic>? ?? {};
        //     nameOfSender = (profileDetails['name'] ?? 'NA').toString();
        //   }
        //   final messages = valueMap['messages'] as List? ?? [];
        //   String messageFrom = '';
        //   String messageBody = '';
        //   if (messages.isNotEmpty) {
        //     messageFrom = (messages.first['from'] ?? 'NA').toString();
        //     messageBody = (messages.first['text']['body'] ?? 'NA').toString();
        //   }
        //   logger.info(
        //       '\nBody of the message is $messageBody\n\nSender of the message is $messageFrom\n\n');

        //   logger.info('\n\nSending response 200 to Meta..\n\n');
        return Response(
          body: 'Msg Rx and Processing Started..',
        );
        // }
      }

    default:
      return Response(body: 'Invalid Method');
  }
}
