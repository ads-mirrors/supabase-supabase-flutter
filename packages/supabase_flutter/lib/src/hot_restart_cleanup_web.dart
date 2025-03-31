import 'dart:js_interop';

import 'package:supabase_flutter/supabase_flutter.dart';

@JS()
external JSFunction? supabaseFlutterClientToDispose;

/// Store a function to properly dispose the previous [SupabaseClient] in
/// the js context.
///
/// WebSocket connections and [BroadcastChannel] are not closed when Flutter is hot-restarted on web.
///
/// This causes old dart code that is still associated with those
/// connections to be still running and causes unexpected behavior like type
/// errors and the fact that the events of the old connection may still be
/// logged.
void markClientToDispose(SupabaseClient client) {
  void dispose() {
    client.realtime.disconnect(
        code: 1000, reason: 'Closed due to Flutter Web hot-restart');
    client.dispose();
  }

  supabaseFlutterClientToDispose = dispose.toJS;
}

/// Disconnect the previous [SupabaseClient] if it exists.
///
/// This is done by calling the function stored by
/// [markClientToDispose] from the js context
void disposePreviousClient() {
  if (supabaseFlutterClientToDispose != null) {
    supabaseFlutterClientToDispose!.callAsFunction();
    supabaseFlutterClientToDispose = null;
  }
}
