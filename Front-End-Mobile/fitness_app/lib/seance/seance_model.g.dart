// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Seance _$SeanceFromJson(Map<String, dynamic> json) => Seance(
      valeurRealisee: (json['valeur_realisee'] as num).toDouble(),
      unite: json['unite'] as String,
      id: json['id'] as String,
      userId: json['id_user'] as String,
      typeExercice: json['type_exercice'] as String,
      duree: Duration(microseconds: (json['duree'] as num).toInt()),
      caloriesBrulees: (json['calories_brulees'] as num).toDouble(),
      notes: json['notes'] as String,
      suiviGps: json['suivi_gps'] as Map<String, dynamic>?,
      accelData: json['accel_data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SeanceToJson(Seance instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'typeExercice': instance.typeExercice,
      'duree': instance.duree.inMicroseconds,
      'caloriesBrulees': instance.caloriesBrulees,
      'valeur_realise': instance.valeurRealisee,
      'unite': instance.unite,
      'notes': instance.notes,
      'suiviGps': instance.suiviGps,
      'accelData': instance.accelData,
    };
