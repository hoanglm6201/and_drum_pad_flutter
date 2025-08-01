import 'package:and_drum_pad_flutter/data/model/lesson_model.dart';
import 'package:and_drum_pad_flutter/data/service/song_collection_service.dart';
import 'package:and_drum_pad_flutter/view_model/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CampaignProvider with ChangeNotifier {
  CategoryProvider _categoryProvider;
  int _easyUnlocked = 0;
  int _mediumUnlocked = 0;
  int _hardUnlocked = 0;
  int _demonicUnlocked = 0;

  int get easyUnlocked => _easyUnlocked;
  int get mediumUnlocked => _mediumUnlocked;
  int get hardUnlocked => _hardUnlocked;
  int get demonicUnlocked => _demonicUnlocked;

  int _currentLessonCampaign = 0;
  int get currentLessonCampaign => _currentLessonCampaign;

  int _currentSongCampaign = 0;
  int get currentSongCampaign => _currentSongCampaign;

  List<SongCollection> currentCampaign = [];

  List<SongCollection> _easyCampaign = [];
  List<SongCollection> _mediumCampaign = [];
  List<SongCollection> _hardCampaign = [];
  List<SongCollection> _demonicCampaign = [];

  List<SongCollection> get easyCampaign => _easyCampaign;
  List<SongCollection> get mediumCampaign => _mediumCampaign;
  List<SongCollection> get hardCampaign => _hardCampaign;
  List<SongCollection> get demonicCampaign => _demonicCampaign;

  CampaignProvider(this._categoryProvider){
    initUnlocked();
  }

  void updateDependencies(CategoryProvider categoryProvider) {
    _categoryProvider = categoryProvider;
    notifyListeners();
  }

  Future<void> initUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    _easyUnlocked = prefs.getInt('easyUnlocked') ?? 0;
    _mediumUnlocked = prefs.getInt('mediumUnlocked') ?? 0;
    _hardUnlocked = prefs.getInt('hardUnlocked') ?? 0;
    _demonicUnlocked = prefs.getInt('demonicUnlocked') ?? 0;
  }

  void setCurrentLessonCampaign(int value){
    _currentLessonCampaign = value;
    notifyListeners();
  }

  void setCurrentSongCampaign(int value){
    _currentSongCampaign = value;
    print('campaign index at $value');
    notifyListeners();
  }

  void setCurrentCampaign({bool isEasy = false, bool isMedium = false, bool isHard = false, bool isDemonic = false}){
    if(isEasy) currentCampaign = _easyCampaign;
    if(isMedium) currentCampaign = _mediumCampaign;
    if(isHard) currentCampaign = _hardCampaign;
    if(isDemonic) currentCampaign = _demonicCampaign;
    notifyListeners();
  }

  Future<void> fetchCampaignSong({bool isEasy = false, bool isMedium = false, bool isHard = false, bool isDemonic = false}) async {
    if(isEasy) _easyCampaign = mergeLists(await _getSongsByDifficulty(DifficultyMode.easy,), await _getListSongByDifficulty(DifficultyMode.easy));
    if(isMedium) _mediumCampaign = mergeLists(await _getSongsByDifficulty(DifficultyMode.medium,), await _getListSongByDifficulty(DifficultyMode.medium));
    if(isHard) _hardCampaign = mergeLists(await _getSongsByDifficulty(DifficultyMode.hard,), await _getListSongByDifficulty(DifficultyMode.hard));
    if(isDemonic) _demonicCampaign = mergeLists(await _getSongsByDifficulty(DifficultyMode.demonic,), await _getListSongByDifficulty(DifficultyMode.demonic));
    notifyListeners();
  }

  Future<List<SongCollection>> _getSongsByDifficulty(String difficulty) async {
    final categories = _categoryProvider.categories;
    if(categories.isEmpty) await _categoryProvider.fetchCategories();
    List<SongCollection> result = [];
    for(var category in categories){
      if(category.items == null || category.items!.isEmpty) continue;
      final songs = category.items?.where((song) => song.difficulty == difficulty,).toList();
      if(songs != null && songs.isNotEmpty) result.addAll(songs);
    }
    return result;
  }

  /// get list in database
  Future<List<SongCollection>> _getListSongByDifficulty(String difficulty) async {
    return await SongCollectionService.getListSongByDifficultyMode(difficulty);
  }

  /// merge list from server and database
  List<SongCollection> mergeLists(List<SongCollection> listFromServer, List<SongCollection> listFromDB) {
    Map<String, SongCollection> mapB = {for (var item in listFromDB) item.id: item};

    return listFromServer.map((item) => mapB.containsKey(item.id) ? mapB[item.id]! : item).toList();
  }

  /// set indexUnlocked of difficulty list at campaign
  Future<void> setUnlocked({required String difficult, required int value}) async {
    final isEasy = difficult == DifficultyMode.easy;
    final isMedium = difficult == DifficultyMode.medium;
    final isHard = difficult == DifficultyMode.hard;
    final isDemonic = difficult == DifficultyMode.demonic;
    isEasy ? _easyUnlocked = value : (isMedium ? _mediumUnlocked = value : (isHard ? _hardUnlocked = value : _demonicUnlocked = value));
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${isEasy? 'easy' : (isMedium ? 'medium' : (isHard ? 'hard' : 'demonic'))}Unlocked', value);
  }

  Future<SongCollection?> getSong(String id) async {
    return await SongCollectionService.getSongById(id);
  }

  Future<void> updateSong(String id, SongCollection songCollection) async {
    await SongCollectionService.updateSong(id, songCollection);
  }

}