#!/usr/bin/env dart

import 'dart:io';

import 'package:args/args.dart';
import 'package:maloc/commands/create_feature.dart';
import 'package:maloc/commands/remove_feature.dart';
import 'package:maloc/utils/logger.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addCommand(
        'create',
        ArgParser()
          ..addOption('name',
              abbr: 'n', help: 'Feature name (e.g., products, profile)')
          ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help'))
    ..addCommand(
        'remove',
        ArgParser()
          ..addOption('name',
              abbr: 'n', help: 'Feature name to remove (e.g., products)')
          ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help'))
    ..addFlag('version', abbr: 'v', negatable: false, help: 'Show version')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help');

  try {
    final results = parser.parse(arguments);

    if (results['help'] == true || arguments.isEmpty) {
      _printHelp(parser);
      return;
    }

    if (results['version'] == true) {
      Logger.info('Maloc CLI v1.0.0');
      return;
    }

    final command = results.command;

    if (command == null) {
      Logger.error('No command specified');
      _printHelp(parser);
      exit(1);
    }

    switch (command.name) {
      case 'create':
        if (command['help'] == true) {
          _printCreateHelp();
          return;
        }

        final name = command['name'] as String?;
        if (name == null || name.isEmpty) {
          Logger.error('Feature name is required');
          Logger.info('Usage: maloc create --name <feature_name>');
          exit(1);
        }

        await CreateFeatureCommand(name).execute();
        break;

      case 'remove':
        if (command['help'] == true) {
          _printRemoveHelp();
          return;
        }

        final name = command['name'] as String?;
        if (name == null || name.isEmpty) {
          Logger.error('Feature name is required');
          Logger.info('Usage: maloc remove --name <feature_name>');
          exit(1);
        }

        await RemoveFeatureCommand(name).execute();
        break;

      default:
        Logger.error('Unknown command: ${command.name}');
        _printHelp(parser);
        exit(1);
    }
  } catch (e) {
    Logger.error('Error: $e');
    exit(1);
  }
}

void _printHelp(ArgParser parser) {
  print('''
╔═══════════════════════════════════════════════════════════════╗
║                    🚀 Maloc CLI v1.0.0                       ║
║     Clean Architecture Feature Generator (Melos + BLoC)      ║
╚═══════════════════════════════════════════════════════════════╝

Usage: maloc <command> [options]

Commands:
  create    Create a new feature package with Clean Architecture
  remove    Remove an existing feature package

Options:
${parser.usage}

Examples:
  # Create a new feature
  maloc create --name products
  maloc create -n user_profile

  # Remove a feature
  maloc remove --name products
  maloc remove -n user_profile

Run "maloc <command> --help" for more information about a command.
''');
}

void _printCreateHelp() {
  print('''
Create a new feature package with Clean Architecture

Usage: maloc create --name <feature_name>

Options:
  -n, --name    Feature name (e.g., products, profile)
  -h, --help    Show this help message

The command will create:
  ✓ Complete package structure
  ✓ Domain layer (entities, repositories, use cases)
  ✓ Data layer (models, datasources, repository implementations)
  ✓ Presentation layer (BLoC, pages, widgets)
  ✓ Barrel export file
  ✓ pubspec.yaml with dependencies

Example:
  maloc create --name products

This creates: packages/features_products/
''');
}

void _printRemoveHelp() {
  print('''
Remove an existing feature package

Usage: maloc remove --name <feature_name>

Options:
  -n, --name    Feature name to remove (required)
  -h, --help    Show this help message

What gets removed:
  ✓ Feature directory (packages/features_*)
  ✓ Dependency from app/pubspec.yaml
  ✓ Routes from app_routes.dart
  ✓ Route registration from app_route_generator.dart
  ✓ Import statement from app_route_generator.dart

Example:
  maloc remove --name products

⚠️  You will be asked for confirmation before deletion.
''');
}
