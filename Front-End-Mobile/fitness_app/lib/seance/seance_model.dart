import 'package:json_annotation/json_annotation.dart';

part 'seance_model.g.dart';

// Convertisseur personnalisé pour Duration
class DurationConverter implements JsonConverter<Duration, int> {
  const DurationConverter();

  @override
  Duration fromJson(int milliseconds) => Duration(milliseconds: milliseconds);

  @override
  int toJson(Duration duration) => duration.inMilliseconds;
}

@JsonSerializable()
class Seance {
  final String id;
  final String userId;
  final String typeExercice;

  @DurationConverter()
  final Duration duree;
  final double caloriesBrulees;
  final double valeurRealisee;
  final String unite;
  final String notes;
  final Map<String, dynamic>? suiviGps; // Coordonnées GPS
  final Map<String, dynamic>? accelData; // Données de l'accéléromètre

  Seance({
    required this.id,
    required this.userId,
    required this.typeExercice,
    required this.duree,
    required this.caloriesBrulees,
    required this.valeurRealisee,
    required this.unite,
    required this.notes,
    this.suiviGps,
    this.accelData,
  });

  factory Seance.fromJson(Map<String, dynamic> json) => _$SeanceFromJson(json);
  Map<String, dynamic> toJson() => _$SeanceToJson(this);
}
