import 'package:http/http.dart';

class CustomHttpClient extends BaseClient {
  BaseRequest? lastRequest;
  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    lastRequest = request;

    if (request.url.path.endsWith("empty-succ")) {
      return StreamedResponse(
        Stream.empty(),
        200,
        request: request,
      );
    }
    //Return custom status code to check for usage of this client.
    return StreamedResponse(
      request.finalize(),
      420,
      request: request,
    );
  }
}
