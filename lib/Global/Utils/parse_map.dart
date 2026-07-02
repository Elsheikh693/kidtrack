List<T?> handleResponse<T>(
    dynamic response, T Function(Map<String, dynamic>) fromJson) {
  final dataresponse = response;

  List<T?> itemList = [];

  if (dataresponse is List) {
    final List<dynamic> responseList = dataresponse;
    itemList = responseList
        .map((dynamic item) {
      if (item != null) {
        return fromJson(item);
      }
      return null;
    })
        .where((item) => item != null)
        .toList();
  } else if (dataresponse is Map) {
    if (dataresponse.isEmpty) {
      return [];
    }
    // Handle the case where the response is a non-empty Map
    final Map<dynamic, dynamic> responseMap = dataresponse;
    responseMap.forEach((key, itemData) {
      if (itemData is Map<String, dynamic>) {
        itemList.add(fromJson(itemData));
      }
    });
  } else {
  }

  return itemList;
}
