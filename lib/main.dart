import 'dart:math';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moegoe_app/db.dart';
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
import 'package:sqflite/sqflite.dart';

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
        primarySwatch: Colors.amber,
      ),
      home: const AudiosListPage(),
    );
  }
}

class AudiosListPage extends ConsumerWidget {
  const AudiosListPage({super.key});

  Widget widgetOption(int index, WidgetRef ref){
    switch (index) {
      case 0:
        return ListView.builder(
          itemCount: ref.read(AudiosProvider).length,
          itemBuilder: (BuildContext context, int index){
            return AudioWidget(index: index,viewModel: AudiosProvider,);
          } 
        );
      case 1://return const Center(child: Text('weeee'),);
        return ListView.builder(
          itemCount: ref.read(localAudioViewModelProvider).length,
          itemBuilder: (BuildContext context, int index){
            return AudioWidget(index: index,viewModel: localAudioViewModelProvider);
          } 
        );
      default:
        return const Text('error');
    }
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    //final data =ref.watch(AudiosProvider);
    ref.watch(nowPageIndexProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('TTS App'),
      ),
      body: widgetOption(ref.read(nowPageIndexProvider), ref),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_open_outlined), label: 'local'),
        ],
        currentIndex: ref.read(nowPageIndexProvider),
        onTap: (index){
          ref.read(nowPageIndexProvider.notifier).state=index;
        },
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => TTSForm()));
        },
      ),
    );
  }
}

final nowPageIndexProvider = StateProvider<int>((ref) => 0);


class AudioWidget extends ConsumerWidget{
  AudioWidget({required this.index,required this.viewModel});
  int index;
  final viewModel;

  Widget onActivePart(WidgetRef ref,int index){
    final audioNotifier = ref.watch(viewModel.notifier);
    final data = ref.read(viewModel)[index];
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
        Stack(children: [
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
                  audioNotifier.play(index);
                }, 
                icon: const FittedBox(child: Icon(Icons.play_arrow))
              )
              else
              IconButton(
                onPressed: (){
                  audioNotifier.pause(index);
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
          ),
          if(viewModel == AudiosProvider) streamingAlignment(ref)
          else if (viewModel == localAudioViewModelProvider) localAlignment(ref)
        ],)
        
      ),
    ],
  );}

  Widget streamingAlignment(WidgetRef ref){
    final audioNotifier = ref.watch(viewModel.notifier);
    final data = ref.read(viewModel)[index];
    return Align(
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.file_download),
                      onPressed: ()async{
                        ref.read(localAudioViewModelProvider.notifier).download(data);
                      },
                    ),
                    IconButton(
                      onPressed: () async{
                        await FileSaver.instance.saveFile(name:'${data.name}.mp3',bytes:data.bytes,ext:'mp3');
                      },
                      icon: const Icon(Icons.folder_outlined),
                    ),
                ],)
              );
  }

  Widget localAlignment(WidgetRef ref){
    final audioNotifier = ref.watch(viewModel.notifier);
    final data = ref.read(viewModel)[index];
    return Align(
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.file_download),
                      onPressed: ()async{
                        ref.read(localAudioViewModelProvider.notifier).download(data);
                      },
                    ),
                    IconButton(
                      onPressed: () async{
                        await FileSaver.instance.saveFile(name:'${data.name}.mp3',bytes:data.bytes,ext:'mp3');
                      },
                      icon: const Icon(Icons.folder_outlined),
                    ),
                ],)
              );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final data = ref.watch(viewModel)[index];
    final audioNotifier = ref.read(viewModel.notifier);
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))
      ),
      child: GestureDetector(
        child:Column(
          children: [
            ListTile(
              title: Text(data.name),
              subtitle: Text(data.date),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: audioNotifier.isActive(index) ? 1.0 : 0.0,
              child: AnimatedContainer(
                height: audioNotifier.isActive(index) ? 100 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: onActivePart(ref, index),
              ),
            )
          ]
        ),
        onTap: () => audioNotifier.toggle(index),
      ),
    );
  }
}
