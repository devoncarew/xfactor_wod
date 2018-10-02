import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;

class Wod {
  // Foundations 9/20/2018
  final String title;

  // CrossFit X Factor – Foundations Metcon (Time) 3 x 400m Run, 500m Row
  final String description;

  // September 20, 2018
  final String date;

  // Workouts
  final String category;

  final String url;

  Wod({this.title, this.description, this.date, this.category, this.url});

  String toString() => '$title: $description';
}

class WodManager {
  static const String gymPrefix = 'CrossFit X Factor – ';

  http.Client client;

  WodManager() {
    client = new http.Client();
  }

  Future<List<Wod>> retrieveWods() async {
    final http.Response response =
        await client.get('https://crossfitxfactor.com/blog/');

    if (response.statusCode != 200) {
      throw '${response.statusCode} ${response.reasonPhrase}';
    }

    dom.Document doc = html.parse(response.body);

    List<dom.Element> elements = doc.querySelectorAll('div.post-details');

    return elements.map((dom.Element element) {
      dom.Element first = element.children.first;
      dom.Element a = first.querySelector('a');

      dom.Element second = element.children[1];
      dom.Element p = second.querySelector('p');

      dom.Element third = element.children[2];

      dom.Element fourth = element.children[3];
      dom.Element category = fourth.querySelector('a');

      String description = p.text.trim();

      if (description.startsWith(gymPrefix)) {
        description = description.substring(gymPrefix.length).trim();
      }

      description = description
          .split(gymPrefix)
          .map((String str) => str.trim())
          .join(('\n\n'));

      return new Wod(
        title: a.text.trim(),
        description: description,
        date: third.text.trim(),
        category: category.text.trim(),
        url: a.attributes['href'],
      );
    }).toList();
  }
}
