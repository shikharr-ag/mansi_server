import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_request_logger/dart_frog_request_logger.dart';

Future<Response> onRequest(RequestContext context) async {
  RequestLogger logger = context.read<RequestLogger>();

  switch (context.request.method) {
    case HttpMethod.post:
      Map<String, dynamic> body =
          jsonDecode(await context.request.body()) as Map<String, dynamic>;
      logger.info('Recv body as $body');
      // await Future.delayed(Duration(seconds: 50)).then((_) {
      //   logger.info('Performed a very long operation');
      // });
      await replyToUser(
          (body['from'] ?? '').toString(), (body['body'] ?? '').toString(),
          logger: logger);
      return Response(body: 'Processed the incoming message');

    default:
      return Response(body: 'Method Not Allowed', statusCode: 401);
  }
}

Future<bool> replyToUser(String name, String messageBody,
    {required RequestLogger logger}) {
  try {
    logger.debug('\n\nMessage sent to Mansi for processing\n\n');

    final messageSendEndpoint =
        Uri.parse('https://graph.facebook.com/v20.0/390332304171825/messages');
    final mansiEndpoint = Uri.parse(
        'https://github-model-171951671217.us-central1.run.app/query');
    logger.debug('\n\nEndpoints Declared...\n\n');
    return Future.sync(() async {
      logger.debug('\n\nEntered Future sync..\n\n');
      try {
        logger.debug('\n\nreturn post call to mansi endpoint.\n\n');
        return await http.post(
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
            'docid': 'fkTjWRTlT6OmiGihOs9y',
          }),
          headers: {
            'Content-Type': 'application/json',
          },
        ).then((resp) {
          if (resp.statusCode != 200) {
            logger.error(
                'Something went wrong at Mansi Endpoint return ${resp.statusCode}');
            return false;
          }
          logger.info('\n\nMansi Sent A Response as: ${resp.body}\n\n');
          logger.info('\n\nSending Message via Meta Graph API\n\n');

          return http
              .post(
            messageSendEndpoint,
            headers: {
              'Authorization':
                  'Bearer EAAHoI1o82mEBOwXTkGYQILceptL3icx0UMoZCD2yx3lhzdu51c7pYcZBOws5xKyXYHQ8ZAMSQ1hZBx3hGoATV0OFtnZCYN314OtYWcz8d2sje50sMsMfKtn44v5jLDkZAIVjYrRYgZBL5kI0t7WkqZCRh02Ebhr11GiFHqEKZBfOvkfvfXxMTO6uRUnwbD2h2aginBBx48N7TslF6hvcJQZCnyHunzdLGrv8tOaYsZD',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              'messaging_product': 'whatsapp',
              'recipient_type': 'individual',
              'to': '+916200052309',
              'type': 'text',
              'text': {
                'preview_url': false,
                'body': jsonDecode(resp.body)['response'] ??
                    'No Response from Mansi',
                // 'responding back..',
              },
            }),
          )
              .then((resp) {
            logger.info(
                'Response after sending message: ${resp.statusCode}\n\n${resp.body}\n\n');
            return true;
          });
          // return true;
        });
      } catch (er) {
        logger.info('\nError in exec future $er\n');
        return false;
      }
    });
  } catch (er) {
    logger.error('\n\nSomething Went Wrong: $er\n\n');
    return Future(() => false);
  }
}
