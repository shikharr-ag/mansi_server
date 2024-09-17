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

            replyToUser(messageFrom, messageBody, logger: logger);
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

Future<bool> replyToUser(String name, String messageBody,
    {required RequestLogger logger}) {
  try {
    // return Future.delayed(
    //   Duration(seconds: 3),
    // ).then((_) {
    //   logger.info('\nMESSAGE SENT!\n');
    //   return true;
    // });
    logger.debug('\n\nMessage sent to Mansi for processing\n\n');
    // Future.delayed(Duration(seconds: 5)).then((_) async{
    //   logger.debug('\n\nMessage Processed in BG\n\n');
    // });
    final messageSendEndpoint =
        Uri.parse('https://graph.facebook.com/v20.0/390332304171825/messages');
    final mansiEndpoint =
        Uri.parse('https://whxmgbtb-8000.inc1.devtunnels.ms/query');
    logger.debug('\n\nEndpoints Declared...\n\n');
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
    // logger.debug('\n\nSending message to user..\n\n');
    return Future.sync(() {
      logger.debug('\n\nEntered Future sync..\n\n');
      try {
        logger.debug('\n\nreturn post call to masni endpoint.\n\n');
        return http.post(
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
                  'Bearer EAAHoI1o82mEBO1MFhvSgHMZAnZAykgasTHHJLtyjeS7vLUV4h4VqN70DoMLtTceg6iIKMwamSmLd5j78FpjUZAqONh3I2jOqOPIvIVMTzSb2NzZClhIygkkVZCx3mH6F8g8qUHkGEDhMJL4W2XA7tMg0qBxYWMZCawrBfW1ZBPyhPu5mvsJtosBDlR44skin2uTcJ6gbJ53HlnQTzdsQwHJAcUcl0Bm3MKnKZBQZD',
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
