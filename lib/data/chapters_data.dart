import 'package:flutter/services.dart' show rootBundle;
import '../models/chapter.dart';

final List<Chapter> chapters = [
  Chapter(
    id: 'vinayagar_worship',
    title: 'விநாயகர் வழிபாட்டு முறைகள்',
    assetPath: 'assets/chapters/வழிபாட்டு_முறைகள்.txt',
  ),
  Chapter(
    id: 'vinayagar_slokam',
    title: 'விநாயகர் ஸ்லோகம்',
    assetPath: 'assets/chapters/விநாயகர்_ஸ்லோகம்.txt',
  ),
  Chapter(
    id: 'kaariyasiddhi_malai',
    title: 'காரியசித்தி மாலை',
    assetPath: 'assets/chapters/காரியசித்தி.txt',
  ),
  Chapter(
    id: 'sankata_nashana_stotram',
    title: 'சங்கட நாசன ஸ்ரீ கணேச ஸ்தோத்ரம்',
    assetPath: 'assets/chapters/சங்கட_நாசன.txt',
  ),
  Chapter(
    id: 'ganesa_pancharatnam',
    title: 'கணேச பஞ்சரத்னம்',
    assetPath: 'assets/chapters/கணேச_பஞ்சரத்னம்.txt',
  ),
  Chapter(
    id: 'ganesa_sahasra_namaavali',
    title: 'கணேச ஸஹஸ்ர நாமாவளி',
    assetPath: 'assets/chapters/கணேச_நாமாவளி.txt',
  ),
  Chapter(
    id: 'vinayagar_in_literature',
    title: 'இலக்கியங்களில் வினாயகர்',
    assetPath: 'assets/chapters/இலக்கியங்கள்.txt',
  ),
  Chapter(
    id: 'vinayagar_agaval',
    title: 'விநாயகர் அகவல்',
    assetPath: 'assets/chapters/விநாயகர்_அகவல்.txt',
  ),
  Chapter(
    id: 'vinayagar_ashtothram',
    title: 'விநாயகர் அஷ்டோத்திரம்',
    assetPath: 'assets/chapters/விநாயகர்_அஷ்டோத்திரம்.txt',
  ),
  Chapter(
    id: 'ganapathi_suktham',
    title: 'கணபதி ஸுக்தம்',
    assetPath: 'assets/chapters/கணபதி_ஸுக்தம்.txt',
  ),
  Chapter(
    id: 'ganesa_ashtakam',
    title: 'கணேச அஷ்டகம்',
    assetPath: 'assets/chapters/கணேச_அஷ்டகம்.txt',
  ),
  Chapter(
    id: 'ganesa_bhujangam',
    title: 'கணேச புஜங்கம்',
    assetPath: 'assets/chapters/கணேச_புஜங்கம்.txt',
  ),
  Chapter(
    id: 'ganesa_kavacham',
    title: 'கணேச கவசம்',
    assetPath: 'assets/chapters/கணேச_கவசம்.txt',
  ),
  Chapter(
    id: 'sakala_dhoshangal',
    title: 'சகல தோஷங்களும் போக்கும் விநாயகர் வழிபாடு',
    assetPath: 'assets/chapters/சகல_தோஷங்கள்.txt',
  ),
  Chapter(
    id: 'thiruirattai_manimalai',
    title: 'திருஇரட்டை மணிமாலை',
    assetPath: 'assets/chapters/திருஇரட்டை_மணிமாலை.txt',
  ),
  Chapter(
    id: 'thirumummanikovai',
    title: 'திருமும்மணிக்கோவை',
    assetPath: 'assets/chapters/திருமும்மணிக்கோவை.txt',
  ),
  Chapter(
    id: 'pancharathna_stotram',
    title: 'பஞ்சரத்ந ஸ்தோத்ரம்',
    assetPath: 'assets/chapters/பஞ்சரத்ந_ஸ்தோத்ரம்.txt',
  ),
  Chapter(
    id: 'ucchishta_ganapathi',
    title: 'உச்சிஷ்ட கணபதி',
    assetPath: 'assets/chapters/உச்சிஷ்ட_கணபதி.txt',
  ),
  Chapter(
    id: 'vinayagar_purana',
    title: 'விநாயகர் புராணம்',
    assetPath: 'assets/chapters/விநாயகர் புராணம்.txt',
    subchapters: [
      Subchapter(title: 'பகுதி 1'),
      Subchapter(title: 'பகுதி 2'),
      Subchapter(title: 'பகுதி 3'),
      Subchapter(title: 'பகுதி 4'),
      Subchapter(title: 'பகுதி 5'),
      Subchapter(title: 'பகுதி 6'),
      Subchapter(title: 'பகுதி 7'),
      Subchapter(title: 'பகுதி 8'),
      Subchapter(title: 'பகுதி 9'),
      Subchapter(title: 'பகுதி 10'),
      Subchapter(title: 'பகுதி 11'),
      Subchapter(title: 'பகுதி 12'),
      Subchapter(title: 'பகுதி 13'),
      Subchapter(title: 'பகுதி 14'),
      Subchapter(title: 'பகுதி 15'),
      Subchapter(title: 'பகுதி 16'),
      Subchapter(title: 'பகுதி 17'),
      Subchapter(title: 'பகுதி 18'),
      Subchapter(title: 'பகுதி 19'),
      Subchapter(title: 'பகுதி 20'),
      Subchapter(title: 'பகுதி 21'),
      Subchapter(title: 'பகுதி 22'),
      Subchapter(title: 'பகுதி 23'),
      Subchapter(title: 'பகுதி 24'),
      Subchapter(title: 'பகுதி 25'),
      Subchapter(title: 'பகுதி 26'),
    ],
  ),
];

Future<void> loadChapterContent(Chapter chapter) async {
  chapter.content ??= await rootBundle.loadString(chapter.assetPath);
}
