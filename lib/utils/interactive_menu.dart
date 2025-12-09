import 'dart:io';
import 'package:tint/tint.dart';
import 'animated_ui.dart';

/// Interactive menu item
class MenuItem {
  final String id;
  final String title;
  final String description;
  final Function() onSelect;
  final List<MenuItem>? subMenu;

  MenuItem({
    required this.id,
    required this.title,
    required this.description,
    required this.onSelect,
    this.subMenu,
  });
}

/// Interactive menu system with keyboard navigation
class InteractiveMenu {
  final List<MenuItem> items;
  final String title;
  int selectedIndex = 0;

  InteractiveMenu({
    required this.items,
    required this.title,
  });

  /// Display and run the interactive menu
  Future<void> show() async {
    while (true) {
      _render();
      
      final input = _readKey();
      
      if (input == 'up' && selectedIndex > 0) {
        selectedIndex--;
      } else if (input == 'down' && selectedIndex < items.length - 1) {
        selectedIndex++;
      } else if (input == 'enter') {
        AnimatedUI.clearScreen();
        await items[selectedIndex].onSelect();
        await Future.delayed(Duration(milliseconds: 500));
        
        // Check if we should exit
        if (items[selectedIndex].id == 'exit') {
          break;
        }
      } else if (input == 'q' || input == 'escape') {
        break;
      }
    }
  }

  /// Render the menu with bright, visible colors
  void _render() {
    AnimatedUI.clearScreen();
    
    print('');
    
    // Fixed width: 68 characters between borders
    final width = 68;
    
    print('╔${'═' * width}╗'.cyan());
    print('║${' ' * width}║'.cyan());
    
    // Title centered
    final titlePadding = ((width - title.length) / 2).floor();
    print('║${' ' * titlePadding}${title.white().bold()}${' ' * (width - titlePadding - title.length)}║'.cyan());
    
    print('║${' ' * width}║'.cyan());
    print('╠${'═' * width}╣'.cyan());

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final isSelected = i == selectedIndex;
      final numStr = (i + 1).toString().padLeft(2, '0');
      
      // Build line content
      String line;
      if (isSelected) {
        line = ' ▶ [$numStr] ${item.title.padRight(25)} ${item.description}';
      } else {
        line = '   [$numStr] ${item.title.padRight(25)} ${item.description}';
      }
      
      // Ensure exact width
      if (line.length > width) {
        line = line.substring(0, width);
      } else {
        line = line.padRight(width);
      }
      
      // Apply colors
      if (isSelected) {
        print('║${line.green().bold()}║'.cyan());
      } else {
        print('║${line.white()}║'.cyan());
      }
    }

    print('╠${'═' * width}╣'.cyan());
    print('║${' ' * width}║'.cyan());
    
    final navLine = '  ◆ Navigate: ↑/↓ or W/S or 1-${items.length}  •  Enter confirm  •  Q quit';
    final navPadded = navLine.padRight(width);
    print('║${navPadded.white()}║'.cyan());
    
    print('║${' ' * width}║'.cyan());
    print('╚${'═' * width}╝'.cyan());
    print('');
  }

  /// Read keyboard input with proper Windows arrow key support
  String _readKey() {
    try {
      stdin.echoMode = false;
      stdin.lineMode = false;
    } catch (e) {
      // Ignore if terminal doesn't support these modes
    }

    final key = stdin.readByteSync();

    try {
      stdin.echoMode = true;
      stdin.lineMode = true;
    } catch (e) {
      // Ignore if terminal doesn't support these modes
    }

    // Windows Command Prompt / PowerShell arrow keys
    // These start with 224 (0xE0) or 0 (0x00)
    if (key == 224 || key == 0) {
      try {
        final next = stdin.readByteSync();
        switch (next) {
          case 72: // Up arrow
            return 'up';
          case 80: // Down arrow
            return 'down';
          case 75: // Left arrow
            return 'left';
          case 77: // Right arrow
            return 'right';
        }
      } catch (e) {
        // Ignore read errors
      }
    }
    
    // Unix/Linux terminals and Windows Terminal (ANSI escape sequences)
    // These start with ESC (27 / 0x1B)
    if (key == 27) {
      try {
        // Check if there's more data (escape sequence)
        final next1 = stdin.readByteSync();
        if (next1 == 91) { // '[' character
          final next2 = stdin.readByteSync();
          switch (next2) {
            case 65: // 'A' - Up arrow
              return 'up';
            case 66: // 'B' - Down arrow
              return 'down';
            case 67: // 'C' - Right arrow
              return 'right';
            case 68: // 'D' - Left arrow
              return 'left';
          }
        }
      } catch (e) {
        // If we can't read more bytes, treat as ESC key
      }
      return 'escape';
    }

    // Regular keys (most reliable)
    if (key == 13 || key == 10) return 'enter';
    if (key == 113 || key == 81) return 'q'; // q or Q
    if (key == 119 || key == 87) return 'up'; // w or W (backup)
    if (key == 115 || key == 83) return 'down'; // s or S (backup)
    
    // Number keys for direct selection (1-9)
    if (key >= 49 && key <= 57) {
      final num = key - 48; // Convert ASCII to number (1-9)
      if (num >= 1 && num <= items.length) {
        selectedIndex = num - 1;
        return 'enter';
      }
    }

    return String.fromCharCode(key);
  }
}

/// Quick selection menu (numbered choices)
class QuickMenu {
  static Future<int?> show(String title, List<String> options) async {
    AnimatedUI.clearScreen();
    
    print('');
    AnimatedUI.separator();
    await AnimatedUI.typeText('  $title', delayMs: 20);
    AnimatedUI.separator();
    print('');

    for (var i = 0; i < options.length; i++) {
      print('  [${(i + 1).toString().cyan()}] ${options[i]}');
    }

    print('');
    stdout.write('  Select option (1-${options.length}): '.cyan());
    
    final input = stdin.readLineSync();
    final choice = int.tryParse(input ?? '');
    
    if (choice != null && choice >= 1 && choice <= options.length) {
      return choice - 1;
    }
    
    return null;
  }
}
