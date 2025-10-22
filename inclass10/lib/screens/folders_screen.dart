import 'package:flutter/material.dart';
import 'package:inclass10/database_helper.dart';
import 'package:inclass10/models/models.dart';
import 'package:inclass10/screens/cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Folder> _folders = [];
  Map<int, int> _folderCardCounts = {};

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final folderMaps = await _dbHelper.getFolders();
    final folders = folderMaps.map((map) => Folder.fromMap(map)).toList();

    // Get card counts for each folder
    for (final folder in folders) {
      final count = await _dbHelper.getCardCountInFolder(folder.id);
      _folderCardCounts[folder.id] = count;
    }

    setState(() {
      _folders = folders;
    });
  }

  void _showRenameFolderDialog(Folder folder) {
    TextEditingController controller = TextEditingController(text: folder.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter folder name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _dbHelper.updateFolder(folder.id, controller.text);
                _loadFolders();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteFolderDialog(Folder folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text('Are you sure you want to delete "${folder.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.deleteFolder(folder.id);
              _loadFolders();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getFolderColor(String folderName) {
    switch (folderName) {
      case 'Hearts':
        return Colors.red[300]!;
      case 'Diamonds':
        return Colors.red[200]!;
      case 'Clubs':
        return Colors.green[300]!;
      case 'Spades':
        return Colors.black87;
      default:
        return Colors.blue[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Organizer'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: _folders.length,
        itemBuilder: (context, index) {
          final folder = _folders[index];
          final cardCount = _folderCardCounts[folder.id] ?? 0;
          
          return Card(
            elevation: 4,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardsScreen(folder: folder),
                  ),
                ).then((_) => _loadFolders());
              },
              child: Column(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    color: _getFolderColor(folder.name),
                    child: Icon(
                      _getFolderIcon(folder.name),
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          folder.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$cardCount cards',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        if (cardCount < 3)
                          Text(
                            'Need ${3 - cardCount} more',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showRenameFolderDialog(folder),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () => _showDeleteFolderDialog(folder),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

IconData _getFolderIcon(String folderName) {
  switch (folderName) {
    case 'Hearts':
      return Icons.favorite;
    case 'Diamonds':
      return Icons.diamond;
    case 'Clubs':
      return Icons.circle; // Club alternative
    case 'Spades':
      return Icons.square; // Spade alternative
    default:
      return Icons.folder;
  }
}
}