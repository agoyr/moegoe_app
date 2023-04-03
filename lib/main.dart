import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        //primaryTextTheme: TextTheme(),
      ),
      home: const SendingForm(title: 'MoeGoe App'),
    );
  }
}

class SendingForm extends StatefulWidget {
  const SendingForm({super.key, required this.title});

  final String title;

  @override
  State<SendingForm> createState() => _SendingPageState();
}

class _SendingPageState extends State<SendingForm> {
  final myController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Please enter the text that you wanna make speech',
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Hello everyone!'
              ),
              controller: myController,
            ),
            ElevatedButton(
              onPressed: (){
                final String ttsText = myController.text;
                print(ttsText);
              }, 
              child: const Text(
                'Generate!',
                //style: ,
              )
            ),
          ],
        ),
      ),
    );
  }
}
