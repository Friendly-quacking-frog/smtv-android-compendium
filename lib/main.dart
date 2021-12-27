import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

List<List<String>> data = [];

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  late Storage storage;

  @override
  Widget build(BuildContext context) {
    storage = Storage();
    return MaterialApp(
        home: MyHomePage(storage: storage),
        theme: ThemeData.dark()
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.storage}) : super(key: key);
  final Storage storage;

  @override
  State<MyHomePage> createState() => _MyHomePageState(storage: storage);
}

class DemonStats {
  final String name;
  final List<int> affinities;
  final List<int> stats;
  final String aliments;
  final int level;
  final int price;
  final String race;
  final String resists;
  final Map<String, dynamic> skills;

  DemonStats(
      { required this.name,
        required this.affinities,
        required this.stats,
        required this.aliments,
        required this.level,
        required this.price,
        required this.race,
        required this.resists,
        required this.skills
      });

  factory DemonStats.fromJson(String demonName, Map<String, dynamic> json)=> DemonStats(
        name : demonName,
        affinities: json['affinities'].cast<int>(),
        aliments: json['aliments'],
        level: json['lvl'],
        price: json['price'],
        race: json['race'],
        resists: json['resists'],
        skills: json['skills'],
        stats: json['stats'].cast<int>()
    );

}

class Storage {

  late Future<List> futureStatsList;
  List<DemonStats> statsList = [];
  late Future<List> futurePagesList;
  List _pagesList = [];
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

  void readJSON() async {
    var data = await rootBundle.loadString('assets/data/demon-data.json');
    data = data.trim();
    Map <String, dynamic> temp = jsonDecode(data);
    print(temp.entries.toString());
  }

  //read stats data file
  Future<List> _makeStatsList() async {
    var tempData = [];
    var data = await rootBundle.loadString('assets/data/demon-data.json');
    Map<String, dynamic> temp = jsonDecode(data);
    var names = temp.entries;
    names.forEach((element) {
      DemonStats stat = DemonStats.fromJson(element.key, element.value);
      tempData.add(stat);
    });
    return tempData;
  }

  //read skills data file
  Future<List> _makePagesList() async {
    var data = [];
    var fileData = await rootBundle.loadString('assets/pages.csv');
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
      tempList.removeLast();
      data.add(tempList);
    }
    return data;
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

  //return index of demon based on its name

  List pagesFromName(String name){
    var list =[];
    for (int i=0; i< _pagesList.length; i++){
      if (_pagesList[i][0][0]==name){
        return _pagesList[i].sublist(1);
      }
    }
    return list;
  }

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
    readJSON();
    futureStatsList = _makeStatsList();
    futurePagesList = _makePagesList();
    futureFusionList = _makeFusionList();
    futureFissionList = _makeFissionList();
    futureStatsList.then((value) => {
      statsList = value.cast<DemonStats>()
    });
    futurePagesList.then((value) => {
      _pagesList = value
    });
    futureFusionList.then((value) => {
      _fusionList = value
    });
    futureFissionList.then((value) => {
      _fissionList = value
    });
  }
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState({required this.storage});
  String searchString = '';
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Demon stats');
  Storage storage;
  String sortStr = '';

  //initialize variables with read data files
  @override
  void initState() {
    super.initState();
  }

  void sortList(String type){
    print(type);
    print(sortStr);
    switch(type){
      case 'race':
        if (sortStr=='rn') {
          storage.statsList.sort((a, b) => a.race.compareTo(b.race));
          storage.statsList = storage.statsList.reversed.toList();
          sortStr = 'rr';
        } else {
          storage.statsList.sort((a, b) => a.race.compareTo(b.race));
          sortStr = 'rn';
        }
        setState(() {});
        break;
      case 'name':
        if (sortStr=='nn') {
          storage.statsList.sort((a, b) => a.name.compareTo(b.name));
          storage.statsList = storage.statsList.reversed.toList();
          sortStr = 'nr';
        } else {
          storage.statsList.sort((a, b) => a.name.compareTo(b.name));
          sortStr = 'nn';
        }
        setState(() {});
        break;
      case 'level':
        if (sortStr=='ln') {
          storage.statsList.sort((a, b) => a.level.compareTo(b.level));
          storage.statsList = storage.statsList.reversed.toList();
          sortStr = 'lr';
        } else {
          storage.statsList.sort((a, b) => a.level.compareTo(b.level));
          sortStr = 'ln';
        }
        setState(() {});
        break;
      default:
        setState(() {});
        break;
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: customSearchBar,
          actions: [
            IconButton(
              icon: customIcon,
              onPressed: () {
                setState(() {
                  if (customIcon.icon == Icons.search){
                    customIcon = const Icon(Icons.cancel);
                    customSearchBar = ListTile(
                      title: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Enter demon name...',
                          border: InputBorder.none
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchString = value.toLowerCase();
                          });
                        },
                      )
                    );
                  } else {
                    customIcon = const Icon(Icons.search);
                    customSearchBar = const Text('Demon stats');
                    searchString = '';
                  }
                });
              },
            ),
            PopupMenuButton<String>(
              onSelected: (String result) {setState(() {
                sortList(result);
              }); },
              icon: const Icon(Icons.sort),
              itemBuilder: (context) => <PopupMenuEntry<String>>[
                const PopupMenuItem(
                    value: 'race',
                    child: Text('Race')
                ),
                const PopupMenuItem(
                    value: 'name',
                    child: Text('Name')
                ),
                const PopupMenuItem(
                    value: 'level',
                    child: Text('Level')
                )
              ]
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: FutureBuilder(
              future: Future.wait([
                                storage.futureStatsList,
                                storage.futurePagesList,
                                storage.futureFissionList,
                                storage.futureFusionList
                              ]),
              builder: (
                BuildContext context,
                AsyncSnapshot<List> snapshot,
              ) {
                Widget child;
                if (snapshot.hasData) {
                  child = ListView.builder(
                      itemCount: snapshot.data?[0].length,
                      itemBuilder: (BuildContext context, int index) {
                        return snapshot.data![0][index].name
                                .toLowerCase()
                                .contains(searchString.toLowerCase())
                            ? MyListItem(
                                storage: storage,
                                givenIndex: index,
                              )
                            : Container();
                      });
                } else if (snapshot.hasError) {
                  child = const Text('Error');
                } else {
                  child = Center(
                    child: ListView(children: const [Text("Loading...")]),
                  );
                }
                return Center(child: child);
              },
            ))
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                    color: Colors.orange
                ),
                child: Text('Demon Compendium')
              ),
              ListTile(
                title: const Text('Stats'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Skills'),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                      builder: (context) => SkillsList(storage: storage,)
                    )
                  );
                },
              ),
            ],
          ),
        ),
    );
  }
}

class MyListItem extends StatelessWidget {
  MyListItem(
      {Key? key,
        required this.storage,
        required this.givenIndex})
      : super(key: key);

  Storage storage;
  int givenIndex;

  List<Widget> weaknessElementList = [];
  List<Widget> affinityElementList = [];

  List<String> weaknessIcons = [];
  List<String> affinityIcons = [];
  List<Color> affinityColors = [];

  //return weakness text with color
  Widget weaknessColoredText(String value) {
    TextStyle style = const TextStyle();
    switch (value) {
      case 's':
        style = const TextStyle(color: Colors.teal);
        return Text('rs', style: style);
      case 'n':
        style = const TextStyle(color: Colors.blue);
        return Text('nu', style: style);
      case 'w':
        style = const TextStyle(color: Colors.redAccent);
        return Text('wk', style: style);
      case 'd':
        style = const TextStyle(color: Colors.lightGreen);
        return Text('ab', style: style);
      case 'r':
        style = const TextStyle(color: Colors.lightBlueAccent);
        return Text('rp', style: style);
      default:
        return const Text('');
    }
  }

  Widget affinityColoredText(int value){
    if (value==0) {
      return const Text('');
    } else {
      return value > 0 ? Text(value.toString(), style: TextStyle(color: affinityColors[value]))
          :Text(value.toString(), style: TextStyle(color: affinityColors[15+value]));
    }
  }

  //initialize lists of widgets
  void initState() {
    affinityColors = storage.affinityColors;
    affinityIcons = storage.affinityIcons;
    weaknessIcons = storage.weaknessIcons;

    for (int i = 0; i < weaknessIcons.length; i++) {
      weaknessElementList.add(Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          width: 26,
          child: Column(
            children: [
              Image.asset(weaknessIcons[i]),
              weaknessColoredText(storage.statsList[givenIndex].resists[i])
            ],
          )));
    }
    for (int i = 0; i < affinityIcons.length; i++) {
      affinityElementList.add(Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          width: 26,
          child: Column(
            children: [
              Image.asset(affinityIcons[i]),
              affinityColoredText(storage.statsList[givenIndex].affinities[i])
            ],
          )));
    }
  }

  @override
  Widget build(BuildContext context) {
    initState();
    return ExpansionTile(
      title: Row(
        children: [
          SizedBox(
              width: 175,
              child: Column(
                children: [
                  Container(height: 8),
                  Row(
                    children: [
                      Text(storage.statsList[givenIndex].race, style: const TextStyle(fontSize: 15)),
                      Container(width: 20),
                      Text('LVL:' + storage.statsList[givenIndex].level.toString(),
                          style: const TextStyle(fontSize: 15))
                    ],
                  ),
                  Row(
                    children: [
                      Text(storage.statsList[givenIndex].name, style: const TextStyle(fontSize: 18))
                    ],
                  )
                ],
              )),
          Column(
            children: [
              Container(height: 8),
              Row(
                children: [Text('HP:' + storage.statsList[givenIndex].stats[0].toString())],
              ),
              Row(
                children: [Text('MP:' + storage.statsList[givenIndex].stats[1].toString())],
              )
            ],
          ),
          Container()
        ],
      ),
      children: [
        Row(
          children: [
            //stats info
            SizedBox(
                width: 75,
                child: Column(
                  children: [
                    Text('STR:' + storage.statsList[givenIndex].stats[2].toString(), style: GoogleFonts.lato()),
                    Text('VIT:' + storage.statsList[givenIndex].stats[3].toString(), style: GoogleFonts.lato()),
                    Text('MAG:' + storage.statsList[givenIndex].stats[4].toString(), style: GoogleFonts.lato()),
                    Text('AGI:' + storage.statsList[givenIndex].stats[5].toString(), style: GoogleFonts.lato()),
                    Text('LUK:' + storage.statsList[givenIndex].stats[6].toString(), style: GoogleFonts.lato()),
                  ],
                )
            ),
            Column(
              children: [
                //weakness info
                Row(
                  children: const [Text('Weaknesses')],
                ),
                Row(children: weaknessElementList),
                //affinity info
                Row(
                  children: const [Text('Affinities')],
                ),
                Row(children: affinityElementList)
              ],
            ),
            Expanded(
              child: IconButton(
                  onPressed: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => DetailedPage(
                    //           storage: storage,
                    //           ind: givenIndex,
                    //         )));
                  },
                  icon: const Icon(Icons.arrow_forward_ios)
              ),
            )
          ],
        )
      ],
    );
  }
}

// class DetailedPage extends StatelessWidget {
//   DetailedPage(
//       {Key? key,
//         required this.storage,
//         required this.ind})
//       : super(key: key);
//
//   Storage storage;
//   int ind;
//   List<Widget> weaknessElementList = [];
//   List<Widget> affinityElementList = [];
//   List<Widget> weaknessAilmentList = [];
//   List<List<Widget>> skillInfo = [];
//   String fissionSearch = '';
//   String fusionSearch = '';
//
//   var ailmentNames = ['Charm', 'Seal', 'Panic', 'Poison', 'Sleep', 'Mirage'];
//   var statsData = [];
//   var skillsData = [];
//   var fusionData = [];
//   var fissionData = [];
//   var affinityColors = [];
//   var weaknessIcons = [];
//   var affinityIcons = [];
//
//
//   Widget weaknessColoredText(String value) {
//     TextStyle style = const TextStyle();
//     switch (value) {
//       case 'rs':
//         style = const TextStyle(color: Colors.teal);
//         break;
//       case 'nu':
//         style = const TextStyle(color: Colors.blue);
//         break;
//       case 'wk':
//         style = const TextStyle(color: Colors.redAccent);
//         break;
//       case 'ab':
//         style = const TextStyle(color: Colors.lightGreen);
//         break;
//       case 'rp':
//         style = const TextStyle(color: Colors.lightBlueAccent);
//         break;
//       default:
//         return const Text('');
//     }
//     return Text(value, style: style);
//   }
//
//   Widget affinityColoredText(String value){
//     var num = int.parse(value);
//     if (num==0) {
//       return const Text('');
//     } else {
//       return num > 0 ? Text(value, style: TextStyle(color: affinityColors[num]))
//           :Text(value, style: TextStyle(color: affinityColors[15+num]));
//     }
//   }
//
//   //initialize variables
//   void initState() {
//     statsData = storage.statsList[ind];
//     skillsData = storage.pagesFromName(statsData[2]);
//     fusionData = storage.fusionFromName(statsData[2]);
//     fissionData = storage.fissionFromName(statsData[2]);
//     affinityColors = storage.affinityColors;
//     weaknessIcons = storage.weaknessIcons;
//     affinityIcons = storage.affinityIcons;
//     //make list of containers with element weaknesses
//     //start at index 10
//     for (int i = 0; i < weaknessIcons.length; i++) {
//       weaknessElementList.add(Container(
//           decoration: BoxDecoration(border: Border.all(color: Colors.black)),
//           width: 26,
//           child: Column(
//             children: [
//               Image.asset(weaknessIcons[i]),
//               weaknessColoredText(statsData[i + 10])
//             ],
//           )));
//     }
//     //make list of containers with skill affinities
//     //they start from index 17
//     for (int i = 0; i < affinityIcons.length; i++) {
//       affinityElementList.add(Container(
//           decoration: BoxDecoration(border: Border.all(color: Colors.black)),
//           width: 26,
//           child: Column(
//             children: [Image.asset(affinityIcons[i]), affinityColoredText(statsData[i + 17])],
//           )));
//     }
//     //make list of containers with ailment information
//     //they start from index 28
//     for (int i = 0; i < 6; i++) {
//       weaknessAilmentList.add(Container(
//           decoration: BoxDecoration(border: Border.all(color: Colors.black)),
//           child: Column(
//             children: [
//               Text(ailmentNames[i]),
//               weaknessColoredText(statsData[i + 28])
//             ],
//           )));
//     }
//     for (int i = 0; i < skillsData.length; i++) {
//       List<Widget> temp = [];
//       temp.add(Image.asset('assets/icons/' + skillsData[i][0] + '.png'));
//       for (int j = 1; j < skillsData[i].length; j++) {
//         temp.add(Text(skillsData[i][j]));
//         temp.add(Container(width: 2));
//       }
//       temp.removeLast();
//       skillInfo.add(temp);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     initState();
//     return DefaultTabController(
//         length: 3,
//         child: Scaffold(
//           appBar: AppBar(
//             title: const Text('Detailed Data'),
//             bottom: const TabBar(
//               tabs: [
//                 Tab(icon: Icon(Icons.format_list_bulleted)),
//                 Tab(icon: Icon(Icons.call_merge)),
//                 Tab(icon: Icon(Icons.call_split))
//               ],
//             ),
//           ),
//           body: TabBarView(children: [
//             Center(
//                 child: Column(
//                   children: [
//                     Container(height: 30),
//                     Text(statsData[2], style: const TextStyle(fontSize: 35)),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text('Race: ' + statsData[0]),
//                         Container(width: 10),
//                         Text('LVL: ' + statsData[1]),
//                       ],
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text('HP: ' + statsData[3]),
//                         Container(width: 20),
//                         Text('MP: ' + statsData[4])
//                       ],
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text('STR:' + statsData[5]),
//                         Container(width: 5),
//                         Text('VIT:' + statsData[6]),
//                         Container(width: 5),
//                         Text('MAG:' + statsData[7])
//                       ],
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text('AGI:' + statsData[8]),
//                         Container(width: 5),
//                         Text('LUK:' + statsData[9])
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         const Text('Element weakness',
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: weaknessElementList,
//                         )
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         const Text('Skill affinity',
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: affinityElementList,
//                         )
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         const Text('Ailment weakness',
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: weaknessAilmentList,
//                         )
//                       ],
//                     ),
//                     Expanded(
//                         child: ListView.separated(
//                             itemCount: skillsData.length,
//                             itemBuilder: (BuildContext context, int index) {
//                               return ExpansionTile(
//                                 title: Row(
//                                   children: [
//                                     skillInfo[index][0],
//                                     skillInfo[index][1],
//                                     skillInfo[index][2],
//                                     skillInfo[index][3]
//                                   ],
//                                 ),
//                                 children: [
//                                   skillInfo[index][5],
//                                   skillInfo[index][6],
//                                   skillInfo[index][7],
//                                 ],
//                               );
//                             },
//                             separatorBuilder: (BuildContext context, int index) =>
//                                 const Divider()))
//                   ],
//                 )),
//             fissionData[0][0]=='normal'?Column(
//                 children: [
//                   Row(
//                     children: [
//                       const Text('Cost'),
//                       Container(width: 70),
//                       const Text('Ingredient 1:'),
//                       Container(width: 120),
//                       const Text('Ingredient 2:')
//                     ],
//                   ),
//                   const Divider(
//                       thickness: 5
//                   ),
//                   Expanded(
//                       child: ListView.separated(
//                           itemCount: fissionData.length-1,
//                           itemBuilder: (BuildContext context, int index) {
//                             return Row(
//                               children: <Widget>[
//                                 Column(
//                                   children: [
//                                     Text(fissionData[index+1][0]),
//                                     Container(height: 5),
//                                     const Text('Macca')
//                                   ],
//                                 ),
//                                 Container(width: 15),
//                                 InkWell(
//                                   child: SizedBox(
//                                     width: 145,
//                                     child: Column(
//                                       children: [
//                                         Text(fissionData[index+1][1] + ' LVL: '+ fissionData[index+1][2]),
//                                         Container(height: 5),
//                                         Text(fissionData[index+1][3] + ' ')
//                                       ],
//                                     ),
//                                   ),
//                                   onTap:() => Navigator.pushReplacement(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) => DetailedPage(
//                                               storage: storage,
//                                               ind: storage.indexFromName(fissionData[index+1][3])
//                                           )
//                                       )
//                                   ),
//                                 ),
//                                 Container(width: 50),
//                                 Expanded(
//                                     child: InkWell(
//                                       child: Column(
//                                         children: [
//                                           Text(fissionData[index+1][4] + ' LVL: '+ fissionData[index+1][5]),
//                                           Container(height: 5),
//                                           Text(fissionData[index+1][6] + ' ')
//                                         ],
//                                       ),
//                                       onTap:() => Navigator.pushReplacement(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) => DetailedPage(
//                                                   storage: storage,
//                                                   ind: storage.indexFromName(fissionData[index+1][6])
//                                               )
//                                           )
//                                       ),
//                                     )
//                                 )
//                               ],
//                             );
//                           }, separatorBuilder: (BuildContext context, int index) => const Divider())
//                   )
//                 ]
//             ):
//             Column(
//               children: [
//                 const Text('Special Fusion Recipe'),
//                 Row(
//                   children: [
//                     const Text('Cost'),
//                     Container(width: 70),
//                     const Text('Ingredient')
//                   ],
//                 ),
//                 const Divider(
//                     thickness: 5
//                 ),
//                 Expanded(
//                     child: ListView.separated(
//                         itemCount: fissionData.length-1,
//                         itemBuilder: (BuildContext context, int index) {
//                           return Row(
//                             children: <Widget>[
//                               Column(
//                                 children: [
//                                   Text(fissionData[index+1][0]),
//                                   Container(height: 5),
//                                   const Text('Macca')
//                                 ],
//                               ),
//                               Container(width: 15),
//                               InkWell(
//                                   child: SizedBox(
//                                     width: 145,
//                                     child: Column(
//                                       children: [
//                                         Text(fissionData[index+1][1] + ' LVL: '+ fissionData[index+1][2]),
//                                         Container(height: 5),
//                                         Text(fissionData[index+1][3] + ' ')
//                                       ],
//                                     ),
//                                   ),
//                                   onTap:() => Navigator.pushReplacement(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) => DetailedPage(
//                                               storage: storage,
//                                               ind: storage.indexFromName(fissionData[index+1][3])
//                                           )
//                                       )
//                                   )
//                               )
//                             ],
//                           );
//                         }, separatorBuilder: (BuildContext context, int index) => const Divider())
//                 )
//               ],
//             ),
//             Column(
//               children: [
//                 Row(
//                   children: [
//                     const Text('Cost'),
//                     Container(width: 70),
//                     const Text('Ingredient 2:'),
//                     Container(width: 120),
//                     const Text('Result')
//                   ],
//                 ),
//                 const Divider(
//                     thickness: 5
//                 ),
//                 Expanded(
//                     child: ListView.separated(
//                         itemCount: fusionData.length,
//                         itemBuilder: (BuildContext context, int index) {
//                           return Row(
//                             children: <Widget>[
//                               Column(
//                                 children: [
//                                   Text(fusionData[index][0]),
//                                   Container(height: 5),
//                                   const Text('Macca')
//                                 ],
//                               ),
//                               Container(width: 15),
//                               InkWell(
//                                   child: SizedBox(
//                                     width: 145,
//                                     child: Column(
//                                       children: [
//                                         Text(fusionData[index][1] + ' LVL: '+ fusionData[index][2]),
//                                         Container(height: 5),
//                                         Text(fusionData[index][3] + ' ')
//                                       ],
//                                     ),
//                                   ),
//                                   onTap:() => Navigator.pushReplacement(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) => DetailedPage(
//                                               storage: storage,
//                                               ind: storage.indexFromName(fusionData[index][3])
//                                           )
//                                       )
//                                   )
//                               ),
//                               Container(width: 50),
//                               Expanded(
//                                 child: InkWell(
//                                     child: Column(
//                                       children: [
//                                         Text(fusionData[index][4] + ' LVL: '+ fusionData[index][5]),
//                                         Container(height: 5),
//                                         Text(fusionData[index][6] + ' ')
//                                       ],
//                                     ),
//                                     onTap: () => Navigator.pushReplacement(
//                                         context,
//                                         MaterialPageRoute(
//                                             builder: (context) => DetailedPage(
//                                                 storage: storage,
//                                                 ind: storage.indexFromName(fusionData[index][6])
//                                             )
//                                         )
//                                     )
//                                 ),
//                               )
//                             ],
//                           );
//                         }, separatorBuilder: (BuildContext context, int index) => const Divider())
//                 )
//               ],
//             )
//           ]),
//         )
//     );
//   }
// }

class SkillsList extends StatefulWidget{
  SkillsList({Key? key, required this.storage}) : super(key: key);

  Storage storage;

  @override
  State<StatefulWidget> createState() => _SkillsList(storage: storage);
}

class _SkillsList extends State<SkillsList>{
  _SkillsList({required this.storage});

  Storage storage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skills'),
      ),
      body: const Text('Future skills list'),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
                decoration: BoxDecoration(
                    color: Colors.orange
                ),
                child: Text('Demon compendium')
            ),
            ListTile(
              title: const Text('Stats'),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(
                        builder: (context) => MyHomePage(storage: storage)
                    )
                );
              },
            ),
            ListTile(
              title: const Text('Skills'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

}
