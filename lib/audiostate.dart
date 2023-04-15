//import 'dart:html';

//import 'dart:wasm';

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
import 'package:intl/intl.dart';

final nowPosisionProvider = StreamProvider<Duration?>((ref) async*{
  ref.watch(AudiosProvider);
  final activeData = ref.watch(AudiosProvider.notifier).activeaudio;
  //return activeData != null ? activeData.audio.position : null;
  print('nowposition');
  if(activeData != null){
  
    await for (final position in activeData.audio.positionStream){
      print("nonnull");
      print(position);
      yield position;
  }
  }
  //return activeData?.audio.position;
});

final AudiosProvider = StateNotifierProvider<AudiosState, List<AudioData>>((ref) => AudiosState());

enum AudioPlayState {
  puase,
  playing,
}
class AudiosState extends StateNotifier<List<AudioData>> {

  AudiosState():super([]);
  int? nowActive;

  void addAudio(AudioData audiodata){
    state = [...state, audiodata];
    audiodata.audio.playerStateStream.listen((state){

    });
  }
  
  void play(int id){
    //print(state[id].audio.playing);
    // print('before');
    // print(state[id].audio.playerState);
    if(state[id].audio.playerState.processingState == ProcessingState.completed){
      state[id].audio.seek(Duration(seconds: 0));
    }
    print(state[id].audio.playing);
    
    state[id].audio.play(); 
    
    // print('after');
    // print(state[id].audio.playerState);
    state = [...state];
  }
  void stop(int id){
    state[id].audio.pause();
    //print(state[id].audio.playerState);
    state = [...state];
  }

  bool isPlaying(int index){
    return state[index].audio.playing;
  }

  AudioData? get activeaudio => nowActive != null ? state[nowActive!] : null;

  Duration bufferdPosision(int index){
    //state = [...state];
    return state[index].audio.bufferedPosition;
  }

  Duration position(int index){
    //if(state[index].audio.playing)
    //state = [...state];
    return state[index].audio.position;
  }
  Duration duration(int index){
    //state = [...state];
    return state[index].audio.duration!;
    
  }

  // ProcessingState get nowstate{
  //   return 
  // }
  

  void Activate(int id){
    for(final audio in state){

    }
  }



  void toggle(int id){
    if (nowActive == id){
      state[id]=state[id].copyWith(active: false);
      nowActive = null;
      //print('きちら');
    }else {
      if(nowActive != null) state[nowActive!] = state[nowActive!].copyWith(active: false);
      state[id]=state[id].copyWith(active: true);
      nowActive = id;
      //print('nonkiti');
    }
    state = [...state];
  }

}

class AudioData {
  AudioData({required this.audio, required this.name,required this.date,this.active=false});
  //AudioData({required this.audio, required this.name,required this.date,required this.active});
  final AudioPlayer audio;
  final String name;
  final String date;
  final bool active;

  AudioData copyWith({AudioPlayer? audio,String? name, String? date, bool? active}){
    return AudioData(
      audio: audio ?? this.audio,
      name: name ?? this.name, 
      date: date ?? this.date,
      active: active ?? this.active
    );
  }
}

// enum AudioState{

// }
