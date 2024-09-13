import 'dart:convert';
import 'dart:developer';

import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final request = context.request;

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
}
