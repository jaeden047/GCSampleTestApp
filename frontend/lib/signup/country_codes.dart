// Country code data for phone number dialing codes
class CountryCode {
  final String code;
  final String name;
  final String dialCode;

  const CountryCode({
    required this.code,
    required this.name,
    required this.dialCode,
  });
}

class CountryCodes {
  static final List<CountryCode> codes = [
    CountryCode(code: 'US', name: 'United States', dialCode: '+1'),
    CountryCode(code: 'CA', name: 'Canada', dialCode: '+1'),
    CountryCode(code: 'GB', name: 'United Kingdom', dialCode: '+44'),
    CountryCode(code: 'AU', name: 'Australia', dialCode: '+61'),
    CountryCode(code: 'DE', name: 'Germany', dialCode: '+49'),
    CountryCode(code: 'FR', name: 'France', dialCode: '+33'),
    CountryCode(code: 'IT', name: 'Italy', dialCode: '+39'),
    CountryCode(code: 'ES', name: 'Spain', dialCode: '+34'),
    CountryCode(code: 'NL', name: 'Netherlands', dialCode: '+31'),
    CountryCode(code: 'BE', name: 'Belgium', dialCode: '+32'),
    CountryCode(code: 'CH', name: 'Switzerland', dialCode: '+41'),
    CountryCode(code: 'AT', name: 'Austria', dialCode: '+43'),
    CountryCode(code: 'SE', name: 'Sweden', dialCode: '+46'),
    CountryCode(code: 'NO', name: 'Norway', dialCode: '+47'),
    CountryCode(code: 'DK', name: 'Denmark', dialCode: '+45'),
    CountryCode(code: 'FI', name: 'Finland', dialCode: '+358'),
    CountryCode(code: 'PL', name: 'Poland', dialCode: '+48'),
    CountryCode(code: 'IE', name: 'Ireland', dialCode: '+353'),
    CountryCode(code: 'PT', name: 'Portugal', dialCode: '+351'),
    CountryCode(code: 'GR', name: 'Greece', dialCode: '+30'),
    CountryCode(code: 'CZ', name: 'Czech Republic', dialCode: '+420'),
    CountryCode(code: 'HU', name: 'Hungary', dialCode: '+36'),
    CountryCode(code: 'RO', name: 'Romania', dialCode: '+40'),
    CountryCode(code: 'BG', name: 'Bulgaria', dialCode: '+359'),
    CountryCode(code: 'HR', name: 'Croatia', dialCode: '+385'),
    CountryCode(code: 'SK', name: 'Slovakia', dialCode: '+421'),
    CountryCode(code: 'SI', name: 'Slovenia', dialCode: '+386'),
    CountryCode(code: 'LT', name: 'Lithuania', dialCode: '+370'),
    CountryCode(code: 'LV', name: 'Latvia', dialCode: '+371'),
    CountryCode(code: 'EE', name: 'Estonia', dialCode: '+372'),
    CountryCode(code: 'JP', name: 'Japan', dialCode: '+81'),
    CountryCode(code: 'CN', name: 'China', dialCode: '+86'),
    CountryCode(code: 'KR', name: 'South Korea', dialCode: '+82'),
    CountryCode(code: 'IN', name: 'India', dialCode: '+91'),
    CountryCode(code: 'SG', name: 'Singapore', dialCode: '+65'),
    CountryCode(code: 'MY', name: 'Malaysia', dialCode: '+60'),
    CountryCode(code: 'TH', name: 'Thailand', dialCode: '+66'),
    CountryCode(code: 'PH', name: 'Philippines', dialCode: '+63'),
    CountryCode(code: 'ID', name: 'Indonesia', dialCode: '+62'),
    CountryCode(code: 'VN', name: 'Vietnam', dialCode: '+84'),
    CountryCode(code: 'TW', name: 'Taiwan', dialCode: '+886'),
    CountryCode(code: 'HK', name: 'Hong Kong', dialCode: '+852'),
    CountryCode(code: 'NZ', name: 'New Zealand', dialCode: '+64'),
    CountryCode(code: 'BR', name: 'Brazil', dialCode: '+55'),
    CountryCode(code: 'MX', name: 'Mexico', dialCode: '+52'),
    CountryCode(code: 'AR', name: 'Argentina', dialCode: '+54'),
    CountryCode(code: 'CL', name: 'Chile', dialCode: '+56'),
    CountryCode(code: 'CO', name: 'Colombia', dialCode: '+57'),
    CountryCode(code: 'PE', name: 'Peru', dialCode: '+51'),
    CountryCode(code: 'VE', name: 'Venezuela', dialCode: '+58'),
    CountryCode(code: 'ZA', name: 'South Africa', dialCode: '+27'),
    CountryCode(code: 'EG', name: 'Egypt', dialCode: '+20'),
    CountryCode(code: 'NG', name: 'Nigeria', dialCode: '+234'),
    CountryCode(code: 'KE', name: 'Kenya', dialCode: '+254'),
    CountryCode(code: 'MA', name: 'Morocco', dialCode: '+212'),
    CountryCode(code: 'AE', name: 'UAE', dialCode: '+971'),
    CountryCode(code: 'SA', name: 'Saudi Arabia', dialCode: '+966'),
    CountryCode(code: 'IL', name: 'Israel', dialCode: '+972'),
    CountryCode(code: 'TR', name: 'Turkey', dialCode: '+90'),
    CountryCode(code: 'RU', name: 'Russia', dialCode: '+7'),
    CountryCode(code: 'UA', name: 'Ukraine', dialCode: '+380'),
  ];

  static CountryCode getDefault() {
    return codes.firstWhere((c) => c.code == 'CA');
  }

  static CountryCode? findByCode(String code) {
    try {
      return codes.firstWhere((c) => c.code == code);
    } catch (e) {
      return null;
    }
  }

  static CountryCode? findByDialCode(String dialCode) {
    try {
      return codes.firstWhere((c) => c.dialCode == dialCode);
    } catch (e) {
      return null;
    }
  }
}

