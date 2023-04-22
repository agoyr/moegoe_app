import 'dart:math';
import 'package:file_saver/file_saver.dart';
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
  runApp(const ProviderScope(child: MyApp()));
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
      persistentFooterButtons: [
        ElevatedButton(onPressed: (){print(ref.read(AudiosProvider.notifier).processingState);}, child:null)
      ],
    );
  }
}

class AudioWidget extends ConsumerWidget{
  AudioWidget({required this.index});
  int index;
  
  @override
  Widget build(BuildContext context, WidgetRef ref){
    //final pos = ref.watch(nowPosisionProvider);
    final data = ref.watch(AudiosProvider)[index];
    final audioNotifier = ref.read(AudiosProvider.notifier);
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
      child: GestureDetector(
        child:Column(
          children: [
            ListTile(
              title: Text(data.name),
              subtitle: Text(data.date),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              //height: audioNotifier.isActive(index) ? 300.0: 0.0,
              opacity: audioNotifier.isActive(index) ? 1.0 : 0.0,
              child: AnimatedContainer(
                height: audioNotifier.isActive(index) ? 100 : 0.0,
                //opacity: audioNotifier.isActive(index) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: onActivePart(ref, index),//audioNotifier.isActive(index) ? onActivePart(ref, index) : const SizedBox.shrink(),
              ),//)
            )
          ]
        ),
        onTap: () => ref.read(AudiosProvider.notifier).toggle(index),
      ),
    );
  }
}

Widget onActivePart(WidgetRef ref,int index){
  final audioNotifier = ref.watch(AudiosProvider.notifier);
  return Column(
  children: [
    Flexible(child: 
      Padding(
        padding: const EdgeInsets.only(left: 20.0,right: 20.0),
        child: ProgressBar(
          progress: audioNotifier.position(index),
          buffered: audioNotifier.bufferdPosision(index),
          total: audioNotifier.duration(index) ?? const Duration(seconds: 0)
        ),
      )
    ),
    Flexible(child: 
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed:(){
              
            },
            icon: const FittedBox(child: Icon(Icons.replay_10))
          ),
          if(!audioNotifier.isPlaying(index))
          IconButton(
            onPressed: (){
              ref.read(AudiosProvider.notifier).play(index);
            }, 
            icon: const FittedBox(child: Icon(Icons.play_arrow))
          )
          else
          IconButton(
            onPressed: (){
              ref.read(AudiosProvider.notifier).pause(index);
            }, 
            icon: const Icon(Icons.pause)
          )
          ,
          IconButton(
            onPressed: (){

            }, 
            icon: const FittedBox(child: Icon(Icons.forward_10))
          ),
        ],
      )
    ),
  ],
);}
