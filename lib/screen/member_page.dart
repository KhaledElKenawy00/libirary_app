import 'package:flutter/material.dart';
import 'package:libirary_app/service/database_helper.dart';

class MemberPage extends StatefulWidget {
  final String name;
  final int memberId;

  const MemberPage({Key? key, required this.name, required this.memberId})
      : super(key: key);

  @override
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> _getBooks() async {
    return await _dbHelper.database.then(
      (db) =>
          db.query('Books', where: 'Availability_Status = ?', whereArgs: [1]),
    );
  }

  Future<List<Map<String, dynamic>>> _getTransactionHistory() async {
    return await _dbHelper.database.then(
      (db) => db.query(
        'Transactions',
        where: 'Member_ID = ?',
        whereArgs: [widget.memberId],
        orderBy: 'Issue_Date DESC',
      ),
    );
  }

  void _borrowBook(int bookId) async {
    final db = await _dbHelper.database;

    // Check if the book is already borrowed by this member
    final existingTransaction = await db.query(
      'Transactions',
      where: 'Book_ID = ? AND Member_ID = ? AND Return_Date IS NULL',
      whereArgs: [bookId, widget.memberId],
    );

    if (existingTransaction.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You already borrowed this book.')),
      );
      return;
    }

    // Insert into Transactions table
    await db.insert('Transactions', {
      'Member_ID': widget.memberId,
      'Book_ID': bookId,
      'Issue_Date': DateTime.now().toIso8601String(),
      'Return_Date': null,
    });

    // Mark the book as unavailable
    await db.update(
      'Books',
      {'Availability_Status': 0},
      where: 'Book_ID = ?',
      whereArgs: [bookId],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Book borrowed successfully.')),
    );

    setState(() {});
  }

  void _returnBook(int bookId) async {
    final db = await _dbHelper.database;

    // Update Transactions table
    await db.update(
      'Transactions',
      {'Return_Date': DateTime.now().toIso8601String()},
      where: 'Book_ID = ? AND Member_ID = ? AND Return_Date IS NULL',
      whereArgs: [bookId, widget.memberId],
    );

    // Mark the book as available
    await db.update(
      'Books',
      {'Availability_Status': 1},
      where: 'Book_ID = ?',
      whereArgs: [bookId],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Book returned successfully.')),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.name}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Available Books',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _getBooks(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final books = snapshot.data!;
                if (books.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('No books available to borrow.'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return ListTile(
                      title: Text(book['Title']),
                      subtitle: Text('Author: ${book['Author']}'),
                      trailing: ElevatedButton(
                        onPressed: () => _borrowBook(book['Book_ID'] as int),
                        child: Text('Borrow'),
                      ),
                    );
                  },
                );
              },
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Your Borrowing History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _getTransactionHistory(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final transactions = snapshot.data!;
                if (transactions.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('No borrowing history.'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final isReturned = transaction['Return_Date'] != null;

                    return ListTile(
                      title: Text('Book ID: ${transaction['Book_ID']}'),
                      subtitle: Text(
                        'Issued: ${transaction['Issue_Date']}\nReturned: ${transaction['Return_Date'] ?? 'Not yet'}',
                      ),
                      trailing: !isReturned
                          ? ElevatedButton(
                              onPressed: () =>
                                  _returnBook(transaction['Book_ID'] as int),
                              child: Text('Return'),
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
