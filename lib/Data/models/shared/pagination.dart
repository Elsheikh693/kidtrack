class Pagination {
  final int currentPage;
  final int from;
  final int lastPage;
  final int perPage;
  final int to;
  final int total;

  const Pagination({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.perPage,
    required this.to,
    required this.total,
  });

  bool get hasNextPage => currentPage < lastPage;

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 0,
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      perPage: json['per_page'] ?? 0,
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'from': from,
        'last_page': lastPage,
        'per_page': perPage,
        'to': to,
        'total': total,
      };
}

class PaginationLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  const PaginationLinks({this.first, this.last, this.prev, this.next});

  factory PaginationLinks.fromJson(Map<String, dynamic> json) {
    return PaginationLinks(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (first != null) 'first': first,
        if (last != null) 'last': last,
        if (prev != null) 'prev': prev,
        if (next != null) 'next': next,
      };
}
