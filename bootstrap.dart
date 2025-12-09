#!/usr/bin/env dart

import 'dart:io';

void main() async {
  print('📦 Getting dependencies for all packages...\n');

  var successCount = 0;
  var failCount = 0;

  // Get dependencies for packages
  final packagesDir = Directory('packages');
  if (await packagesDir.exists()) {
    await for (var entity in packagesDir.list()) {
      if (entity is Directory) {
        final pubspecFile = File('${entity.path}/pubspec.yaml');
        if (await pubspecFile.exists()) {
          final packageName = entity.path.split(Platform.pathSeparator).last;
          print('  ▸ $packageName');

          final result = await Process.run(
            'dart',
            ['pub', 'get'],
            workingDirectory: entity.path,
            runInShell: true,
          );

          if (result.exitCode == 0) {
            print('    ✓ Dependencies installed');
            successCount++;
          } else {
            print('    ✗ Failed to install dependencies');
            failCount++;
          }
        }
      }
    }
  }

  // Get dependencies for CLI
  final cliDir = Directory('cli');
  final cliPubspec = File('cli/pubspec.yaml');
  if (await cliDir.exists() && await cliPubspec.exists()) {
    print('  ▸ cli');

    final result = await Process.run(
      'dart',
      ['pub', 'get'],
      workingDirectory: 'cli',
      runInShell: true,
    );

    if (result.exitCode == 0) {
      print('    ✓ Dependencies installed');
      successCount++;
    } else {
      print('    ✗ Failed to install dependencies');
      failCount++;
    }
  }

  print('');
  if (failCount == 0) {
    print('✨ All packages bootstrapped successfully! ($successCount packages)');
  } else {
    print(
      '⚠ Bootstrapped with errors: $successCount succeeded, $failCount failed',
    );
    exit(1);
  }
}
