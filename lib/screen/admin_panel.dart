import 'package:flutter/material.dart';
import 'package:libirary_app/service/database_helper.dart';

class AdminPage extends StatefulWidget {
  final String name;

  const AdminPage({Key? key, required this.name}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> _getBooks() async {
    return await _dbHelper.getBooks();
  }

  Future<List<Map<String, dynamic>>> _getMembers() async {
    return await _dbHelper.getMembers();
  }

  void _addBook() async {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final publisherController = TextEditingController();
    final yearController = TextEditingController();
    final genreController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Book'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: authorController,
                decoration: InputDecoration(labelText: 'Author'),
              ),
              TextField(
                controller: publisherController,
                decoration: InputDecoration(labelText: 'Publisher'),
              ),
              TextField(
                controller: yearController,
                decoration: InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: genreController,
                decoration: InputDecoration(labelText: 'Genre'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.insertBook({
                'Title': titleController.text,
                'Author': authorController.text,
                'Publisher': publisherController.text,
                'Year': int.parse(yearController.text),
                'Genre': genreController.text,
                'Availability_Status': 1,
              });
              Navigator.pop(context);
              setState(() {});
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addMember() async {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Member'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.insertMember({
                'Name': nameController.text,
                'Address': addressController.text,
                'Phone': phoneController.text,
                'Email': emailController.text,
                'Password': passwordController.text,
                'Registration_Date': DateTime.now().toIso8601String(),
                'Role': 'Member',
              });
              Navigator.pop(context);
              setState(() {});
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(String table, String idColumn, int id) async {
    await _dbHelper.database.then((db) {
      db.delete(table, where: '$idColumn = ?', whereArgs: [id]);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text('Add Book'),
              trailing: Icon(Icons.add),
              onTap: _addBook,
            ),
            ListTile(
              title: Text('Add Member'),
              trailing: Icon(Icons.add),
              onTap: _addMember,
            ),
            Divider(),
            Text('All Books', style: TextStyle(fontWeight: FontWeight.bold)),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _getBooks(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final book = snapshot.data![index];
                    return ListTile(
                      title: Text(book['Title']),
                      subtitle: Text('Author: ${book['Author']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteItem(
                            'Books', 'Book_ID', book['Book_ID'] as int),
                      ),
                    );
                  },
                );
              },
            ),
            Divider(),
            Text('All Members', style: TextStyle(fontWeight: FontWeight.bold)),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _getMembers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final member = snapshot.data![index];
                    return ListTile(
                      title: Text(member['Name']),
                      subtitle: Text('Email: ${member['Email']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteItem(
                            'Members', 'Member_ID', member['Member_ID'] as int),
                      ),
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
