import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

import 'dart:developer';

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

  Future<void> _handleHttp() async {
    //var url = Uri.parse('http://localhost:8080/tts?text=''おはよう');
    
    //try{
      // Directory appDocDir = await getApplicationDocumentsDirectory();
      // String appDocPath = appDocDir.path;
      // String imgPath = appDocPath + '/audio.wav';
      var url = Uri.http('localhost:8080', 'tts', {'text': ttsText});
      print(url);
      var response = await http.get(url);
      print(response.bodyBytes.runtimeType);
      await _player.setUrl('http://localhost:8080/audio');
      await _player.play();
      // final file = File(imgPath);
      // await file.create();
      // await file.writeAsBytes(response.bodyBytes);

   //

    
    // if (response.statusCode == 200) {
    //   var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
    //   var itemCount = jsonResponse['totalItems'];
    //   print('Number of books about http: $itemCount.');
    // } else {
    //   print('Request failed with status: ${response.statusCode}.');
    // }
  }


  final myController = TextEditingController();
  String ttsText='';
  late AudioPlayer _player = AudioPlayer();

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
                ttsText = myController.text;
                //print(ttsText);
                _handleHttp();
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

// Future<void> _handleHttp() async {
//     var url = Uri.http('localhost:8080', '/tts', {'text': 'gori'});
    
//     print(url);

//     var response = await http.get(url);
//   }