//import 'dart:html';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moegoe_app/makeTTS.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer';
import 'makeTTS.dart';
import 'audiostate.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';


void main() {
  runApp(ProviderScope(child:const MyApp()));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: AudiosForm(),
    );
  }
}
class AudiosForm extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final data =ref.watch(AudiosProvider);
    //print(audios.length);
    return Scaffold(
      appBar: AppBar(
        title: const Text('TTS App'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: ref.read(AudiosProvider).length,
          itemBuilder: (BuildContext context, int index){
            return AudioWidget(index: index);
          } 

        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => TTSForm()));
        },
      ),
    );
  }
}

class AudioWidget extends ConsumerWidget{
  AudioWidget({required this.index});
  int index;
  //WidgetRef ref;
  
  @override
  Widget build(BuildContext context, WidgetRef ref){
    final pos = ref.watch(nowPosisionProvider);
    final data = ref.watch(AudiosProvider)[index];
    final audioNotifier = ref.read(AudiosProvider.notifier);
    return GestureDetector(
      child:Column(
        children: [
          ListTile(
            title: Text(data.name),
            subtitle: Text(data.date),
          ),
          if(data.active)
            ProgressBar(
              progress: ref.read(nowPosisionProvider).when(
                data: (pos){return pos ?? const Duration(minutes: 0);},
                error: (error, stack)=> const Duration(minutes: 0),
                loading: () => const Duration(minutes: 0),
              ), 
              buffered: audioNotifier.bufferdPosision(index),
              total: audioNotifier.duration(index)
            ),
          if(data.active)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed:(){
                    
                  },
                  icon: Icon(Icons.replay_10)
                ),
                if(!audioNotifier.isPlaying(index))
                IconButton(
                  onPressed: (){
                    ref.read(AudiosProvider.notifier).play(index);
                  }, 
                  icon: const Icon(Icons.play_arrow)
                )
                else
                IconButton(
                  onPressed: (){
                    ref.read(AudiosProvider.notifier).stop(index);
                  }, 
                  icon: const Icon(Icons.pause)
                )
                ,
                IconButton(
                  onPressed: (){

                  }, 
                  icon: Icon(Icons.forward_10)
                ),
              ],
            )
          //),
          
        ]
      ),
      onTap: () => ref.read(AudiosProvider.notifier).toggle(index),
    );
  }
}

