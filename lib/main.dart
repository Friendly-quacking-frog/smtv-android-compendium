import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return MaterialApp(
        home: MyHomePage(title: 'Demon Compendium'),
        theme: ThemeData.dark()
    );
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
  late Future<List> fissionData;

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

  //read fusion data file
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

  //read reverse fusion data file
  Future<List> loadFissionData() async {
    var data = [];
    var fileData = await rootBundle.loadString('assets/fissionRecipes.csv');
    var readData = fileData.split('\n');
    for (int i=0; i<readData.length; i++){
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
    fissionData = loadFissionData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: <Widget>[
            Container(height: 2),
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
              future: Future.wait([statsData, skillsData, fusionData, fissionData]),
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
                                fissionData: snapshot.data![3][index],
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
                child: Text('Header')
              ),
              ListTile(
                title: const Text('Item 1'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Item 2'),
                onTap: () {
                  Navigator.pop(context);
                }
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
      required this.list,
      required this.skillsList,
      required this.fusionData,
      required this.fissionData})
      : super(key: key);

  var list = [];
  var skillsList = [];
  var fusionData = [];
  var fissionData = [];
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
  var affinityColors = [
    Colors.black,
    Color(0xff7cfc00),
    Color(0xff00ff00),
    Color(0xff00ff7f),
    Color(0xff00fa9a),
    Color(0xff32cd32),
    Color(0xff3cb371),
    Color(0xff2e8b57),
    Color(0xffff4500),
    Color(0xffff6347),
    Color(0xffFF7F50),
    Color(0xffff8c00),
    Colors.orange,
    Color(0xffffa07a),
    Color(0xffFFD700),
  ];
  //return weakness text with color
  Widget weaknessColoredText(String value) {
    TextStyle style = TextStyle();
    switch (value) {
      case 'rs':
        style = const TextStyle(color: Colors.teal);
        break;
      case 'nu':
        style = const TextStyle(color: Colors.white);
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

  Widget affinityColoredText(String value){
    var num = int.parse(value);
    if (num==0) return const Text('');
    else {
      return num > 0 ? Text(value, style: TextStyle(color: affinityColors[num]))
      :Text(value, style: TextStyle(color: affinityColors[15+num]));
    }
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
            children: [
              Image.asset(affinityIcons[i]),
              affinityColoredText(list[i + 17])
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
            Container(
              width: 75,
              child: Column(
                children: [
                  Text('STR:' + list[5], style: GoogleFonts.lato()),
                  Text('VIT:' + list[6], style: GoogleFonts.lato()),
                  Text('MAG:' + list[7], style: GoogleFonts.lato()),
                  Text('AGI:' + list[8], style: GoogleFonts.lato()),
                  Text('LUK:' + list[9], style: GoogleFonts.lato()),
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
                                    fissionData: fissionData,
                                  )));
                    },
                    icon: const Icon(Icons.arrow_forward_ios)
                ),
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
      required this.fusionData,
      required this.fissionData})
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
  var affinityColors = [
    Colors.black,
    Color(0xff7cfc00),
    Color(0xff00ff00),
    Color(0xff00ff7f),
    Color(0xff00fa9a),
    Color(0xff32cd32),
    Color(0xff3cb371),
    Color(0xff2e8b57),
    Color(0xffff4500),
    Color(0xffff6347),
    Color(0xffFF7F50),
    Color(0xffff8c00),
    Colors.orange,
    Color(0xffffa07a),
    Color(0xffFFD700),
  ];
  var ailmentNames = ['Charm', 'Seal', 'Panic', 'Poison', 'Sleep', 'Mirage'];
  var statsData = [];
  var skillsData = [];
  var fusionData = [];
  var fissionData = [];

  Widget weaknessColoredText(String value) {
    TextStyle style = TextStyle();
    switch (value) {
      case 'rs':
        style = const TextStyle(color: Colors.teal);
        break;
      case 'nu':
        style = const TextStyle(color: Colors.white);
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

  Widget affinityColoredText(String value){
    var num = int.parse(value);
    if (num==0) return const Text('');
    else {
      return num > 0 ? Text(value, style: TextStyle(color: affinityColors[num]))
          :Text(value, style: TextStyle(color: affinityColors[15+num]));
    }
  }

  //initialize variables
  void initState() {
    skillsData.removeLast();
    //make list of containers with element weaknesses
    //start at index 10
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
    //make list of containers with skill affinities
    //they start from index 17
    for (int i = 0; i < affinityIcons.length; i++) {
      affinityElementList.add(Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          width: 26,
          child: Column(
            children: [Image.asset(affinityIcons[i]), affinityColoredText(statsData[i + 17])],
          )));
    }
    //make list of containers with ailment information
    //they start from index 28
    for (int i = 0; i < 6; i++) {
      weaknessAilmentList.add(Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: Column(
            children: [
              Text(ailmentNames[i]),
              weaknessColoredText(statsData[i + 28])
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
              fissionData[0][0]=='normal'?Column(
                  children: [
                    Row(
                      children: [
                        const Text('Cost'),
                        Container(width: 70),
                        const Text('Ingredient 1:'),
                        Container(width: 120),
                        const Text('Ingredient 2:')
                      ],
                    ),
                    Divider(
                        thickness: 5
                    ),
                    Expanded(
                        child: ListView.separated(
                            itemCount: fissionData.length-1,
                            itemBuilder: (BuildContext context, int index) {
                              return Row(
                                children: <Widget>[
                                  Column(
                                    children: [
                                      Text(fissionData[index+1][0]),
                                      Container(height: 5),
                                      const Text('Macca')
                                    ],
                                  ),
                                  Container(width: 15),
                                  Container(
                                    width: 145,
                                    child: Column(
                                      children: [
                                        Text(fissionData[index+1][1] + ' LVL: '+ fissionData[index+1][2]),
                                        Container(height: 5),
                                        Text(fissionData[index+1][3] + ' ')
                                      ],
                                    ),
                                  ),
                                  Container(width: 50),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(fissionData[index+1][4] + ' LVL: '+ fissionData[index+1][5]),
                                        Container(height: 5),
                                        Text(fissionData[index+1][6] + ' ')
                                      ],
                                    ),
                                  )
                                ],
                              );
                            }, separatorBuilder: (BuildContext context, int index) => Divider())
                    )
                  ]
              ):
                Column(
                  children: [
                    Text('Special Fusion Recipe'),
                    Row(
                      children: [
                        const Text('Cost'),
                        Container(width: 70),
                        const Text('Ingredient')
                      ],
                    ),
                    Divider(
                        thickness: 5
                    ),
                    Expanded(
                        child: ListView.separated(
                            itemCount: fissionData.length-1,
                            itemBuilder: (BuildContext context, int index) {
                              return Row(
                                children: <Widget>[
                                  Column(
                                    children: [
                                      Text(fissionData[index+1][0]),
                                      Container(height: 5),
                                      const Text('Macca')
                                    ],
                                  ),
                                  Container(width: 15),
                                  Container(
                                    width: 145,
                                    child: Column(
                                      children: [
                                        Text(fissionData[index+1][1] + ' LVL: '+ fissionData[index+1][2]),
                                        Container(height: 5),
                                        Text(fissionData[index+1][3] + ' ')
                                      ],
                                    ),
                                  )
                                ],
                              );
                            }, separatorBuilder: (BuildContext context, int index) => Divider())
                    )
                  ],
                ),
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
            ]),
        )
    );
  }
}
