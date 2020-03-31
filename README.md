# mecab_dart

MeCab(Japanese Morphological Analyzer) wrapper for Flutter on iOS/Android.

#Usage
Add this plug_in `mecab_flutter` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

Copy Mecab dictionary (ipadic) to your assets folder

### Example

Init the tagger:

```dart
var tagger = new Mecab();
await tagger.init("assets/ipadic", true);
```
Set the boolean option in `init` function to true if you want to get the tokens including features,
set it to false if you only want the token surfaces.


Use the tagger to parse text:

```dart
var tokens = tagger.parse('にわにわにわにわとりがいる。');
var text = '';

for(var token in tokens) {
  text += token.surface + "\t";
  for(var i = 0; i < token.features.length; i++) {
    text += token.features[i];
    if(i + 1 < token.features.length) {
	  text += ",";
    }
  }
  text += "\n";
}
```