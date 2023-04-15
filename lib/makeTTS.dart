import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer';
import 'audiostate.dart';
import 'package:intl/intl.dart';

//This is for exchange binary to audio data
class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;
  MyCustomSource(this.bytes) : super(null);
  
  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}

class TTSForm extends ConsumerWidget {
  Future<void> _handleHttp(WidgetRef ref) async {
    
    var url = Uri.http('localhost:8080', 'tts', {'text': ttsText});
    var response = await http.get(url);
    AudioPlayer _player = AudioPlayer();
    _player.setAudioSource(MyCustomSource(response.bodyBytes));
    AudioData _audioData = AudioData(audio: _player, name: ttsText, date: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    ref.read(AudiosProvider.notifier).addAudio(_audioData);
    // print(ref.read(AudiosProvider).length);
    // print('ログ');
    //_players.add(AudioPlayer());
    //await _players.last.play();
    //return _player;
  }


  final myController = TextEditingController();
  String ttsText='';
  //late AudioPlayer _player = AudioPlayer();
  //List<AudioPlayer> _players = [];


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoeGoe App'),
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
            Builder(builder: (context){
              return ElevatedButton(
              onPressed: ()async {
                ttsText = myController.text;
                _handleHttp(ref).then((value) => Navigator.pop(context));
                //ref.read(AudiosProvider.notifier).addAudio(p.);
                //Navigator.pop(context);
              }, 
              child: const Text(
                'Generate!',
                //style: ,
              )
              );
            }),
            
          ],
        ),
      ),
    );
  }
}



// Directory appDocDir = await getApplicationDocumentsDirectory();
      // String appDocPath = appDocDir.path;
      // String imgPath = appDocPath + '/audio.wav';
      
      // final file = File(imgPath);
      // await file.create();
      // await file.writeAsBytes(response.bodyBytes);
       //print(response.bodyBytes.runtimeType);
       //print(url);