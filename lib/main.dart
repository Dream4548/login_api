import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() async {
  // ตรวจสอบให้แน่ใจว่า Flutter binding ถูกติดตั้ง
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login & Sign Up Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  Future<void> _login() async {
    final url = Uri.parse('https://wallet-api-7m1z.onrender.com/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['token'];

        // แสดง token ใน debug console
        print('Login successful. Token: $token');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful')),
        );

        // Navigate to UserInformationPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserInformationPage()),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid username or password')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'WELCOME',
              style: GoogleFonts.lato(
                textStyle: TextStyle(color: Colors.blue, letterSpacing: .5),
                fontSize: 50,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              child: Text('Login'),
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // สีพื้นหลังของปุ่ม
                foregroundColor: Colors.white, // สีของตัวอักษรในปุ่ม
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              child: Text('Don\'t have an account? Sign Up'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signUp() async {
    final url = Uri.parse('https://wallet-api-7m1z.onrender.com/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User registered successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'SIGN UP',
              style: GoogleFonts.lato(
                textStyle: TextStyle(color: Colors.blue, letterSpacing: .5),
                fontSize: 50,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              child: Text('Sign Up'),
              onPressed: _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              child: Text('Already have an account? Login'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

//UserInterform
class UserInformationPage extends StatefulWidget {
  @override
  _UserInformationPageState createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  Map<String, dynamic> _userInfo = {};
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchUserInformation();
  }

  Future<void> _fetchUserInformation() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('https://wallet-api-7m1z.onrender.com/user/information'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _userInfo = json.decode(response.body);
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _error = 'Unauthorized: Invalid or missing token.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load user information.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<String> _getToken() async {
    try {
      return await rootBundle.loadString('assets/token.txt');
    } catch (e) {
      throw Exception('Failed to load token: $e');
    }
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Information',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Text(
                    _error,
                    style: GoogleFonts.roboto(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                )
              : Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'User Details',
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildInfoItem('User ID', _userInfo['_id'] ?? ''),
                        _buildInfoItem('Username', _userInfo['username'] ?? ''),
                        _buildInfoItem('First Name', _userInfo['fname'] ?? ''),
                        _buildInfoItem('Last Name', _userInfo['lname'] ?? ''),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditUserNamePage(
                                  currentFname: _userInfo['fname'] ?? '',
                                  currentLname: _userInfo['lname'] ?? '',
                                ),
                              ),
                            );

                            if (result == true) {
                              _fetchUserInformation(); // อัพเดตข้อมูลหลังการแก้ไข
                            }
                          },
                          child: Text('Edit Profile'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

//eidt
class EditUserNamePage extends StatefulWidget {
  final String currentFname;
  final String currentLname;

  EditUserNamePage({required this.currentFname, required this.currentLname});

  @override
  _EditUserNamePageState createState() => _EditUserNamePageState();
}

class _EditUserNamePageState extends State<EditUserNamePage> {
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fnameController.text = widget.currentFname;
    _lnameController.text = widget.currentLname;
  }

  Future<void> _updateUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final token = await _getToken();
    final response = await http.post(
      Uri.parse('https://wallet-api-7m1z.onrender.com/user/set/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'fname': _fnameController.text,
        'lname': _lnameController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop(true); // ส่งสัญญาณกลับเมื่อทำสำเร็จ
    } else {
      setState(() {
        _error =
            json.decode(response.body)['error'] ?? 'Failed to update profile.';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUserName() async {
    setState(() {
      _fnameController.clear();
      _lnameController.clear();
    });
  }

  Future<String> _getToken() async {
    try {
      return await rootBundle.loadString('assets/token.txt');
    } catch (e) {
      throw Exception('Failed to load token: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _fnameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lnameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: _updateUserProfile,
                        child: Text('Save Changes'),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _deleteUserName,
                        child: Text('Clear Names'),
                        style: ElevatedButton.styleFrom(),
                      ),
                    ],
                  ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  _error,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
