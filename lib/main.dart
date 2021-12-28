import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'data.dart';

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
        home: MyHomePage(storage: storage), theme: ThemeData.dark());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.storage}) : super(key: key);
  final Storage storage;

  @override
  State<MyHomePage> createState() => _MyHomePageState(storage: storage);
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

  void sortList(String type) {
    switch (type) {
      case 'race':
        if (sortStr == 'rn') {
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
        if (sortStr == 'nn') {
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
        if (sortStr == 'ln') {
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
                if (customIcon.icon == Icons.search) {
                  customIcon = const Icon(Icons.cancel);
                  customSearchBar = ListTile(
                      title: TextField(
                    decoration: const InputDecoration(
                        hintText: 'Enter demon name...',
                        border: InputBorder.none),
                    onChanged: (value) {
                      setState(() {
                        searchString = value.toLowerCase();
                      });
                    },
                  ));
                } else {
                  customIcon = const Icon(Icons.search);
                  customSearchBar = const Text('Demon stats');
                  searchString = '';
                }
              });
            },
          ),
          PopupMenuButton<String>(
              onSelected: (String result) {
                setState(() {
                  sortList(result);
                });
              },
              icon: const Icon(Icons.sort),
              itemBuilder: (context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem(value: 'race', child: Text('Race')),
                    const PopupMenuItem(value: 'name', child: Text('Name')),
                    const PopupMenuItem(value: 'level', child: Text('Level'))
                  ])
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: FutureBuilder(
            future: Future.wait([
              storage.futureStatsList,
              storage.futureSkillsList,
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
                decoration: BoxDecoration(color: Colors.orange),
                child: Text('Demon Compendium')),
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
                        builder: (context) => SkillsList(
                              storage: storage,
                            )));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MyListItem extends StatelessWidget {
  MyListItem({Key? key, required this.storage, required this.givenIndex})
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

  Widget affinityColoredText(int value) {
    if (value == 0) {
      return const Text('');
    } else {
      return value > 0
          ? Text(value.toString(),
              style: TextStyle(color: affinityColors[value]))
          : Text(value.toString(),
              style: TextStyle(color: affinityColors[15 + value]));
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
                      Text(storage.statsList[givenIndex].race,
                          style: const TextStyle(fontSize: 15)),
                      Container(width: 20),
                      Text(
                          'LVL:' +
                              storage.statsList[givenIndex].level.toString(),
                          style: const TextStyle(fontSize: 15))
                    ],
                  ),
                  Row(
                    children: [
                      Text(storage.statsList[givenIndex].name,
                          style: const TextStyle(fontSize: 18))
                    ],
                  )
                ],
              )),
          Column(
            children: [
              Container(height: 8),
              Row(
                children: [
                  Text(
                      'HP:' + storage.statsList[givenIndex].stats[0].toString())
                ],
              ),
              Row(
                children: [
                  Text(
                      'MP:' + storage.statsList[givenIndex].stats[1].toString())
                ],
              )
            ],
          ),
          Container()
        ],
      ),
      children: [
        InkWell(
          child: Row(
            children: [
              //stats info
              SizedBox(
                  width: 75,
                  child: Column(
                    children: [
                      Text(
                          'STR:' +
                              storage.statsList[givenIndex].stats[2].toString(),
                          style: GoogleFonts.lato()),
                      Text(
                          'VIT:' +
                              storage.statsList[givenIndex].stats[3].toString(),
                          style: GoogleFonts.lato()),
                      Text(
                          'MAG:' +
                              storage.statsList[givenIndex].stats[4].toString(),
                          style: GoogleFonts.lato()),
                      Text(
                          'AGI:' +
                              storage.statsList[givenIndex].stats[5].toString(),
                          style: GoogleFonts.lato()),
                      Text(
                          'LUK:' +
                              storage.statsList[givenIndex].stats[6].toString(),
                          style: GoogleFonts.lato()),
                    ],
                  )),
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
            ],
          ),
          onTap: (){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailedPage(
                        storage: storage, name: storage.statsList[givenIndex].name
                    )
                )
            );
          },
        )
      ],
    );
  }
}

class DetailedPage extends StatelessWidget {
  DetailedPage(
      {Key? key,
        required this.storage,
        required this.name})
      : super(key: key);

  Storage storage;
  String name;
  List<Widget> weaknessElementList = [];
  List<Widget> affinityElementList = [];
  List<Widget> weaknessAilmentList = [];
  List<List<Widget>> skillInfo = [];
  String fissionSearch = '';
  String fusionSearch = '';

  var ailmentNames = ['Charm', 'Seal', 'Panic', 'Poison', 'Sleep', 'Mirage'];
  late DemonStats statsData;
  List<SkillData> skillsList = [];
  var fusionData = [];
  var fissionData = [];
  var affinityColors = [];
  var weaknessIcons = [];
  var affinityIcons = [];


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

  Widget affinityColoredText(int value) {
    if (value == 0) {
      return const Text('');
    } else {
      return value > 0
          ? Text(value.toString(),
          style: TextStyle(color: affinityColors[value]))
          : Text(value.toString(),
          style: TextStyle(color: affinityColors[15 + value]));
    }
  }

  //initialize variables
  void initState() {
    statsData = storage.getDemonByName(name);
    // fusionData = storage.fusionFromName(statsData[2]);
    // fissionData = storage.fissionFromName(statsData[2]);
    affinityColors = storage.affinityColors;
    weaknessIcons = storage.weaknessIcons;
    affinityIcons = storage.affinityIcons;
    //make list of containers with element weaknesses
    for (int i = 0; i < weaknessIcons.length; i++) {
      weaknessElementList.add(Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          width: 26,
          child: Column(
            children: [
              Image.asset(weaknessIcons[i]),
              weaknessColoredText(statsData.resists[i])
            ],
          )));
    }
    //make list of containers with skill affinities
    for (int i = 0; i < affinityIcons.length; i++) {
      affinityElementList.add(Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          width: 26,
          child: Column(
            children: [Image.asset(affinityIcons[i]), affinityColoredText(statsData.affinities[i])],
          )));
    }
    //make list of containers with ailment information
    for (int i = 0; i < 6; i++) {
      weaknessAilmentList.add(Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: Column(
            children: [
              Text(ailmentNames[i]),
              weaknessColoredText(statsData.ailments[i])
            ],
          )));
    }
    var tempSkillData = statsData.skills.entries;
    for(var element in tempSkillData){
      SkillData skill = storage.getSkillByName(element.key);
      skillsList.add(skill);
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
                    Text(statsData.name, style: const TextStyle(fontSize: 35)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Race: ' + statsData.race),
                        Container(width: 10),
                        Text('LVL: ' + statsData.level.toString()),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('HP: ' + statsData.stats[0].toString()),
                        Container(width: 20),
                        Text('MP: ' + statsData.stats[1].toString())
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('STR:' + statsData.stats[2].toString()),
                        Container(width: 5),
                        Text('VIT:' + statsData.stats[3].toString()),
                        Container(width: 5),
                        Text('MAG:' + statsData.stats[4].toString())
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('AGI:' + statsData.stats[5].toString()),
                        Container(width: 5),
                        Text('LUK:' + statsData.stats[6].toString())
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
                            itemCount: skillsList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ExpansionTile(
                                title: Row(
                                  children: [
                                    Image.asset('assets/icons/' + skillsList[index].element + '.png'),
                                    Text(skillsList[index].name),
                                    Text(skillsList[index].cost.toString()),
                                  ],
                                ),
                                children: [],
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) =>
                                const Divider()))
                  ],
                )),
            const Text('fissions'),
            const Text('fusions')
          ]),
        )
    );
  }
}

class SkillsList extends StatefulWidget {
  SkillsList({Key? key, required this.storage}) : super(key: key);

  Storage storage;

  @override
  State<StatefulWidget> createState() => _SkillsList(storage: storage);
}

class _SkillsList extends State<SkillsList> {
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
                decoration: BoxDecoration(color: Colors.orange),
                child: Text('Demon compendium')),
            ListTile(
              title: const Text('Stats'),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyHomePage(storage: storage)));
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
