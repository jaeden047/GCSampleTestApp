// Country code data for phone number dialing codes
class CountryCode {
  final String code;
  final String name;
  final String dialCode;
  final String continent;

  const CountryCode({
    required this.code,
    required this.name,
    required this.dialCode,
    required this.continent,
  });
}

class CountryCodes {
  static final List<CountryCode> codes = [
    // Africa (sorted by dialCode)
    CountryCode(code: 'EG', name: 'Egypt', dialCode: '+20', continent: 'Africa'),
    CountryCode(code: 'ZA', name: 'South Africa', dialCode: '+27', continent: 'Africa'),
    CountryCode(code: 'MA', name: 'Morocco', dialCode: '+212', continent: 'Africa'),
    CountryCode(code: 'NG', name: 'Nigeria', dialCode: '+234', continent: 'Africa'),
    CountryCode(code: 'KE', name: 'Kenya', dialCode: '+254', continent: 'Africa'),

    // Asia (sorted by dialCode)
    CountryCode(code: 'MY', name: 'Malaysia', dialCode: '+60', continent: 'Asia'),
    CountryCode(code: 'ID', name: 'Indonesia', dialCode: '+62', continent: 'Asia'),
    CountryCode(code: 'PH', name: 'Philippines', dialCode: '+63', continent: 'Asia'),
    CountryCode(code: 'SG', name: 'Singapore', dialCode: '+65', continent: 'Asia'),
    CountryCode(code: 'TH', name: 'Thailand', dialCode: '+66', continent: 'Asia'),
    CountryCode(code: 'JP', name: 'Japan', dialCode: '+81', continent: 'Asia'),
    CountryCode(code: 'KR', name: 'South Korea', dialCode: '+82', continent: 'Asia'),
    CountryCode(code: 'VN', name: 'Vietnam', dialCode: '+84', continent: 'Asia'),
    CountryCode(code: 'CN', name: 'China', dialCode: '+86', continent: 'Asia'),
    CountryCode(code: 'TR', name: 'Turkey', dialCode: '+90', continent: 'Asia'),
    CountryCode(code: 'IN', name: 'India', dialCode: '+91', continent: 'Asia'),
    CountryCode(code: 'HK', name: 'Hong Kong', dialCode: '+852', continent: 'Asia'),
    CountryCode(code: 'TW', name: 'Taiwan', dialCode: '+886', continent: 'Asia'),
    CountryCode(code: 'SA', name: 'Saudi Arabia', dialCode: '+966', continent: 'Asia'),
    CountryCode(code: 'AE', name: 'UAE', dialCode: '+971', continent: 'Asia'),
    CountryCode(code: 'IL', name: 'Israel', dialCode: '+972', continent: 'Asia'),

    // Europe (sorted by dialCode)
    CountryCode(code: 'RU', name: 'Russia', dialCode: '+7', continent: 'Europe'),
    CountryCode(code: 'GR', name: 'Greece', dialCode: '+30', continent: 'Europe'),
    CountryCode(code: 'NL', name: 'Netherlands', dialCode: '+31', continent: 'Europe'),
    CountryCode(code: 'BE', name: 'Belgium', dialCode: '+32', continent: 'Europe'),
    CountryCode(code: 'FR', name: 'France', dialCode: '+33', continent: 'Europe'),
    CountryCode(code: 'ES', name: 'Spain', dialCode: '+34', continent: 'Europe'),
    CountryCode(code: 'HU', name: 'Hungary', dialCode: '+36', continent: 'Europe'),
    CountryCode(code: 'IT', name: 'Italy', dialCode: '+39', continent: 'Europe'),
    CountryCode(code: 'RO', name: 'Romania', dialCode: '+40', continent: 'Europe'),
    CountryCode(code: 'CH', name: 'Switzerland', dialCode: '+41', continent: 'Europe'),
    CountryCode(code: 'AT', name: 'Austria', dialCode: '+43', continent: 'Europe'),
    CountryCode(code: 'GB', name: 'United Kingdom', dialCode: '+44', continent: 'Europe'),
    CountryCode(code: 'DK', name: 'Denmark', dialCode: '+45', continent: 'Europe'),
    CountryCode(code: 'SE', name: 'Sweden', dialCode: '+46', continent: 'Europe'),
    CountryCode(code: 'NO', name: 'Norway', dialCode: '+47', continent: 'Europe'),
    CountryCode(code: 'PL', name: 'Poland', dialCode: '+48', continent: 'Europe'),
    CountryCode(code: 'DE', name: 'Germany', dialCode: '+49', continent: 'Europe'),
    CountryCode(code: 'PT', name: 'Portugal', dialCode: '+351', continent: 'Europe'),
    CountryCode(code: 'IE', name: 'Ireland', dialCode: '+353', continent: 'Europe'),
    CountryCode(code: 'FI', name: 'Finland', dialCode: '+358', continent: 'Europe'),
    CountryCode(code: 'BG', name: 'Bulgaria', dialCode: '+359', continent: 'Europe'),
    CountryCode(code: 'LT', name: 'Lithuania', dialCode: '+370', continent: 'Europe'),
    CountryCode(code: 'LV', name: 'Latvia', dialCode: '+371', continent: 'Europe'),
    CountryCode(code: 'EE', name: 'Estonia', dialCode: '+372', continent: 'Europe'),
    CountryCode(code: 'UA', name: 'Ukraine', dialCode: '+380', continent: 'Europe'),
    CountryCode(code: 'HR', name: 'Croatia', dialCode: '+385', continent: 'Europe'),
    CountryCode(code: 'SI', name: 'Slovenia', dialCode: '+386', continent: 'Europe'),
    CountryCode(code: 'CZ', name: 'Czech Republic', dialCode: '+420', continent: 'Europe'),
    CountryCode(code: 'SK', name: 'Slovakia', dialCode: '+421', continent: 'Europe'),

    // North America (sorted by dialCode)
    CountryCode(code: 'CA', name: 'Canada', dialCode: '+1', continent: 'North America'),
    CountryCode(code: 'US', name: 'United States', dialCode: '+1', continent: 'North America'),
    CountryCode(code: 'MX', name: 'Mexico', dialCode: '+52', continent: 'North America'),

    // Oceania (sorted by dialCode)
    CountryCode(code: 'AU', name: 'Australia', dialCode: '+61', continent: 'Oceania'),
    CountryCode(code: 'NZ', name: 'New Zealand', dialCode: '+64', continent: 'Oceania'),

    // South America (sorted by dialCode)
    CountryCode(code: 'PE', name: 'Peru', dialCode: '+51', continent: 'South America'),
    CountryCode(code: 'AR', name: 'Argentina', dialCode: '+54', continent: 'South America'),
    CountryCode(code: 'BR', name: 'Brazil', dialCode: '+55', continent: 'South America'),
    CountryCode(code: 'CL', name: 'Chile', dialCode: '+56', continent: 'South America'),
    CountryCode(code: 'CO', name: 'Colombia', dialCode: '+57', continent: 'South America'),
    CountryCode(code: 'VE', name: 'Venezuela', dialCode: '+58', continent: 'South America'),
  ];

  static CountryCode getDefault() {
    return codes.firstWhere((c) => c.code == 'CA');
  }

  static CountryCode? findByCode(String code) {
    try {
      return codes.firstWhere((c) => c.code == code);
    } catch (e) {
      return null;
    } // This fails for some reason
  }

  static CountryCode? findByDialCode(String dialCode) {
    try {
      return codes.firstWhere((c) => c.dialCode == dialCode);
    } catch (e) {
      return null;
    }
  }

  /// Maps continent (from CountryCode) to region for quiz set assignment.
  /// asia_oceania = Set 1, africa = Set 2, americas = Set 3, europe = Set 4.
  static String continentToRegion(String continent) {
    switch (continent) {
      case 'Africa':
        return 'africa';
      case 'Asia':
      case 'Oceania':
        return 'asia_oceania';
      case 'North America':
      case 'South America':
        return 'americas';
      case 'Europe':
        return 'europe';
      default:
        return 'americas'; // fallback
    }
  }
}

