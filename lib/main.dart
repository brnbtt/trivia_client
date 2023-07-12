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
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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

class _MyHomePageState extends State<MyHomePage> {
  late final IO.Socket socket = IO.io('http://localhost:3333');
  bool _showNameInput = true;
  String _name = '';

  void _submitName() {
    socket.emit('nameEntered', _name);
    setState(() {
      _showNameInput = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _showNameInput
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _name = value;
                        });
                      },
                      keyboardType: TextInputType.name,
                      autofocus: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your name',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16, width: 50),
                  ElevatedButton(
                    onPressed: _name.isNotEmpty ? _submitName : null,
                    child: const Text('Submit'),
                  ),
                ],
              )
            : MyButton(socket: socket),
      ),
    );
  }
}
