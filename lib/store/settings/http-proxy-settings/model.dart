import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class HttpProxySettings extends Equatable {
  final bool enabled; // proxy enabled
  final String host;
  final String port;

  const HttpProxySettings({
    this.enabled = false,
    this.host = '127.0.0.1',
    this.port = '8118',
  });

  @override
  List<Object?> get props => [
        enabled,
        host,
        port,
      ];

  HttpProxySettings copyWith({
    enabled,
    host,
    port,
  }) =>
      HttpProxySettings(
        enabled: enabled ?? this.enabled,
        host: host ?? this.host,
        port: port ?? this.port,
      );

  Map<String, dynamic> toJson() => _$HttpProxySettingsToJson(this);

  factory HttpProxySettings.fromJson(Map<String, dynamic> json) =>
      _$HttpProxySettingsFromJson(json);
}