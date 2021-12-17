import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

List<List<String>> data = [];

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyHomePage(title: 'Demon Compendium'));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List> statsData;
  late Future<List> skillsData;
  late Future<List> fusionData;

  String searchString = '';

  //read stats data file
  Future<List> loadStatsData() async {
    var temp = [];
    var data = await rootBundle.loadString('assets/data.csv');
    temp = data.split('\n');
    var temp2 = [];
    for (int i = 0; i < temp.length; i++) {
      temp2.add(temp[i].split(';'));
    }
    return temp2;
  }

  //read skills data file
  Future<List> loadSkillsList() async {
    var data = [];
    var fileData = await rootBundle.loadString('assets/pages.csv');
    var readData = fileData.split('\n');
    for (int i = 0; i < readData.length; i++) {
      var tempList = [];
      var a = readData[i].split(';');
      for (int j = 0; j < a.length; j++) {
        var b = a[j].split(':');
        tempList.add(b);
      }
      data.add(tempList);
    }
    return data;
  }

  Future<List> loadFusionData() async {
    var data = [];
    var fileData = await rootBundle.loadString('assets/fusionRecipes.csv');
    var readData = fileData.split('\n');
    for (int i = 0; i < readData.length; i++) {
      var tempList = [];
      var a = readData[i].split(';');
      for (int j = 0; j < a.length; j++) {
        var b = a[j].split(':');
        tempList.add(b);
      }
      data.add(tempList);
    }
    return data;
  }

  //initialize variables with read data files
  @override
  void initState() {
    super.initState();
    statsData = loadStatsData();
    skillsData = loadSkillsList();
    fusionData = loadFusionData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: <Widget>[
            TextField(
                onChanged: (value) {
                  setState(() {
                    searchString = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(25.0))))),
            Expanded(
                child: FutureBuilder(
              future: Future.wait([statsData, skillsData, fusionData]),
              builder: (
                BuildContext context,
                AsyncSnapshot<List> snapshot,
              ) {
                Widget child;
                if (snapshot.hasData) {
                  child = ListView.builder(
                      itemCount: snapshot.data?[0].length,
                      itemBuilder: (BuildContext context, int index) {
                        return snapshot.data![0][index][2]
                                .toLowerCase()
                                .contains(searchString)
                            ? MyListItem(
                                list: snapshot.data![0][index],
                                skillsList: snapshot.data![1][index],
                                fusionData: snapshot.data![2][index],
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
        ));
  }
}

class MyListItem extends StatelessWidget {
  MyListItem(
      {Key? key,
      required this.list,
      required this.skillsList,
      required this.fusionData})
      : super(key: key);

  var list = [];
  var skillsList = [];
  var fusionData = [];
  List<Widget> weaknessElementList = [];
  var weaknessIcons = [
    'assets/icons/phy.png',
    'assets/icons/fir.png',
    'assets/icons/ice.png',
    'assets/icons/ele.png',
    'assets/icons/force.png',
    'assets/icons/lig.png',
    'assets/icons/cur.png',
  ];
  List<Widget> affinityElementList = [];
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

  //return weakness text with color
  Widget weaknessColoredText(String value) {
    TextStyle style = TextStyle();
    switch (value) {
      case 'rs':
        style = const TextStyle(color: Colors.teal);
        break;
      case 'nu':
        style = const TextStyle(color: Colors.black);
        break;
      case 'wk':
        style = const TextStyle(color: Colors.redAccent);
        break;
      case 'ab':
        style = const TextStyle(color: Colors.lightGreen);
        break;
      case 'rp':
        style = const TextStyle(color: Colors.lightBlueAccent);
        break;
      default:
        return const Text('');
    }
    return Text(value, style: style);
  }

  //initialize lists of widgets
  void initState() {
    for (int i = 0; i < weaknessIcons.length; i++) {
      weaknessElementList.add(Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          width: 26,
          child: Column(
            children: [
              Image.asset(weaknessIcons[i]),
              weaknessColoredText(list[i + 10])
            ],
          )));
    }
    for (int i = 0; i < affinityIcons.length; i++) {
      affinityElementList.add(Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          width: 26,
          child: Column(
            children: [Image.asset(affinityIcons[i]), Text(list[i + 17])],
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
                      Text(list[0], style: const TextStyle(fontSize: 15)),
                      Container(width: 20),
                      Text('LVL:' + list[1],
                          style: const TextStyle(fontSize: 15))
                    ],
                  ),
                  Row(
                    children: [
                      Text(list[2], style: const TextStyle(fontSize: 18))
                    ],
                  )
                ],
              )),
          Column(
            children: [
              Container(height: 8),
              Row(
                children: [Text('HP:' + list[3])],
              ),
              Row(
                children: [Text('MP:' + list[4])],
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
            Column(
              children: [
                Text('STR:' + list[5]),
                Text('VIT:' + list[6]),
                Text('MAG:' + list[7]),
                Text('AGI:' + list[8]),
                Text('LUK:' + list[9]),
              ],
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailedPage(
                                    statsData: list,
                                    skillsData: skillsList,
                                    fusionData: fusionData,
                                  )));
                    },
                    icon: const Icon(Icons.arrow_forward_ios)),
              ],
            )
          ],
        )
      ],
    );
  }
}

class DetailedPage extends StatelessWidget {
  DetailedPage(
      {Key? key,
      required this.statsData,
      required this.skillsData,
      required this.fusionData})
      : super(key: key);

  List<Widget> weaknessElementList = [];
  List<Widget> affinityElementList = [];
  List<Widget> weaknessAilmentList = [];
  List<List<Widget>> skillInfo = [];
  String fissionSearch = '';
  String fusionSearch = '';

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
  var ailmentNames = ['Charm', 'Seal', 'Panic', 'Poison', 'Sleep', 'Mirage'];
  var statsData = [];
  var skillsData = [];
  var fusionData = [];

  Widget weaknessColoredText(String value) {
    TextStyle style = TextStyle();
    switch (value) {
      case 'rs':
        style = const TextStyle(color: Colors.teal);
        break;
      case 'nu':
        style = const TextStyle(color: Colors.black);
        break;
      case 'wk':
        style = const TextStyle(color: Colors.redAccent);
        break;
      case 'ab':
        style = const TextStyle(color: Colors.lightGreen);
        break;
      case 'rp':
        style = const TextStyle(color: Colors.lightBlueAccent);
        break;
      default:
        return const Text('');
    }
    return Text(value, style: style);
  }

  //initialize variables
  void initState() {
    skillsData.removeLast();
    for (int i = 0; i < weaknessIcons.length; i++) {
      weaknessElementList.add(Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          width: 26,
          child: Column(
            children: [
              Image.asset(weaknessIcons[i]),
              weaknessColoredText(statsData[i + 10])
            ],
          )));
    }
    for (int i = 0; i < affinityIcons.length; i++) {
      affinityElementList.add(Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          width: 26,
          child: Column(
            children: [Image.asset(affinityIcons[i]), Text(statsData[i + 17])],
          )));
    }
    for (int i = 0; i < 6; i++) {
      weaknessAilmentList.add(Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: Column(
            children: [
              Text(ailmentNames[i]),
              weaknessColoredText(statsData[i + 27])
            ],
          )));
    }
    for (int i = 0; i < skillsData.length; i++) {
      List<Widget> temp = [];
      temp.add(Image.asset('assets/icons/' + skillsData[i][0] + '.png'));
      for (int j = 1; j < skillsData[i].length; j++) {
        temp.add(Text(skillsData[i][j]));
        temp.add(Container(width: 2));
      }
      temp.removeLast();
      skillInfo.add(temp);
    }
  }

  @override
  Widget build(BuildContext context) {
    initState();
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Detailed Data'),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.format_list_bulleted)),
                  Tab(icon: Icon(Icons.call_merge)),
                  Tab(icon: Icon(Icons.call_split))
                ],
              ),
            ),
            body: TabBarView(children: [
              Center(
                  child: Column(
                children: [
                  Container(height: 30),
                  Text(statsData[2], style: const TextStyle(fontSize: 35)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Race: ' + statsData[0]),
                      Container(width: 10),
                      Text('LVL: ' + statsData[1]),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('HP: ' + statsData[3]),
                      Container(width: 20),
                      Text('MP: ' + statsData[4])
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('STR:' + statsData[5]),
                      Container(width: 5),
                      Text('VIT:' + statsData[6]),
                      Container(width: 5),
                      Text('MAG:' + statsData[7])
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('AGI:' + statsData[8]),
                      Container(width: 5),
                      Text('LUK:' + statsData[9])
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Element weakness',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: weaknessElementList,
                      )
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Skill affinity',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: affinityElementList,
                      )
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Ailment weakness',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: weaknessAilmentList,
                      )
                    ],
                  ),
                  Expanded(
                      child: ListView.separated(
                          itemCount: skillsData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ExpansionTile(
                              title: Row(
                                children: [
                                  skillInfo[index][0],
                                  skillInfo[index][1],
                                  skillInfo[index][2],
                                  skillInfo[index][3]
                                ],
                              ),
                              children: [
                                skillInfo[index][5],
                                skillInfo[index][6],
                                skillInfo[index][7],
                              ],
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider()))
                ],
              )),
              Center(child: Text('Possible fissions')),
              Column(
                children: [
                  Row(
                      children: [
                        const Text('Cost'),
                        Container(width: 70),
                        const Text('Ingredient 2:'),
                        Container(width: 120),
                        const Text('Result')
                      ],
                  ),
                  Divider(
                    thickness: 5
                  ),
                  Expanded(
                      child: ListView.separated(
                          itemCount: fusionData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Row(
                              children: <Widget>[
                                Column(
                                  children: [
                                    Text(fusionData[index][0]),
                                    Container(height: 5),
                                    const Text('Macca')
                                  ],
                                ),
                                Container(width: 15),
                                Container(
                                  width: 145,
                                  child: Column(
                                    children: [
                                      Text(fusionData[index][1] + ' LVL: '+ fusionData[index][2]),
                                      Container(height: 5),
                                      Text(fusionData[index][3] + ' ')
                                    ],
                                  ),
                                ),
                                Container(width: 50),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(fusionData[index][4] + ' LVL: '+ fusionData[index][5]),
                                      Container(height: 5),
                                      Text(fusionData[index][6] + ' ')
                                    ],
                                  ),
                                )
                              ],
                            );
                          }, separatorBuilder: (BuildContext context, int index) => Divider())
                  )
                ],
              )
            ])));
  }
}
