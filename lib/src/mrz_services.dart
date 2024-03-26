import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mrz_parser/mrz_parser.dart';
import 'mrz_helper.dart';

class MRZScannerService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  Future<MRZResult?> _parseScannedText(List<String> lines) async {
    try {
      final data = MRZParser.parse(lines);
      return data;
    } catch (e) {
      print('error i got is ${e}');
    }
  }

  Future<MRZResult?> processImage(File image) async {
    try {
      InputImage inputImg = InputImage.fromFile(image);
      await _textRecognizer.processImage(inputImg);
      final recognisedText =await _textRecognizer.processImage(inputImg);
      String fullText = recognisedText.text;
      String trimmedText = fullText.replaceAll(' ', '');
      List allText = trimmedText.split('\n');
      List<String> ableToScanText = [];
      for (var e in allText) {
        if (MRZHelper.testTextLine(e).isNotEmpty) {
          ableToScanText.add(MRZHelper.testTextLine(e));
        }
      }
      List<String>? result = MRZHelper.getFinalListToParse([...ableToScanText]);
      if (result != null) {

        return MRZParser.parse(result);
      } else {
        return null;
      }
    } catch (e) {
      print('Error processing image: $e');
      return null;
    }
  }
}