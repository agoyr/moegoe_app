import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'audiostate.dart';
import 'audiostate.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

final localAudioDatabaseProvider = Provider<ModelInterface>((ref) => AudioDataBase());
final localAudioViewModelProvider=StateNotifierProvider<LocalAudioViewModel,List<AudioData>>((ref) => LocalAudioViewModel(database:ref.watch(localAudioDatabaseProvider)));

class LocalAudioViewModel extends StateNotifier<List<AudioData>>{
  LocalAudioViewModel({required database}):_database=database,super([]);

  final ModelInterface _database;
  void download(AudioData data){
    //_database.create(tableName: _database.tableName, audioData: data.toMap());
    state=[...state,data];
  }

  int? nowActive;
  StreamSubscription? _positoinSub;
  StreamSubscription? _playerStateSub;

  ProcessingState? get processingState => nowActive != null ? state[nowActive!].audio.processingState : null;

  void addAudio(AudioData audiodata){
    state = [...state, audiodata];
    // audiodata.audio.playerStateStream.listen((state){

    // });
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
          //print(state);
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

abstract class ModelInterface{
  Future<int> create({
    required String tableName,
    required Map<String, Object?> audioData,
  });
}

class AudioDataBase implements ModelInterface{

 static Database? _database;
  /// initDBをしてdatabaseを使用する
  Future<Database> get database async => _database ??= await initDB();

  final dbName = "localAudio.db";
  final tableName = "localAudio";

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTable,
      //onUpgrade: _upgradeTabelV1toV2,
    );
  }

  Future<void> _createTable(Database db, int version) async {
    final batch = db.batch();
    //batch.execute('DROP TABLE IF EXISTS $dbName');
    batch.execute(
      "CREATE TABLE $tableName("
      "TTStext TEXT NOT NULL,"
      "date INTEGER NOT NULL,"
      "bytes BLOB NOT NULL"
      ");",
    );
    await batch.commit();
  }

  /// tableにレコードをinsertする
  /// [json]はレコードの内容
  @override
  Future<int> create({
    required String tableName,
    required Map<String, Object?> audioData,
  }) async {
    final db = await database;
    return db.insert(tableName, audioData);
  }

  /// tableからデータを取得する
  /// [where]は id = ? のような形式にする
  /// [where]もしくは[whereArgs]がnullの場合は全件取得する
  Future<List<Map<String, Object?>>> read({
    required String tableName,
    String? where,
    List? whereArgs,
  }) async {
    final db = await database;
    if (where == null || whereArgs == null) {
      return db.query(tableName);
    }
    return db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// tableのidに一致する[primaryKey]を指定してレコードをupdateする
  Future<int> update({
    required String tableName,
    required Map<String, Object?> json,
    required String primaryKey,
  }) async {
    final db = await database;
    return db.update(
      tableName,
      json,
      where: "id = ?",
      whereArgs: [primaryKey],
    );
  }

  /// tableのidに一致する[primaryKey]を指定してレコードを削除する
  Future<int> delete({
    required String tableName,
    required String primaryKey,
  }) async {
    final db = await database;
    var res = db.delete(tableName, where: "id = ?", whereArgs: [primaryKey]);
    return res;
  }

}