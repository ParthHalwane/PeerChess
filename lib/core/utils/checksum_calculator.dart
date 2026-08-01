import 'dart:convert';

class ChecksumCalculator {
  static String calculate(Map<String, dynamic> data) {
    Map<String, dynamic> cleanData = Map.from(data);
    cleanData.remove('checksum');
    
    List<String> sortedKeys = cleanData.keys.toList()..sort();
    StringBuffer buffer = StringBuffer();
    for (var key in sortedKeys) {
      buffer.write('$key:${cleanData[key]}|');
    }
    
    List<int> bytes = utf8.encode(buffer.toString());
    int hash = 5381;
    for (int b in bytes) {
      hash = ((hash << 5) + hash) + b;
      hash = hash & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }

  static bool verify(Map<String, dynamic> data) {
    if (!data.containsKey('checksum') || data['checksum'] == null) {
      return true;
    }
    String expectedChecksum = data['checksum'].toString();
    String calculatedChecksum = calculate(data);
    return expectedChecksum == calculatedChecksum;
  }
}
