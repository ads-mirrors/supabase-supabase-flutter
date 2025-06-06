import 'package:gotrue/gotrue.dart';

class AuthMFAEnrollResponse {
  /// ID of the factor that was just enrolled (in an unverified state).
  final String id;

  /// Type of MFA factor. Supports both `[FactorType.totp]` and `[FactorType.phone]`.
  final FactorType type;

  /// TOTP enrollment information (only present when type is totp).
  final TOTPEnrollment? totp;

  /// Phone enrollment information (only present when type is phone).
  final PhoneEnrollment? phone;

  const AuthMFAEnrollResponse({
    required this.id,
    required this.type,
    this.totp,
    this.phone,
  });

  factory AuthMFAEnrollResponse.fromJson(Map<String, dynamic> json) {
    final type = FactorType.values.firstWhere((e) => e.name == json['type']);
    return AuthMFAEnrollResponse(
      id: json['id'],
      type: type,
      totp: type == FactorType.totp && json['totp'] != null
          ? TOTPEnrollment.fromJson(json['totp'])
          : null,
      phone: type == FactorType.phone && json['phone'] != null
          ? PhoneEnrollment._fromJsonValue(json['phone'])
          : null,
    );
  }
}

class TOTPEnrollment {
  ///Contains a QR code encoding the authenticator URI.
  ///
  ///You can convert it to a URL by prepending `data:image/svg+xml;utf-8,` to the value. Avoid logging this value to the console.
  final String qrCode;

  ///The TOTP secret (also encoded in the QR code).
  ///
  ///Show this secret in a password-style field to the user, in case they are unable to scan the QR code. Avoid logging this value to the console.
  final String secret;

  ///The authenticator URI encoded within the QR code, should you need to use it. Avoid logging this value to the console.
  final String uri;

  const TOTPEnrollment({
    required this.qrCode,
    required this.secret,
    required this.uri,
  });

  factory TOTPEnrollment.fromJson(Map<String, dynamic> json) {
    return TOTPEnrollment(
      qrCode: json['qr_code'],
      secret: json['secret'],
      uri: json['uri'],
    );
  }
}

class PhoneEnrollment {
  /// The phone number that will receive the SMS OTP.
  final String phone;

  const PhoneEnrollment({
    required this.phone,
  });

  factory PhoneEnrollment.fromJson(Map<String, dynamic> json) {
    return PhoneEnrollment(
      phone: json['phone'],
    );
  }

  factory PhoneEnrollment._fromJsonValue(dynamic value) {
    if (value is String) {
      // Server returns phone number as a string directly
      return PhoneEnrollment(phone: value);
    } else if (value is Map<String, dynamic>) {
      // Server returns phone data as an object
      return PhoneEnrollment.fromJson(value);
    } else {
      throw ArgumentError(
          'Invalid phone enrollment data type: ${value.runtimeType}');
    }
  }
}

class AuthMFAChallengeResponse {
  /// ID of the newly created challenge.
  final String id;

  /// Timestamp when this challenge will no longer be usable.
  final DateTime expiresAt;

  const AuthMFAChallengeResponse({required this.id, required this.expiresAt});

  factory AuthMFAChallengeResponse.fromJson(Map<String, dynamic> json) {
    return AuthMFAChallengeResponse(
      id: json['id'],
      expiresAt: DateTime.fromMillisecondsSinceEpoch(json['expires_at'] * 1000),
    );
  }
}

class AuthMFAVerifyResponse {
  /// New access token (JWT) after successful verification.
  final String accessToken;

  /// Type of token, typically `Bearer`.
  final String tokenType;

  /// Duration in which the access token will expire.
  final Duration expiresIn;

  /// Refresh token you can use to obtain new access tokens when expired.
  final String refreshToken;

  /// Updated user profile.
  final User user;

  const AuthMFAVerifyResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
    required this.user,
  });

  factory AuthMFAVerifyResponse.fromJson(Map<String, dynamic> json) {
    return AuthMFAVerifyResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      expiresIn: Duration(seconds: json['expires_in']),
      refreshToken: json['refresh_token'],
      user: User.fromJson(json['user'])!,
    );
  }
}

class AuthMFAUnenrollResponse {
  /// ID of the factor that was successfully unenrolled.
  final String id;

  const AuthMFAUnenrollResponse({required this.id});

  factory AuthMFAUnenrollResponse.fromJson(Map<String, dynamic> json) {
    return AuthMFAUnenrollResponse(id: json['id']);
  }
}

class AuthMFAListFactorsResponse {
  final List<Factor> all;
  final List<Factor> totp;
  final List<Factor> phone;

  AuthMFAListFactorsResponse({
    required this.all,
    required this.totp,
    required this.phone,
  });
}

class AuthMFAAdminListFactorsResponse {
  /// All factors attached to the user.
  final List<Factor> factors;

  const AuthMFAAdminListFactorsResponse({required this.factors});

  factory AuthMFAAdminListFactorsResponse.fromJson(Map<String, dynamic> json) {
    return AuthMFAAdminListFactorsResponse(
      factors:
          (json['factors'] as List).map((e) => Factor.fromJson(e)).toList(),
    );
  }
}

class AuthMFAAdminDeleteFactorResponse {
  /// ID of the factor that was successfully deleted.
  final String id;

  const AuthMFAAdminDeleteFactorResponse({required this.id});

  factory AuthMFAAdminDeleteFactorResponse.fromJson(Map<String, dynamic> json) {
    return AuthMFAAdminDeleteFactorResponse(id: json['id']);
  }
}

enum FactorStatus { verified, unverified }

enum FactorType { totp, phone }

class Factor {
  /// ID of the factor.
  final String id;

  /// Friendly name of the factor, useful to disambiguate between multiple factors.
  final String? friendlyName;

  /// Type of factor. Supports both `totp` and `phone`.
  final FactorType factorType;

  /// Factor's status.
  final FactorStatus status;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Factor({
    required this.id,
    required this.friendlyName,
    required this.factorType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Factor.fromJson(Map<String, dynamic> json) {
    return Factor(
      id: json['id'],
      friendlyName: json['friendly_name'],
      factorType: FactorType.values.firstWhere(
        (e) => e.name == json['factor_type'],
      ),
      status: FactorStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'friendly_name': friendlyName,
      'factor_type': factorType.name,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Factor &&
        other.id == id &&
        other.friendlyName == friendlyName &&
        other.factorType == factorType &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        friendlyName.hashCode ^
        factorType.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

enum AuthenticatorAssuranceLevels {
  // The user's identity has been verified only with a conventional login (email+password, OTP, magic link, social login, etc.).
  aal1,

  // The user's identity has been verified both with a conventional login and at least one MFA factor.
  aal2,
}

class AuthMFAGetAuthenticatorAssuranceLevelResponse {
  /// Current AAL level of the session.
  final AuthenticatorAssuranceLevels? currentLevel;

  /// Next possible AAL level for the session. If the next level is higher than the current one, the user should go through MFA.
  ///
  /// see [GoTrueMFAApi.challenge]
  final AuthenticatorAssuranceLevels? nextLevel;

  /// A list of all authentication methods attached to this session.
  ///
  /// Use the information here to detect the last time a user verified a factor, for example if implementing a step-up scenario.
  final List<AMREntry> currentAuthenticationMethods;

  const AuthMFAGetAuthenticatorAssuranceLevelResponse({
    required this.currentLevel,
    required this.nextLevel,
    required this.currentAuthenticationMethods,
  });
}

enum AMRMethod {
  password('password'),
  otp('otp'),
  oauth('oauth'),
  totp('totp'),
  magiclink('magiclink'),
  recovery('recovery'),
  invite('invite'),
  ssoSaml('sso/saml'),
  emailSignUp('email/signup'),
  emailChange('email_change'),
  tokenRefresh('token_refresh'),
  anonymous('anonymous'),
  mfaPhone('mfa/phone'),
  unknown('unknown');

  final String code;
  const AMRMethod(this.code);
}

/// An authentication method reference (AMR) entry.
///
/// An entry designates what method was used by the user to verify their
/// identity and at what time.
///
/// see [GoTrueMFAApi.getAuthenticatorAssuranceLevel].
///
class AMREntry {
  /// authentication method name
  final AMRMethod method;

  /// Timestamp when the method was successfully used.
  final DateTime timestamp;

  const AMREntry({required this.method, required this.timestamp});

  factory AMREntry.fromJson(Map<String, dynamic> json) {
    return AMREntry(
      method: AMRMethod.values.firstWhere(
        (e) => e.code == json['method'],
        orElse: () => AMRMethod.unknown,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] * 1000),
    );
  }
}
