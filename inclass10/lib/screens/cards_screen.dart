import 'package:flutter/material.dart';
import 'package:inclass10/database_helper.dart';
import 'package:inclass10/models/models.dart';

class CardsScreen extends StatefulWidget {
  final Folder folder;

  const CardsScreen({super.key, required this.folder});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<PlayingCard> _cards = []; // Changed from Card to PlayingCard
  List<PlayingCard> _availableCards = []; // Changed from Card to PlayingCard

  @override
  void initState() {
    super.initState();
    _loadCards();
    _loadAvailableCards();
  }

  Future<void> _loadCards() async {
    final cardMaps = await _dbHelper.getCardsByFolder(widget.folder.id);
    setState(() {
      _cards = cardMaps.map((map) => PlayingCard.fromMap(map)).toList(); // Updated
    });
  }

  Future<void> _loadAvailableCards() async {
    final cardMaps = await _dbHelper.getCardsByFolder(null);
    setState(() {
      _availableCards = cardMaps.map((map) => PlayingCard.fromMap(map)).toList(); // Updated
    });
  }

  void _showAddCardDialog() async {
    final currentCount = await _dbHelper.getCardCountInFolder(widget.folder.id);
    
    if (currentCount >= 6) {
      _showErrorDialog('This folder can only hold 6 cards.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Card to Folder'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _availableCards.isEmpty
              ? const Center(child: Text('No available cards'))
              : ListView.builder(
                  itemCount: _availableCards.length,
                  itemBuilder: (context, index) {
                    final card = _availableCards[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getSuitColor(card.suit),
                        child: Text(
                          card.name[0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(card.fullName),
                      onTap: () async {
                        await _dbHelper.updateCardFolder(card.id, widget.folder.id);
                        Navigator.pop(context);
                        _loadCards();
                        _loadAvailableCards();
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRemoveCardDialog(PlayingCard card) { // Updated parameter type
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Card'),
        content: Text('Remove ${card.fullName} from ${widget.folder.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.updateCardFolder(card.id, null);
              Navigator.pop(context);
              _loadCards();
              _loadAvailableCards();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _getSuitColor(String suit) {
    switch (suit) {
      case 'Hearts':
      case 'Diamonds':
        return Colors.red;
      case 'Clubs':
      case 'Spades':
        return Colors.black;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCount = _cards.length;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.folder.name} Cards'),
        backgroundColor: _getSuitColor(widget.folder.name),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCardDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          if (currentCount < 3)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange[100],
              child: Text(
                'Warning: You need at least 3 cards in this folder. Currently: $currentCount',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.orange),
              ),
            ),
          Expanded(
            child: _cards.isEmpty
                ? const Center(
                    child: Text(
                      'No cards in this folder\nTap + to add cards',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      return Card( // This is the Material Card widget - no conflict!
                        elevation: 4,
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Container(
                                  height: 120,
                                  width: double.infinity,
                                  color: _getSuitColor(card.suit),
                                  child: Center(
                                    child: Text(
                                      card.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        card.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'of ${card.suit}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => _showRemoveCardDialog(card),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCardDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}