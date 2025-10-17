import 'package:flutter/material.dart';
import 'database_helper.dart';

// Here we are using a global variable. You can use something like
// get_it in a production app.
final dbHelper = DatabaseHelper();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize the database
  await dbHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQFlite Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _records = [];
  int _recordCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    await _query(); // Added await here
    await _getRecordCount(); // Added await here
  }

  Future<void> _getRecordCount() async {
    final count = await dbHelper.queryRowCount();
    setState(() {
      _recordCount = count;
    });
  }

  // Enhanced UI with modern design
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Manager'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stats Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total Records', _recordCount.toString(), Icons.list),
                    _buildStatItem('Table', 'my_table', Icons.storage),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Operation Buttons
            const Text(
              'Database Operations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildOperationButton(
                  'Insert Record',
                  Icons.add,
                  Colors.green,
                  _insert,
                ),
                _buildOperationButton(
                  'Query All',
                  Icons.search,
                  Colors.blue,
                  _query,
                ),
                _buildOperationButton(
                  'Update Record',
                  Icons.edit,
                  Colors.orange,
                  _update,
                ),
                _buildOperationButton(
                  'Delete Last',
                  Icons.delete,
                  Colors.red,
                  _delete,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Records Display
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Records in Database',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _records.isEmpty
                          ? Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.list_alt,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No records found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const Text(
                                      'Use the buttons above to add records',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount: _records.length,
                                itemBuilder: (context, index) {
                                  final record = _records[index];
                                  return _buildRecordCard(record, index);
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _insert,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New Record',
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildOperationButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      width: 140,
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColorForIndex(index),
          child: Text(
            record['_id'].toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          record['name'] ?? 'No Name',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text('Age: ${record['age']}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteSpecificRecord(record['_id']),
          tooltip: 'Delete this record',
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];
    return colors[index % colors.length];
  }

  // Enhanced Button onPressed methods with UI feedback

  Future<void> _insert() async { // Changed to async
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: 'User${_recordCount + 1}',
      DatabaseHelper.columnAge: 20 + _recordCount,
    };
    final id = await dbHelper.insert(row);
    debugPrint('inserted row id: $id');
    
    // Show snackbar feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Record inserted with ID: $id'),
          backgroundColor: Colors.green,
        ),
      );
    }
    
    await _refreshData();
  }

  Future<void> _query() async { // Changed to async and returns Future<void>
    final allRows = await dbHelper.queryAllRows();
    debugPrint('query all rows:');
    for (final row in allRows) {
      debugPrint(row.toString());
    }
    
    setState(() {
      _records = allRows;
    });
    
    // Show snackbar feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Queried ${allRows.length} records'),
          backgroundColor: Colors.blue,
        ),
      );
    }
    
    await _getRecordCount();
  }

  Future<void> _update() async { // Changed to async
    if (_records.isEmpty) {
      _showError('No records to update. Please insert some records first.');
      return;
    }
    
    // row to update - update the first record
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: _records.first['_id'],
      DatabaseHelper.columnName: 'Updated${DateTime.now().second}',
      DatabaseHelper.columnAge: DateTime.now().second,
    };
    final rowsAffected = await dbHelper.update(row);
    debugPrint('updated $rowsAffected row(s)');
    
    // Show snackbar feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Updated $rowsAffected record(s)'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    
    await _refreshData();
  }

  Future<void> _delete() async { // Changed to async
    final count = await dbHelper.queryRowCount();
    if (count == 0) {
      _showError('No records to delete.');
      return;
    }
    
    // Assuming that the number of rows is the id for the last row.
    final id = count;
    final rowsDeleted = await dbHelper.delete(id);
    debugPrint('deleted $rowsDeleted row(s): row $id');
    
    // Show snackbar feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted record with ID: $id'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    await _refreshData();
  }

  Future<void> _deleteSpecificRecord(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Are you sure you want to delete record ID: $id?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final rowsDeleted = await dbHelper.delete(id);
      debugPrint('deleted $rowsDeleted row(s): row $id');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted record ID: $id'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      await _refreshData();
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}