import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

/// Cryptography service for SecureVault
/// Implements AES-256-GCM encryption, PBKDF2 key derivation, and HMAC integrity
class CryptoService {
  static const int saltLength = 16; // 128 bits
  static const int ivLength = 12; // 96 bits for GCM
  static const int keyLength = 32; // 256 bits
  static const int pbkdf2Iterations = 100000;
  static const int pbkdf2IterationsStrong = 250000;
  static const int hmacIterations = 10000;

  final SecureRandom _secureRandom;

  CryptoService() : _secureRandom = _createSecureRandom();

  /// Create a cryptographically secure random number generator
  static SecureRandom _createSecureRandom() {
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seeds = List<int>.generate(32, (_) => random.nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  /// Generate random bytes
  Uint8List generateRandomBytes(int length) {
    return _secureRandom.nextBytes(length);
  }

  /// Generate a random salt
  Uint8List generateSalt() {
    return generateRandomBytes(saltLength);
  }

  /// Generate a random IV (Initialization Vector)
  Uint8List generateIV() {
    return generateRandomBytes(ivLength);
  }

  /// Derive encryption key from password using PBKDF2
  Uint8List deriveKey(
    String password,
    Uint8List salt, {
    int iterations = pbkdf2Iterations,
  }) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(salt, iterations, keyLength));
    return pbkdf2.process(Uint8List.fromList(utf8.encode(password)));
  }

  /// Encrypt data using AES-256-GCM
  EncryptedData encrypt(
    String plaintext,
    String password,
    Uint8List salt, {
    int iterations = pbkdf2Iterations,
  }) {
    // Derive key from password
    final key = deriveKey(password, salt, iterations: iterations);

    // Generate random IV
    final iv = generateIV();

    // Create AES-GCM cipher
    final cipher = GCMBlockCipher(AESEngine());
    final params = AEADParameters(
      KeyParameter(key),
      128, // tag length in bits
      iv,
      Uint8List(0), // additional authenticated data
    );

    cipher.init(true, params); // true = encrypt

    // Encrypt the data
    final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));
    final encryptedBytes = cipher.process(plaintextBytes);

    return EncryptedData(
      data: encryptedBytes,
      iv: iv,
    );
  }

  /// Decrypt data using AES-256-GCM
  String decrypt(
    Uint8List encryptedData,
    Uint8List iv,
    String password,
    Uint8List salt, {
    int iterations = pbkdf2Iterations,
  }) {
    try {
      // Derive key from password
      final key = deriveKey(password, salt, iterations: iterations);

      // Create AES-GCM cipher
      final cipher = GCMBlockCipher(AESEngine());
      final params = AEADParameters(
        KeyParameter(key),
        128, // tag length in bits
        iv,
        Uint8List(0), // additional authenticated data
      );

      cipher.init(false, params); // false = decrypt

      // Decrypt the data
      final decryptedBytes = cipher.process(encryptedData);
      return utf8.decode(decryptedBytes);
    } catch (e) {
      throw Exception('Decryption failed: Invalid password or corrupted data');
    }
  }

  /// Generate HMAC signature for integrity verification
  Uint8List generateHMAC(String data, String password, Uint8List salt) {
    // Derive HMAC key using PBKDF2
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(salt, hmacIterations, 32));
    final hmacKey = pbkdf2.process(Uint8List.fromList(utf8.encode(password)));

    // Generate HMAC
    final hmac = Hmac(sha256, hmacKey);
    final digest = hmac.convert(utf8.encode(data));
    return Uint8List.fromList(digest.bytes);
  }

  /// Verify HMAC signature
  bool verifyHMAC(
    String data,
    Uint8List signature,
    String password,
    Uint8List salt,
  ) {
    final expectedSignature = generateHMAC(data, password, salt);
    if (signature.length != expectedSignature.length) {
      return false;
    }

    // Constant-time comparison to prevent timing attacks
    var result = 0;
    for (var i = 0; i < signature.length; i++) {
      result |= signature[i] ^ expectedSignature[i];
    }
    return result == 0;
  }

  /// Generate a secure random password
  String generatePassword({
    int length = 20,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeDigits = true,
    bool includeSymbols = true,
    bool excludeAmbiguous = true,
  }) {
    var charset = '';

    if (includeLowercase) {
      charset += excludeAmbiguous
          ? 'abcdefghjkmnpqrstuvwxyz'
          : 'abcdefghijklmnopqrstuvwxyz';
    }
    if (includeUppercase) {
      charset += excludeAmbiguous
          ? 'ABCDEFGHJKLMNPQRSTUVWXYZ'
          : 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    }
    if (includeDigits) {
      charset += excludeAmbiguous ? '23456789' : '0123456789';
    }
    if (includeSymbols) {
      charset += '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    }

    if (charset.isEmpty) {
      throw ArgumentError('At least one character type must be selected');
    }

    final random = generateRandomBytes(length);
    final buffer = StringBuffer();

    for (var i = 0; i < length; i++) {
      buffer.write(charset[random[i] % charset.length]);
    }

    return buffer.toString();
  }

  /// Calculate password entropy in bits
  double calculateEntropy(String password) {
    var charsetSize = 0;

    if (RegExp(r'[a-z]').hasMatch(password)) charsetSize += 26;
    if (RegExp(r'[A-Z]').hasMatch(password)) charsetSize += 26;
    if (RegExp(r'[0-9]').hasMatch(password)) charsetSize += 10;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) charsetSize += 32;

    if (charsetSize == 0) return 0;

    return log(pow(charsetSize, password.length)) / ln2;
  }

  /// Analyze password strength
  PasswordStrength analyzePasswordStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength(
        score: 0,
        strength: 'none',
        entropy: 0,
        feedback: 'Enter a password',
      );
    }

    final entropy = calculateEntropy(password);
    final length = password.length;

    // Check for patterns
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasDigits = RegExp(r'[0-9]').hasMatch(password);
    final hasSymbols = RegExp(r'[^a-zA-Z0-9]').hasMatch(password);
    final hasSequential =
        RegExp(r'abc|bcd|cde|123|234|345|456|567|678|789', caseSensitive: false)
            .hasMatch(password);
    final hasRepeating = RegExp(r'(.)\1{2,}').hasMatch(password);
    final hasCommonWords = RegExp(
      r'password|123456|qwerty|admin|letmein|welcome',
      caseSensitive: false,
    ).hasMatch(password);

    var score = 0;
    final feedback = <String>[];

    // Length scoring
    if (length >= 8) score += 1;
    if (length >= 12) score += 1;
    if (length >= 16) score += 1;
    if (length >= 20) score += 1;

    // Complexity scoring
    if (hasLowercase) score += 1;
    if (hasUppercase) score += 1;
    if (hasDigits) score += 1;
    if (hasSymbols) score += 1;

    // Entropy scoring
    if (entropy >= 50) score += 1;
    if (entropy >= 75) score += 1;

    // Penalties
    if (hasSequential) score -= 2;
    if (hasRepeating) score -= 1;
    if (hasCommonWords) score -= 3;
    if (length < 8) score -= 2;

    // Ensure score is between 0 and 10
    score = score.clamp(0, 10);

    // Generate feedback
    if (length < 12) feedback.add('Use at least 12 characters');
    if (!hasUppercase) feedback.add('Add uppercase letters');
    if (!hasLowercase) feedback.add('Add lowercase letters');
    if (!hasDigits) feedback.add('Add numbers');
    if (!hasSymbols) feedback.add('Add symbols');
    if (hasSequential) feedback.add('Avoid sequential patterns');
    if (hasRepeating) feedback.add('Avoid repeating characters');
    if (hasCommonWords) feedback.add('Avoid common words');

    // Determine strength level
    String strength;
    if (score <= 3) {
      strength = 'weak';
    } else if (score <= 6) {
      strength = 'medium';
    } else if (score <= 8) {
      strength = 'strong';
    } else {
      strength = 'excellent';
    }

    return PasswordStrength(
      score: score,
      strength: strength,
      entropy: entropy,
      feedback: feedback.isEmpty ? 'Great password!' : feedback.join(', '),
    );
  }

  /// Hash password using SHA-256 (for breach checking)
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString().toUpperCase();
  }

  /// Check if password appears in common breach list
  bool checkPasswordBreach(String password) {
    // Simplified version - in production, use a local database
    final commonPasswords = [
      'password',
      '123456',
      '12345678',
      'qwerty',
      'abc123',
      'monkey',
      '1234567',
      'letmein',
      'trustno1',
      'dragon',
      'baseball',
      'iloveyou',
      'master',
      'sunshine',
      'ashley',
      'bailey',
      'passw0rd',
      'shadow',
      '123123',
      '654321',
    ];

    return commonPasswords
        .any((common) => password.toLowerCase().contains(common));
  }

  /// Generate a recovery key
  String generateRecoveryKey() {
    final bytes = generateRandomBytes(32);
    return base64Url.encode(bytes);
  }

  /// Securely wipe a byte array from memory
  void secureWipe(Uint8List data) {
    for (var i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }
}

/// Encrypted data container
class EncryptedData {
  final Uint8List data;
  final Uint8List iv;

  EncryptedData({required this.data, required this.iv});
}

/// Password strength analysis result
class PasswordStrength {
  final int score;
  final String strength;
  final double entropy;
  final String feedback;

  PasswordStrength({
    required this.score,
    required this.strength,
    required this.entropy,
    required this.feedback,
  });
}
