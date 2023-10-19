part of 'about_page.dart';

class ProducerText extends StatelessWidget {
  const ProducerText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Lt.of(context).producer, style: subHeading),
        const SizedBox(height: 8),
        const Text('Abilia AB', style: headlineSmall),
        const SizedBox(height: 24),
        const Text('Råsundavägen 6, 169 67 Solna, Sweden', style: heading),
        const SizedBox(height: 24),
        const Text(
          '''+46 (0)8- 594 694 00
info@abilia.com
www.abilia.com''',
          style: heading,
        ),
        const SizedBox(height: 24),
        const Text(
          'This product is developed in accordance with '
          'and complies to all necessary requirements, '
          'regulations and directives for medical devices.',
        ),
      ],
    );
  }
}
