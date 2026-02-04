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
    final base = ['Grade 7 and 8', 'Option 2', 'Option 3'];
    return base.map((o) => '$o ($c)').toList(); // Takes the 'Option 1' and adds the Country Code: ()'CA')
  }

   DateTime _unlockAtFor(String country, String topicName) {
    final c = country.toUpperCase().trim();
    if (c == 'ca' && topicName == 'Grade 7 and 8') {
      return DateTime(2026, 2, 5);
    }
    else {
      return DateTime(2026, 1, 4);
    }
    // if (c == 'US' && topicName == 'Math') return DateTime(2026, 2, 1);
    // return DateTime(2000, 1, 1); // default unlocked
  }

  @override
  Widget build(BuildContext context) {
    final options = _optionsForCountry(country);

    final unlockAt = _unlockAtFor(country, topicName);
    final now = DateTime.now();
    final isLocked = now.isBefore(unlockAt); // calls date function, returns date

    return Scaffold(
      appBar: AppBar(title: const Text('Choose an option')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isLocked)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Locked until ${unlockAt.toLocal()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  return ElevatedButton(
                    onPressed: isLocked
                        ? null
                        : () {
                            // allowed
                            // Navigator.push(...) or whatever
                          },
                    child: Text(options[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
