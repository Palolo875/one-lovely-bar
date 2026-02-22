// @dart=3.6
// ignore_for_file: directives_ordering
// build_runner >=2.4.16
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:build_runner/src/build_plan/builder_factories.dart' as _i1;
import 'package:freezed/builder.dart' as _i2;
import 'package:hive_ce_generator/hive_ce_generator.dart' as _i3;
import 'package:json_serializable/builder.dart' as _i4;
import 'package:mockito/src/builder.dart' as _i5;
import 'package:riverpod_generator/builder.dart' as _i6;
import 'package:source_gen/builder.dart' as _i7;
import 'dart:io' as _i8;
import 'package:build_runner/src/bootstrap/processes.dart' as _i9;

final _builderFactories = _i1.BuilderFactories(
  {
    'freezed:freezed': [_i2.freezed],
    'hive_ce_generator:hive_adapters_generator': [_i3.getAdaptersBuilder],
    'hive_ce_generator:hive_registrar_generator': [_i3.getRegistrarBuilder],
    'hive_ce_generator:hive_registrar_intermediate_generator': [
      _i3.getRegistrarIntermediateBuilder
    ],
    'hive_ce_generator:hive_schema_migrator': [_i3.getSchemaMigratorBuilder],
    'hive_ce_generator:hive_type_adapter_generator': [
      _i3.getTypeAdapterBuilder
    ],
    'json_serializable:json_serializable': [_i4.jsonSerializable],
    'mockito:mockBuilder': [_i5.buildMocks],
    'riverpod_generator:riverpod_generator': [_i6.riverpodBuilder],
    'source_gen:combining_builder': [_i7.combiningBuilder],
  },
  postProcessBuilderFactories: {'source_gen:part_cleanup': _i7.partCleanup},
);
void main(List<String> args) async {
  _i8.exitCode = await _i9.ChildProcess.run(
    args,
    _builderFactories,
  )!;
}
