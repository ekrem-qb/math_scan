import 'dart:io';

import 'package:innosetup/innosetup.dart';
import 'package:version/version.dart';

void main() {
  InnoSetup(
    app: InnoSetupApp(
      name: 'Math Scanner',
      executable: 'math_scan.exe',
      version: Version.parse('0.0.4'),
      publisher: 'Ekrem Bayram',
      urls: InnoSetupAppUrls(
        homeUrl: Uri.parse('https://github.com/ekrem-qb/math_scan'),
      ),
    ),
    files: InnoSetupFiles(
      executable: File('build/windows/x64/runner/Release/math_scan.exe'),
      location: Directory('build/windows/x64/runner/Release'),
    ),
    name: const InnoSetupName('Math_Scanner'),
    location: InnoSetupInstallerDirectory(
      Directory('build/windows/x64'),
    ),
    icon: InnoSetupIcon(
      File('windows/runner/resources/app_icon.ico'),
    ),
    compression: InnoSetupCompressions().lzma2(
      InnoSetupCompressionLevel.ultra64,
    ),
  ).make();
}
