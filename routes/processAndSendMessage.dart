import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_request_logger/dart_frog_request_logger.dart';

Future<Response> onRequest(RequestContext context) async {
  RequestLogger logger = context.read<RequestLogger>();

  switch (context.request.method) {
    case HttpMethod.post:
      Map<String, dynamic> body =
          jsonDecode(await context.request.body()) as Map<String, dynamic>;
      logger.info('Recv body as $body');
      await Future.delayed(Duration(seconds: 50)).then((_) {
        logger.info('Performed a very long operation');
      });
      return Response(body: 'Processed the incoming message');

    default:
      return Response(body: 'Method Not Allowed', statusCode: 401);
  }
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
    return Future.delayed(Duration(seconds: 50)).then((_) {
      logger.debug('\n\nVery Long Function Returned Result...\n\n');
      return true;
    });
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
    // return Future.sync(() {
    //   logger.debug('\n\nEntered Future sync..\n\n');
    //   try {
    //     logger.debug('\n\nreturn post call to mansi endpoint.\n\n');
    //     return http.post(
    //       mansiEndpoint,
    //       body: jsonEncode({
    //         'query': messageBody,
    //         'uid': 'RQ2pIEzjVsb3zbKkckms7a3iOnC3',
    //         'name': name,
    //         'goal_weight': 70,
    //         'current_weight': 75,
    //         'bmi': 24,
    //         'age': 22,
    //         'gender': 'male',
    //         'docid': 'fkTjWRTlT6OmiGihOs9y',
    //       }),
    //       headers: {
    //         'Content-Type': 'application/json',
    //       },
    //     ).then((resp) {
    //       if (resp.statusCode != 200) {
    //         logger.error(
    //             'Something went wrong at Mansi Endpoint return ${resp.statusCode}');
    //         return false;
    //       }
    //       logger.info('\n\nMansi Sent A Response as: ${resp.body}\n\n');
    // logger.info('\n\nSending Message via Meta Graph API\n\n');

    // return http
    //     .post(
    //   messageSendEndpoint,
    //   headers: {
    //     'Authorization':
    //         'Bearer EAAHoI1o82mEBO7CoR1j0kBVfoPxdvFCQgJ80oGWImdou0WcvXjjafO0t1hAdbXgh0UXE07JZB5UMIOncDnH96TEkjlKxwkJwwsy51Nr9kQxuAe9kIUnEc48dN3EVMsvrR9eFZAu0e6Mo3ZC0AslCmAC8e3aZAQOB22yMB4jlWvCTKn40b2zdqj4ZCzITUkuL6Xorf48iiHXRNuVRLDlcSe1zWuBZAp2SOJlocZD',
    //     'Content-Type': 'application/json'
    //   },
    //   body: jsonEncode({
    //     'messaging_product': 'whatsapp',
    //     'recipient_type': 'individual',
    //     'to': '+916200052309',
    //     'type': 'text',
    //     'text': {
    //       'preview_url': false,
    //       'body':
    //           //  jsonDecode(resp.body)['response'] ??
    //           //     'No Response from Mansi',
    //           'responding back..',
    //     },
    //   }),
    // )
    //     .then((resp) {
    //   logger.info(
    //       'Response after sending message: ${resp.statusCode}\n\n${resp.body}\n\n');
    //   return true;
    // });
    //       return true;
    //     });
    //   } catch (er) {
    //     logger.info('\nError in exec future $er\n');
    //     return false;
    //   }
    // });
  } catch (er) {
    logger.error('\n\nSomething Went Wrong: $er\n\n');
    return Future(() => false);
  }
}
