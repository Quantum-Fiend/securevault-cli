import 'dart:io';
import 'dart:async';
import 'package:tint/tint.dart';

/// Animated UI utilities for hacker-style interface
class AnimatedUI {
  static const int _typingDelayMs = 30;
  static const int _glitchDelayMs = 50;

  /// Print text with typing animation effect
  static Future<void> typeText(String text, {int delayMs = _typingDelayMs, bool newLine = true}) async {
    for (var char in text.split('')) {
      stdout.write(char);
      await Future.delayed(Duration(milliseconds: delayMs));
    }
    if (newLine) print('');
  }

  /// Print text with glitch effect
  static Future<void> glitchText(String text, {int iterations = 3}) async {
    final glitchChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?~/\\';
    final random = DateTime.now().millisecondsSinceEpoch;
    
    for (var i = 0; i < iterations; i++) {
      // Show glitched version
      final glitched = text.split('').map((char) {
        if (char == ' ') return ' ';
        return (random + i) % 3 == 0 ? glitchChars[(random + char.codeUnitAt(0)) % glitchChars.length] : char;
      }).join();
      
      stdout.write('\r$glitched');
      await Future.delayed(Duration(milliseconds: _glitchDelayMs));
    }
    
    // Show final correct version
    stdout.write('\r$text');
    print('');
  }

  /// Print animated ASCII banner
  static Future<void> printBanner() async {
    final banner = '''
╔═════════════════════════════════════════════════════════════════════╗
║                                                                     ║
║   ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗████████╗██╗   ██╗███╗   ███   ║
║  ██╔═══██╗██║   ██║██╔══██╗████╗  ██║╚══██╔══╝██║   ██║████╗ ████   ║
║  ██║   ██║██║   ██║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██   ║
║  ██║▄▄ ██║██║   ██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██   ║
║  ╚██████╔╝╚██████╔╝██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██   ║
║   ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═   ║
║                                                                     ║
║              ███████╗██╗███████╗███╗   ██╗██████╗                   ║
║              ██╔════╝██║██╔════╝████╗  ██║██╔══██╗                  ║
║              █████╗  ██║█████╗  ██╔██╗ ██║██║  ██║                  ║
║              ██╔══╝  ██║██╔══╝  ██║╚██╗██║██║  ██║                  ║
║              ██║     ██║███████╗██║ ╚████║██████╔╝                  ║
║              ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝╚═════╝                   ║
║                                                                     ║
╚═════════════════════════════════════════════════════════════════════╝''';

    print(banner.cyan());
    await Future.delayed(Duration(milliseconds: 300));
  }

  /// Print SecureVault branded banner
  static Future<void> printSecureVaultBanner() async {
    clearScreen();
    
    // Glitch effect on startup
    for (var i = 0; i < 3; i++) {
      print('█' * 70);
      await Future.delayed(Duration(milliseconds: 50));
      clearScreen();
      await Future.delayed(Duration(milliseconds: 50));
    }

    final banner = '''
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║        ███████╗███████╗ ██████╗██╗   ██╗██████╗ ███████╗          ║
║        ██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██╔════╝          ║
║        ███████╗█████╗  ██║     ██║   ██║██████╔╝█████╗            ║
║        ╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██╔══╝            ║
║        ███████║███████╗╚██████╗╚██████╔╝██║  ██║███████╗          ║
║        ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝          ║
║                                                                   ║
║        ██╗   ██╗ █████╗ ██╗   ██╗██╗  ████████╗                   ║
║        ██║   ██║██╔══██╗██║   ██║██║  ╚══██╔══╝                   ║
║        ██║   ██║███████║██║   ██║██║     ██║                      ║
║        ╚██╗ ██╔╝██╔══██║██║   ██║██║     ██║                      ║
║         ╚████╔╝ ██║  ██║╚██████╔╝███████╗██║                      ║
║          ╚═══╝  ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝                      ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝''';

    print(banner.cyan().bold());
    await Future.delayed(Duration(milliseconds: 200));
    
    await typeText('    🔐  Encrypted Password Manager  •  Fully Offline  •  AES-256-GCM'.green(), delayMs: 15);
    print('');
    await Future.delayed(Duration(milliseconds: 300));
  }

  /// Matrix-style loading animation
  static Future<void> matrixLoad(String message, {int durationMs = 1500}) async {
    final chars = '01';
    final width = 50;
    final random = DateTime.now().millisecondsSinceEpoch;
    
    stdout.write('$message ');
    final startTime = DateTime.now().millisecondsSinceEpoch;
    
    while (DateTime.now().millisecondsSinceEpoch - startTime < durationMs) {
      final matrix = List.generate(10, (i) => chars[(random + i) % chars.length]).join();
      stdout.write('\r$message ${matrix.green()}');
      await Future.delayed(Duration(milliseconds: 100));
    }
    
    stdout.write('\r$message ${'✓'.green()}\n');
  }

  /// Progress bar animation
  static Future<void> progressBar(String label, {int durationMs = 1000}) async {
    final width = 40;
    stdout.write('$label [');
    
    for (var i = 0; i <= width; i++) {
      final filled = '█' * i;
      final empty = '░' * (width - i);
      final percent = ((i / width) * 100).toInt();
      stdout.write('\r$label [$filled$empty] $percent%');
      await Future.delayed(Duration(milliseconds: durationMs ~/ width));
    }
    
    print(' ✓'.green());
  }

  /// Clear screen
  static void clearScreen() {
    if (Platform.isWindows) {
      print('\x1B[2J\x1B[0;0H');
    } else {
      print('\x1B[2J\x1B[0;0H');
    }
  }

  /// Print separator line
  static void separator({String char = '═', int length = 70}) {
    print((char * length).cyan());
  }

  /// Print menu option with animation
  static Future<void> printMenuOption(int number, String text, String description, {bool selected = false}) async {
    final prefix = selected ? '▶' : ' ';
    final numStr = number.toString().padLeft(2, '0');
    final color = selected ? (String s) => s.cyan().bold() : (String s) => s.white();
    
    print('  $prefix ${color('[$numStr]')} ${color(text.padRight(20))} ${description.dim()}');
  }

  /// Hacker-style system message
  static Future<void> systemMessage(String message, {String type = 'INFO'}) async {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final icon = switch (type) {
      'SUCCESS' => '✓'.green(),
      'ERROR' => '✗'.red(),
      'WARNING' => '⚠'.yellow(),
      'INFO' => 'ℹ'.blue(),
      _ => '•',
    };
    
    await typeText('[$timestamp] $icon $message', delayMs: 10);
  }

  /// Countdown animation
  static Future<void> countdown(int seconds) async {
    for (var i = seconds; i > 0; i--) {
      stdout.write('\rInitializing in ${i.toString().cyan().bold()}... ');
      await Future.delayed(Duration(seconds: 1));
    }
    stdout.write('\r' + ' ' * 30 + '\r');
  }

  /// Pulse animation for text
  static Future<void> pulseText(String text, {int pulses = 3}) async {
    for (var i = 0; i < pulses; i++) {
      stdout.write('\r${text.cyan().bold()}');
      await Future.delayed(Duration(milliseconds: 300));
      stdout.write('\r${text.dim()}');
      await Future.delayed(Duration(milliseconds: 300));
    }
    stdout.write('\r${text.cyan().bold()}\n');
  }
}
