import 'dart:html' as html;

enum AppViewTarget { pro, market, social }

class DomainGuard {
  static AppViewTarget get currentTarget {
    final port = html.window.location.port;
    final host = html.window.location.hostname?.toLowerCase() ?? '';

    if (host.contains('marketplace') || port == '8082') {
      return AppViewTarget.market;
    }
    if (host.contains('social') || port == '8083') {
      return AppViewTarget.social;
    }
    // Default case (hostname contains 'pro' or port equals '8081')
    return AppViewTarget.pro;
  }
}
