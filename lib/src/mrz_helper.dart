import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mrz_parser/mrz_parser.dart';

class MRZHelper {

  static Future<MRZResult?> processImage(File image) async {
    try {
      final TextRecognizer _textRecognizer = TextRecognizer();
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
  static List<String>? getFinalListToParse(List<String> ableToScanTextList) {
    if (ableToScanTextList.length < 2) {
      // minimum length of any MRZ format is 2 lines
      return null;
    }
    int lineLength = ableToScanTextList.first.length;
    for (var e in ableToScanTextList) {
      if (e.length != lineLength) {
        return null;
      }
      // to make sure that all lines are the same in length
    }
    List<String> firstLineChars = ableToScanTextList.first.split('');
    List<String> supportedDocTypes = ['A', 'C', 'P', 'V', 'I'];
    String fChar = firstLineChars[0];
    if (supportedDocTypes.contains(fChar)) {
      return [...ableToScanTextList];
    }
    return null;
  }
  static String testTextLine(String text) {
    String res = text.replaceAll(' ', '');
    List<String> list = res.split('');
    List<String> updatedMRZLines = [];

    for (String line in list) {
      if (line.startsWith("P") && line.endsWith("<")) {
        // Line starts with "P" and ends with "<"
        if (line.length < 44) {
          // Length is less than 44, append "<" characters to make it 44
          line = line.padRight(44, "<");
        }
      }
      updatedMRZLines.add(line);
    }
    if(updatedMRZLines.isNotEmpty){
      list = updatedMRZLines;
    }
    // to check if the text belongs to any MRZ format or not
    if (list.length != 44) {
      return '';
    }

    for (int i = 0; i < list.length; i++) {
      if (RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(list[i])) {
        list[i] = list[i].toUpperCase();
        // to ensure that every letter is uppercase
      }
      if (double.tryParse(list[i]) == null &&
          !(RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(list[i]))) {
        list[i] = '<';
        // sometimes < sign not recognized well
      }
    }
    String result = list.join('');
    return result;
  }

  // static String testTextLine(String text) {
  //   String res = text.replaceAll(' ', '');
  //   List<String> list = res.split('');
  //
  //   // to check if the text belongs to any MRZ format or not
  //   if (list.length != 44 && list.length != 30 && list.length != 36) {
  //     return '';
  //   }
  //
  //   for (int i = 0; i < list.length; i++) {
  //     if (RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(list[i])) {
  //       list[i] = list[i].toUpperCase();
  //       // to ensure that every letter is uppercase
  //     }
  //     if (double.tryParse(list[i]) == null &&
  //         !(RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(list[i]))) {
  //       list[i] = '<';
  //       // sometimes < sign not recognized well
  //     }
  //   }
  //   String result = list.join('');
  //   return result;
  // }
}
