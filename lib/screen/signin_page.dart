import 'package:flutter/material.dart';
import 'package:libirary_app/screen/admin_panel.dart';
import 'package:libirary_app/service/database_helper.dart';
import 'member_page.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    final db = await _dbHelper.database;

    // Query the database for the user
    final result = await db.query(
      'Members',
      where: 'Email = ? AND Password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      final user = result.first;
      final String role = user['Role'] as String ?? 'Member';
      final int memberId = user['Member_ID'] as int;
      final String name = user['Name'] as String;

      if (role == 'Admin') {
        // Navigate to AdminPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPage(name: name)),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$role Registered Successfully!')),
        );
      } else {
        // Navigate to MemberPage with ID and Name
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MemberPage(name: name, memberId: memberId),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$role Registered Successfully!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid email or password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
