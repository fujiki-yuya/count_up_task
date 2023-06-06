import 'package:json_annotation/json_annotation.dart';


part 'news.g.dart';

@JsonSerializable()
class News{
  News({
    this.title,
    this.url,
  });

  factory News.fromJson(Map<String, dynamic> json) => _$NewsFromJson(json);

  final String? title;
  final String? url;

  Map<String, dynamic> toJson() => _$NewsToJson(this);
}
