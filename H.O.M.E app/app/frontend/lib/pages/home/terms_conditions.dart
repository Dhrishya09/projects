import 'package:flutter/material.dart';


class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms And Privacy Policy'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader("1. Introduction"),
            ParagraphText(
                "Welcome to H.O.M.E app. We value your privacy and are committed to protecting your personal data in accordance with the Dubai Data Law (Dubai Law No. 26 of 2015) and the UAE Personal Data Protection Law (PDPL)."),

            SectionHeader("2. Data Collection and Use"),
            ParagraphText(
                "In compliance with Article 8 of the Dubai Data Law, we ensure transparency in data collection. We collect personal data for specific purposes, including but not limited to:"),
            BulletPointList([
              "Providing services and customer support",
              "Processing transactions and payments",
              "Enhancing user experience and security",
              "Compliance with legal obligations",
            ]),

            SectionHeader("3. User Rights"),
            ParagraphText(
                "Under the Dubai Data Law, individuals have the right to:"),
            BulletPointList([
              "Be informed about the collection and use of their data",
              "Access their personal data upon request",
              "Request corrections or deletion of inaccurate data",
            ]),

            SectionHeader("4. Data Processing Principles"),
            ParagraphText("As per Article 5 of the PDPL, we adhere to the following principles:"),
            BulletPointList([
              "Transparency: We disclose the type of data collected and its intended use.",
              "Accountability: We ensure secure and responsible data processing practices.",
              "Consent: Where applicable, we obtain explicit consent before processing sensitive data.",
            ]),

            SectionHeader("5. Sensitive Data Handling"),
            ParagraphText(
                "We comply with UAE regulations when handling sensitive data, including racial or ethnic origin, political opinions, religious beliefs, and health data. Explicit consent is required before processing such information."),

            SectionHeader("6. Data Minimization"),
            ParagraphText(
                "Following Article 7 of the PDPL, we only collect data that is necessary for the specified purposes, ensuring minimal data collection and storage."),

            SectionHeader("7. Data Security"),
            ParagraphText(
                "We implement industry-standard security measures to protect user data from unauthorized access, alteration, or disclosure."),

            SectionHeader("8. Third-Party Sharing"),
            ParagraphText(
                "We do not sell, rent, or share personal data with third parties without user consent, except when required by law."),

            SectionHeader("9. Updates to This Policy"),
            ParagraphText(
                "We may update this policy periodically. Users will be notified of significant changes through our website or other communication channels."),

            SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255,96,125,139),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// **Reusable Widget for Section Headers**
class SectionHeader extends StatelessWidget {
  final String text;
  const SectionHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// **Reusable Widget for Paragraph Text**
class ParagraphText extends StatelessWidget {
  final String text;
  const ParagraphText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

/// **Reusable Widget for Bullet Point Lists**
class BulletPointList extends StatelessWidget {
  final List<String> items;
  const BulletPointList(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
