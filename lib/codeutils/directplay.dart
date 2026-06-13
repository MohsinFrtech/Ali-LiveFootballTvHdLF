
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DirectPlay{


 static String generateUserVal(String link, String userBase, String userIp, String defaultString) {
    List<String> separated = link.split("/");
    String streamName = separated[separated.length - 2];
    int startTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int endTime = startTime + 77;
    String sha1 = '$startTime$streamName$userIp$defaultString$endTime';
    sha1 = sHA2(sha1);
    return '$userBase${sHA2(streamName + defaultString + startTime.toString() + userIp)}-$endTime-$startTime';
  }


 static String sHA2(String text) {
     var md = sha256;
     List<int> textBytes = latin1.encode(text);

    // List<int> textBytes = utf8.encode(text);
     Digest sha2hash = md.convert(textBytes);
    return convertToHex(sha2hash.bytes);
  }


 static String convertToHex(List<int> data) {
   StringBuffer buf = StringBuffer();
   for (int b in data) {
     int halfbyte = (b >> 4) & 0x0F;
     int twohalfs = 0;
     do {
       buf.write(
           (halfbyte < 10) ? String.fromCharCode(('0'.codeUnitAt(0) + halfbyte))
            :String.fromCharCode(('a'.codeUnitAt(0) + (halfbyte - 10)))
       );
       halfbyte = b & 0x0F;
     } while (twohalfs++ < 1);
   }
   return buf.toString();
 }


}
