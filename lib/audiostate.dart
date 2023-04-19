import 'dart:async';
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

final AudiosProvider = StateNotifierProvider<AudiosState, List<AudioData>>((ref) => AudiosState());

class AudiosState extends StateNotifier<List<AudioData>> {

  AudiosState():super([]);
  int? nowActive;
  StreamSubscription? _positoinSub;
  StreamSubscription? _playerStateSub;

  ProcessingState? get processingState => nowActive != null ? state[nowActive!].audio.processingState : null;

  void addAudio(AudioData audiodata){
    state = [...state, audiodata];
    audiodata.audio.playerStateStream.listen((state){

    });
  }
  
  void play(int id) async {
    if(state[id].audio.playerState.processingState == ProcessingState.completed){
      await state[id].audio.seek(Duration(seconds: 0));
    }
    print('play');    
    state[id].audio.play(); 
    state = [...state];
  }

  void pause(int id){
    state[id].audio.pause();
    state = [...state];
  }
   void stop(int id){
    state[id].audio.stop();
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
  Duration? duration(int index){
    //state = [...state];
    return state[index].audio.duration;
    
  }
  bool isActive(int index){
    return state[index].active;
  }

  void toggle(int id){
    if (nowActive == id){
      state[id].audio.stop();
      state[id]=state[id].copyWith(active: false);
      nowActive = null;
      _positoinSub?.pause();
      _playerStateSub?.pause();
    }else {
      if(nowActive != null){
        state[nowActive!].audio.stop();
        state[nowActive!] = state[nowActive!].copyWith(active: false);

      } 
      state[id]=state[id].copyWith(active: true);
      _positoinSub = state[id].audio.positionStream.listen((event) {
        //print(event);
        state=[...state];
      });
      _playerStateSub = state[id].audio.playerStateStream.listen((state) {
        //print(state);
        if(state.processingState == ProcessingState.completed){
          pause(id);
        }
       });
      _positoinSub!.resume();
      _playerStateSub!.resume();
      nowActive = id;
    }
    state = [...state];
  }

}

class AudioData {
  AudioData({required this.audio, required this.name,required this.date,this.active=false});
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
