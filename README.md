# mecab_dart

MeCab(Japanese Morphological Analyzer) wrapper for Flutter on iOS/Android.

```dart
var tagger = new Mecab();
await tagger.init("assets/ipadic", true);

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


