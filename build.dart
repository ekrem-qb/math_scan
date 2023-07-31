import 'dart:io';

import 'package:innosetup/innosetup.dart';
import 'package:version/version.dart';

void main() {
  InnoSetup(
    app: InnoSetupApp(
      name: 'Math Scanner',
      executable: 'math_scan.exe',
      version: Version.parse('0.0.2'),
      publisher: 'Ekrem Bayram',
      urls: InnoSetupAppUrls(
        homeUrl: Uri.parse('https://github.com/ekrem-qb/math_scan'),
      ),
    ),
    files: InnoSetupFiles(
      executable: File('build/windows/runner/Release/math_scan.exe'),
      location: Directory('build/windows/runner/Release'),
    ),
    name: const InnoSetupName('Math Scanner'),
    location: InnoSetupInstallerDirectory(
      Directory('build/windows'),
    ),
    icon: InnoSetupIcon(
      File('windows/runner/resources/app_icon.ico'),
    ),
    compression: InnoSetupCompressions().lzma2(
      InnoSetupCompressionLevel.ultra64,
    ),
  ).make();
}
