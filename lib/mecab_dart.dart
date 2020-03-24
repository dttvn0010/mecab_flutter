import 'dart:async';
import 'package:flutter/services.dart';

import 'dart:ffi'; 
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

typedef initMecabFunc = Pointer<Void> Function(Pointer<Utf8> options, Pointer<Utf8> dicdir);
typedef parseFunc = Pointer<Utf8> Function(Pointer<Void> m, Pointer<Utf8> input);
typedef destroyMecabFunc = Void Function(Pointer<Void> mecab);
typedef destroyMecab_func = void Function(Pointer<Void> mecab);

final DynamicLibrary mecabDartLib = Platform.isAndroid
    ? DynamicLibrary.open("libmecab_dart.so")
    : DynamicLibrary.process();

final initMecabPointer = mecabDartLib.lookup<NativeFunction<initMecabFunc>>('initMecab');
final initMecabFfi = initMecabPointer.asFunction<initMecabFunc>();

final parsePointer = mecabDartLib.lookup<NativeFunction<parseFunc>>('parse');
final parseFfi = parsePointer.asFunction<parseFunc>();

final destroyMecabPointer = mecabDartLib.lookup<NativeFunction<destroyMecabFunc>>('destroyMecab');
final destroyMecabFfi = destroyMecabPointer.asFunction<destroyMecab_func>();

class Mecab {
  Pointer<Void> mecabPtr;
  
  Future<void> copyFile(String dicdir, String assetDicDir, String fileName) async {    
    if(FileSystemEntity.typeSync('$dicdir/$fileName') == FileSystemEntityType.notFound) {
      var data = (await rootBundle.load('$assetDicDir/$fileName'));
      var buffer = data.buffer;
      var bytes = buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      new File('$dicdir/$fileName').writeAsBytesSync(bytes);
    }
  }

  Future<void> init(String assetDicDir, String options) async {
    var dir = (await getApplicationDocumentsDirectory()).path;  
    var dicdir = "$dir/ipadic";
    var mecabrc = '$dicdir/mecabrc';
    
    if(FileSystemEntity.typeSync(mecabrc) == FileSystemEntityType.notFound) {
      // Create new mecabrc file
      var mecabrcFile = await(new File(mecabrc).create(recursive: true));
      mecabrcFile.writeAsStringSync("");
    }

    // Copy dictionary from asset folder to App Document folder
    await copyFile(dicdir, assetDicDir, 'char.bin');
    await copyFile(dicdir, assetDicDir, 'dicrc');
    await copyFile(dicdir, assetDicDir, 'left-id.def');
    await copyFile(dicdir, assetDicDir, 'matrix.bin');
    await copyFile(dicdir, assetDicDir, 'pos-id.def');
    await copyFile(dicdir, assetDicDir, 'rewrite.def');
    await copyFile(dicdir, assetDicDir, 'right-id.def');
    await copyFile(dicdir, assetDicDir, 'sys.dic');
    await copyFile(dicdir, assetDicDir, 'unk.dic');

    mecabPtr = initMecabFfi(Utf8.toUtf8(options), Utf8.toUtf8(dicdir));
  }

  String parse(String input) {
    if(mecabPtr != null) {
      return Utf8.fromUtf8(parseFfi(mecabPtr, Utf8.toUtf8(input)));
    }
    return "";
  }

  void destroy() {
    if(mecabPtr != null) {
      destroyMecabFfi(mecabPtr);
    }
  }
}

final int Function(int x, int y) nativeAdd =
  mecabDartLib
    .lookup<NativeFunction<Int32 Function(Int32, Int32)>>("native_add")
    .asFunction();
    
class MecabDart {
  static const MethodChannel _channel =
      const MethodChannel('mecab_dart');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
