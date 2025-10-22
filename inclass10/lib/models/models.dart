class Folder {
  final int id;
  final String name;
  final DateTime createdAt;
  int cardCount;
  String? previewImage;

  Folder({
    required this.id,
    required this.name,
    required this.createdAt,
    this.cardCount = 0,
    this.previewImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'],
      name: map['name'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class PlayingCard {
  final int id;
  final String name;
  final String suit;
  final String? imageUrl;
  final int? folderId;
  final DateTime createdAt;

  PlayingCard({
    required this.id,
    required this.name,
    required this.suit,
    this.imageUrl,
    this.folderId,
    required this.createdAt,
  });

  String get fullName => '$name of $suit';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'suit': suit,
      'image_url': imageUrl,
      'folder_id': folderId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PlayingCard.fromMap(Map<String, dynamic> map) {
    return PlayingCard(
      id: map['id'],
      name: map['name'],
      suit: map['suit'],
      imageUrl: map['image_url'],
      folderId: map['folder_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}