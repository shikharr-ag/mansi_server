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

          unawaited(replyToUser(
            nameOfSender,
            messageBody,
            logger: logger,
          ));
          logger.info('\n\nSending response 200 to Meta..\n\n');
          return Response(body: 'Mansi will respond');
        }
      }

    default:
      return Response(body: 'Invalid Method');
  }
}

Future<bool> replyToUser(String name, String messageBody,
    {required RequestLogger logger}) {
  try {
    logger.debug('\n\nMessage sent to Mansi for processing\n\n');
    // Future.delayed(Duration(seconds: 5)).then((_) async{
    //   logger.debug('\n\nMessage Processed in BG\n\n');
    // });
    final messageSendEndpoint =
        Uri.parse('https://graph.facebook.com/v20.0/390332304171825/messages');
    final mansiEndpoint =
        Uri.parse('https://whxmgbtb-8000.inc1.devtunnels.ms/query');

    // .
    // catchError((er) {
    //   logger.error('\n\nCaught Error in Mansi Response => $er');
    //   return Future(() => http.Response("{'answer': 'error'}", 200));
    // }).then((resp) {
    // if (resp.statusCode != 200) {
    //   logger.error('Something went wrong: return ${resp.statusCode}');
    //   return;
    // }
    // logger.debug('\n\nMansi Response is: ${resp.body}\n\n');
    // const bearer =
    //     'EAAHoI1o82mEBOw0ZAAdAWmmO0sAhSmfKUKtyF9iXuE5yfbxPMUxPtprwZBv1AanJQx43WcxsKbIVMo3ekONoDTsujt8VwpkEDkvCgXXUetTEVgjelDsGRnTUqYfUDgay5hZBRbhM1oCnZC3hsSsnplZCAOuelMpR4dbdk7mHMkKUWCFCpPKvEodwBACqYGCeIuvD3viBoSOllMZAgJ2XLneHjQAvEtMrduyAlHXA8ZD';
    logger.debug('\n\nSending message to user..\n\n');
    return Future.sync(() {
      try {
        // http.post(
        //   mansiEndpoint,
        //   body: jsonEncode({
        //     'query': messageBody,
        //     'uid': 'RQ2pIEzjVsb3zbKkckms7a3iOnC3',
        //     'name': name,
        //     'goal_weight': 70,
        //     'current_weight': 75,
        //     'bmi': 24,
        //     'age': 22,
        //     'gender': 'male',
        //     'docid': 'fkTjWRTlT6OmiGihOs9y',
        //   }),
        //   headers: {
        //     'Content-Type': 'application/json',
        //   },
        // ).then((resp) {
        //   if (resp.statusCode != 200) {
        //     logger.error('Something went wrong: return ${resp.statusCode}');
        //     return;
        //   }
        //   logger.debug('\n\nMansi Response is: ${resp.body}\n\n');
        return http
            .post(
          messageSendEndpoint,
          headers: {
            'Authorization':
                'Bearer EAAHoI1o82mEBO8arYFjaeoyQocDnWJ7myS20ZCSxdmFYDyd63KPW1aFqdMbEEcUgH8cdoUJpe67oH0ZCbuYfihZA7E1ZBfgRQo5JLBacDUoMLabegQbliOZCCTrCXKS2jBqlk99b4ahlZBtgBs7iQx04TkZBfZBkmAmWbpmnIZCZCrE98OiEv5RrZAHfIjcm7yXRxF8ZBZC2TpaSaOoy7XGBE0umU75i9MWZCGM6ZB90g8ZD',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            'messaging_product': 'whatsapp',
            'recipient_type': 'individual',
            'to': '+916200052309',
            'type': 'text',
            'text': {
              'preview_url': false,
              'body':
                  // jsonDecode(resp.body)['response'] ?? 'No Response from Mansi',
                  'responding back..',
            },
          }),
        )
            .then((resp) {
          logger.info(
              'Response after sending message: ${resp.statusCode}\n\n${resp.body}\n\n');
          return true;
        });
      } catch (er) {
        logger.info('\nError in exec future $er\n');
        return false;
      }
    });
    // });

    // });
  } catch (er) {
    logger.error('\n\nSomething Went Wrong: $er\n\n');
    return Future(() => false);
  }
}
