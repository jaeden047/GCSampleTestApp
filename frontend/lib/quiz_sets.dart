import 'package:flutter/material.dart';

class CountryMenuPage extends StatelessWidget {
  final String country;   
  final String topicName; 

  const CountryMenuPage({
    super.key,
    required this.country,
    required this.topicName,
  });

  List<String> _optionsForCountry(String country) {
    final c = country.toLowerCase().trim();

    
    // When you decide real per-country options later, put them here:
    // final map = <String, List<String>>{
    //   'CA': ['Option A', 'Option B', 'Option C'],
    //   'US': ['Option A', 'Option B', 'Option C'],
    // };
    // final base = map[c] ?? ['Option 1', 'Option 2', 'Option 3'];

    // For now: generic list, always suffix with the code
    final base = ['Option 1', 'Option 2', 'Option 3'];
    return base.map((o) => '$o ($c)').toList(); // Takes the 'Option 1' and adds the Country Code: ()'CA')
  }

  @override
  Widget build(BuildContext context) {
    final options = _optionsForCountry(country);

    return Scaffold(
      appBar: AppBar(title: Text('Choose an option')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          return ElevatedButton(
            onPressed: () {
              // TODO: handle option selection
              // e.g. Navigator.push(...) to next page, or pop with result:
              // Navigator.pop(context, options[i]);
            },
            child: Text(options[i]),
          );
        },
      ),
    );
  }
}
