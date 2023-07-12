import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Trivia'),
    );
  }
}

class MyButton extends StatelessWidget {
  final IO.Socket socket;

  const MyButton({required this.socket});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => socket.emit('buttonPressed'),
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(const Size(200, 60)),
      ),
      child: const Text('Press me'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late final IO.Socket socket = IO.io('http://localhost:3333');
  bool _showNameInput = true;
  late TextEditingController _nameController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  void _submitName() {
    socket.emit('nameEntered', _nameController.text);
    setState(() {
      _showNameInput = false;
    });
  }

  @override
  void dispose() {
    socket.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool _isSubmitButtonEnabled() {
    return _nameController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient and blur container
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final color1 = HSVColor.fromAHSV(
                1.0,
                _animationController.value * 360,
                1.0,
                1.0,
              ).toColor();
              final color2 = HSVColor.fromAHSV(
                1.0,
                (_animationController.value + 0.5) % 1.0 * 360,
                1.0,
                1.0,
              ).toColor();

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color1, color2],
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                  child: child,
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Trivia',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _showNameInput
                      ? // Name input card
                      Card(
                          key: const ValueKey('nameInput'),
                          color: Colors.white.withOpacity(0.6),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: SizedBox(
                                  width: 250,
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: _nameController,
                                        onChanged: (_) {
                                          setState(() {});
                                        },
                                        keyboardType: TextInputType.name,
                                        autofocus: true,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Enter your name',
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _isSubmitButtonEnabled()
                                            ? _submitName
                                            : null,
                                        child: const Text('Submit'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : // "Press me" button
                      Column(children: [
                          MyButton(socket: socket),
                        ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
