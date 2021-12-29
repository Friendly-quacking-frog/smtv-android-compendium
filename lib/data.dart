import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DemonStats {
  final String name;
  final List<int> affinities;
  final List<int> stats;
  String ailments;
  final int level;
  final int price;
  final String race;
  final String resists;
  final Map<String, dynamic> skills;

  String _getAilments(String? value){
    if (value == null){
      return '------';
    } else {
      return value;
    }
  }

  void normalize(){
    ailments = _getAilments(ailments);
  }

  DemonStats(
      { required this.name,
        required this.affinities,
        required this.stats,
        required this.ailments,
        required this.level,
        required this.price,
        required this.race,
        required this.resists,
        required this.skills, cost, effect
      });

  factory DemonStats.fromJson(String demonName, Map<String, dynamic> json)=> DemonStats(
      name : demonName,
      affinities: json['affinities'].cast<int>(),
      ailments: json['ailments'],
      level: json['lvl'],
      price: json['price'],
      race: json['race'],
      resists: json['resists'],
      skills: json['skills'],
      stats: json['stats'].cast<int>()
  );

}

class SkillData {
  final String name;
  final String effect;
  final String element;
  String target;
  int rank;
  int cost;

  SkillData(
      { required this.name,
        required this.effect,
        required this.element,
        required this.target,
        required this.cost,
        required this.rank,
      });

  int _getCost(int? cost){
    if (cost is! int){
      return 0;
    } else {
      if (cost > 2000) {
        return 1000;
      } else {
        return cost%1000;
      }
    }
  }

  String _getTarget(String? value){
    if (value != null){
      return value;
    }
    return 'self';
  }

  int _getRank(int? value){
    if (value is! int){
      return 0;
    } else {
      return value;
    }
  }

  void normalize(){
    cost = _getCost(cost);
    target = _getTarget(target);
    rank = _getRank(rank);
  }

  factory SkillData.fromJson(String skillName, Map<String, dynamic> json) => SkillData(
      name: skillName,
      effect: json['effect'],
      element: json['element'],
      target: json['target'],
      cost: json['cost'],
      rank: json['rank']
  );

}

class SpecialFusion {
  List recipe = [];
  String prereq = '';

  SpecialFusion(List rec, String pre){
    recipe = rec;
    prereq = pre;
  }
}

class Storage {

  late Future<List> futureStatsList;
  List<DemonStats> statsList = [];
  late Future<List> futureSkillsList;
  List<SkillData> _skillsList = [];
  Map<String, SpecialFusion> specialFusions = {};
  late Future<List> futureFissionList;
  List _fissionList = [];
  late Future<List> futureFusionList;
  List _fusionList = [];
  Set<String> races = {};

  var affinityColors = [
    Colors.black,
    const Color(0xff7cfc00),
    const Color(0xff00ff00),
    const Color(0xff00ff7f),
    const Color(0xff00fa9a),
    const Color(0xff32cd32),
    const Color(0xff3cb371),
    const Color(0xff2e8b57),
    const Color(0xffff4500),
    const Color(0xffff6347),
    const Color(0xffFF7F50),
    const Color(0xffff8c00),
    Colors.orange,
    const Color(0xffffa07a),
    const Color(0xffFFD700),
  ];
  var affinityIcons = [
    'assets/icons/phy.png',
    'assets/icons/fir.png',
    'assets/icons/ice.png',
    'assets/icons/ele.png',
    'assets/icons/force.png',
    'assets/icons/lig.png',
    'assets/icons/cur.png',
    'assets/icons/alm.png',
    'assets/icons/ail.png',
    'assets/icons/rec.png',
    'assets/icons/sup.png',
  ];
  var weaknessIcons = [
    'assets/icons/phy.png',
    'assets/icons/fir.png',
    'assets/icons/ice.png',
    'assets/icons/ele.png',
    'assets/icons/force.png',
    'assets/icons/lig.png',
    'assets/icons/cur.png',
  ];

  void readJson() async {

  }

  DemonStats getDemonByName(String name){
    for (int i=0; i<statsList.length; i++){
      if(statsList[i].name == name){
        return statsList[i];
      }
    }
    return DemonStats(
        name: 'none',
        affinities: [],
        stats: [],
        ailments: 'none',
        level: 0,
        price: 0,
        race: 'none',
        resists: 'none',
        skills: {}
    );
  }

  SkillData getSkillByName(String name){
    for (int i=0; i< _skillsList.length; i++){
      if(_skillsList[i].name==name){
        return _skillsList[i];
      }
    }
    return SkillData(name: '', effect: '', element: '', target: '', cost: 0, rank: 0);
  }

  //read stats data file
  Future<List> _makeStatsList() async {
    var tempData = [];
    var data = await rootBundle.loadString('assets/data/demon-data.json');
    Map<String, dynamic> temp = jsonDecode(data);
    var names = temp.entries;
    for (var element in names) {
      DemonStats stat = DemonStats.fromJson(element.key, element.value);
      stat.normalize();
      tempData.add(stat);
    }
    return tempData;
  }

  //read skills data file
  Future<List> _makeSkillsList() async {
    var tempData = [];
    var data = await rootBundle.loadString('assets/data/skill-data.json');
    Map<String, dynamic> temp = jsonDecode(data);
    var names = temp.entries;
    for (var element in names) {
      SkillData stat = SkillData.fromJson(element.key, element.value);
      stat.normalize();
      tempData.add(stat);
    }
    return tempData;
  }

  //read fusion data file
  Future<List> _makeFusionList() async {
    var data = [];
    var fileData = await rootBundle.loadString('assets/fusionRecipes.csv');
    var readData = fileData.split('\n');
    for (int i = 0; i < readData.length; i++) {
      var tempList = [];
      var a = readData[i].split(';');
      for (int j = 0; j < a.length; j++) {
        var b = a[j].split(':');
        for (int k=0; k<b.length; k++){
          b[k] = b[k].trim();
        }
        tempList.add(b);
      }
      data.add(tempList);
    }
    return data;
  }

  //read reverse fusion data file
  Future<List> _makeFissionList() async {
    var data = [];
    var fileData = await rootBundle.loadString('assets/fissionRecipes.csv');
    var readData = fileData.split('\n');
    for (int i=0; i<readData.length; i++){
      var tempList = [];
      var a = readData[i].split(';');
      for (int j = 0; j < a.length; j++) {
        var b = a[j].split(':');
        for (int k=0; k<b.length; k++){
          b[k] = b[k].trim();
        }
        tempList.add(b);
      }
      data.add(tempList);
    }
    return data;
  }

  Future<Map<String, SpecialFusion>> _loadSpecialFusions() async {
    Map<String, SpecialFusion> result = {};
    var data = await rootBundle.loadString('assets/data/special-recipes.json');
    Map<String, dynamic> recipes = jsonDecode(data);
    data = await rootBundle.loadString('assets/data/fusion-prereqs.json');
    Map<String, dynamic> prereqs = jsonDecode(data);
    var recipe = recipes.entries;
    for (var entry in recipe){
      SpecialFusion temp = SpecialFusion(entry.value, prereqs[entry.key]);
      result[entry.key] = temp;
    }
    return result;
  }

  //return index of demon based on its name

  List fissionFromName(String name){
    var list =[];
    for (int i=0; i< _fissionList.length; i++){
      if (_fissionList[i][0][0]==name){
        return _fissionList[i].sublist(1);
      }
    }
    return list;
  }

  List fusionFromName(String name){
    var list =[];
    for (int i=0; i< _fusionList.length; i++){
      if (_fusionList[i][0][0]==name){
        return _fusionList[i].sublist(1);
      }
    }
    return list;
  }

  Storage() {
    readJson();
    futureStatsList = _makeStatsList();
    futureSkillsList = _makeSkillsList();
    futureFusionList = _makeFusionList();
    futureFissionList = _makeFissionList();
    _loadSpecialFusions().then((value) => {
      specialFusions = value
    });
    futureStatsList.then((value) => {
      statsList = value.cast<DemonStats>()
    });
    futureSkillsList.then((value) => {
      _skillsList = value.cast<SkillData>()
    });
    futureFusionList.then((value) => {
      _fusionList = value
    });
    futureFissionList.then((value) => {
      _fissionList = value
    });
  }
}
