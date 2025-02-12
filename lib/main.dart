import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpartaBarber',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.black, 
        textTheme: TextTheme(bodyLarge: TextStyle(color: const Color.fromARGB(255, 250, 249, 249))), 
      ),
      home: SplashScreen(), 
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.black, 
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/barber.png', 
              width: 200, 
              height: 200, 
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Olá, bora agendar?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _storage = FlutterSecureStorage();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String _currentForm = 'login'; 

  // Função para abrir o Instagram
  Future<void> _launchInstagram() async {
    const url = 'https://www.instagram.com/ericacom_c/'; // Substitua pelo seu link do Instagram
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o link $url';
    }
  }

  Future<void> login() async {
    final response = await http.post(
      Uri.parse('http://localhost:5100/login'),
      body: {
        'email': emailController.text,
        'password': passwordController.text,
      },
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      await _storage.write(key: 'token', value: data['token']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login realizado com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    }
  }

  Future<void> register() async {
    final response = await http.post(
      Uri.parse('http://localhost:5100/register'),
      body: {
        'email': emailController.text,
        'password': passwordController.text,
      },
    );

    final data = json.decode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'])),
    );
  }

  Future<void> recoverPassword() async {
    final response = await http.post(
      Uri.parse('http://localhost:5100/recover-password'),
      body: {
        'email': emailController.text,
      },
    );

    final data = json.decode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: Icon(
                FontAwesomeIcons.instagram, 
                color: Color(0xFF36AA91),
              ),
              onPressed: _launchInstagram, // Chama a função _launchInstagram
            ),
            SizedBox(width: 10),
            Text(
              "Visite nosso perfil!",
              style: TextStyle(color: Colors.white), 
            ),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.black, 
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Seletor de Formulário
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _currentForm = 'login'),
                    child: const Text('Login', style: TextStyle(color: Colors.greenAccent)),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentForm = 'register'),
                    child: const Text('Cadastro', style: TextStyle(color: Colors.greenAccent)),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentForm = 'recover'),
                    child: const Text('Recuperar Senha', style: TextStyle(color: Colors.greenAccent)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Formulário de acordo com a seleção
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    switch (_currentForm) {
      case 'register':
        return _buildRegisterForm();
      case 'recover':
        return _buildRecoverForm();
      case 'login':
      default:
        return _buildLoginForm();
    }
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        const Text(
          'Login',
          style: TextStyle(
            color: Color(0xFFF8F8F8),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField('Email', emailController),
        const SizedBox(height: 20),
        _buildTextField('Senha', passwordController, obscureText: true),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            side: const BorderSide(color: Color(0xFF48B487), width: 3),
          ),
          child: const Text('Login', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        const Text(
          'Cadastro',
          style: TextStyle(
            color: Color(0xFFF8F8F8),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField('Email', emailController),
        const SizedBox(height: 20),
        _buildTextField('Senha', passwordController, obscureText: true),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: register,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            side: const BorderSide(color: Color(0xFF48B487), width: 3),
          ),
          child: const Text('Cadastrar', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildRecoverForm() {
    return Column(
      children: [
        const Text(
          'Recuperar Senha',
          style: TextStyle(
            color: Color(0xFFF8F8F8),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField('Email', emailController),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: recoverPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            side: const BorderSide(color: Color(0xFF48B487), width: 3),
          ),
          child: const Text('Recuperar', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white), // Rótulo branco
        filled: true,
        fillColor: Colors.black, // Fundo preto
        focusColor: Colors.greenAccent,
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF36AA91), width: 3), // Borda verde água
          borderRadius: BorderRadius.circular(15),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF52EECC), width: 3), // Borda verde água
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
