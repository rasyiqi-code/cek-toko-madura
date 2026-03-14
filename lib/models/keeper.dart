class Keeper {
  final String id;
  final String name;

  Keeper({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Keeper.fromJson(Map<String, dynamic> json) => Keeper(
        id: json['id'],
        name: json['name'],
      );
}
