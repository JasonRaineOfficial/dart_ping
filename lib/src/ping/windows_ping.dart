import 'package:dart_ping/dart_ping.dart';
import 'package:dart_ping/src/models/regex_parser.dart';
import 'package:dart_ping/src/ping/base_ping.dart';
import 'package:dart_ping/src/dart_ping_base.dart';

class PingWindows extends BasePing implements Ping {
  PingWindows(String host, int? count, double interval, double timeout, int ttl,
      bool ipv6,
      {PingParser? parser})
      : super(host, count, interval, timeout, ttl, ipv6, parser ?? _parser);

  static PingParser get _parser => PingParser(
      responseStr: RegExp(r'Reply from'),
      responseRgx: RegExp(r'from (.*): bytes=\d+() time=(\d+)ms TTL=(\d+)'),
      summaryStr: RegExp(r'Lost'),
      summaryRgx: RegExp(r'Sent = (\d+), Received = (\d+), Lost = (\d+)'),
      timeoutStr: RegExp(r'host unreachable|timed out'),
      unknownHostStr: RegExp(r'could not find host'),
      errorStr: RegExp(r'transmit failed'));

  @override
  List<String> get params {
    if (ipv6) throw UnimplementedError('IPv6 not implemented for windows');
    var params = ['-w', timeout.toString(), '-I', ttl.toString()];
    if (ipv6) {
      params.add('-6');
    } else {
      params.add('-4');
    }
    if (count == null) {
      params.add('-t');
    } else {
      params.add('-n');
      params.add(count.toString());
    }
    return params;
  }

  @override
  PingError? interpretExitCode(int exitCode) => PingError(ErrorType.Unknown,
      message: 'Ping process exited with code: $exitCode');

  @override
  Exception throwExit(int exitCode) =>
      Exception('Ping process exited with code: $exitCode');
}
