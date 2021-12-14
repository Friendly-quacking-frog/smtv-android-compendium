import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
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
        home: MyHomePage(title: 'Demon Compendium', storage: DataStorage()));
  }
}

class DataStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.csv');
  }

  Future<String> readCounter() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      return '';
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.storage})
      : super(key: key);
  final DataStorage storage;
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> names = <String>['Entry A', 'Entry B', 'Entry C', 'nothing'];
  late Future<List> readFile;

  Future<List> loadAsset() async {
    var temp = [];
    var data = await rootBundle.loadString('assets/data.csv');
    temp = data.split('\n');
    var temp2 = [];
    for (int i = 0; i < temp.length; i++) {
      temp2.add(temp[i].split(';'));
    }
    return temp2;
  }

  @override
  void initState() {
    super.initState();
    readFile = loadAsset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder(
          future: readFile,
          builder: (
            BuildContext context,
            AsyncSnapshot<List> snapshot,
          ) {
            Widget child;
            if (snapshot.hasData) {
              child = ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int index) {
                  return MyListItem(list: snapshot.data![index]);
                },
              );
            } else if (snapshot.hasError) {
              child = const Text('Error');
            } else {
              child = Center(
                child: ListView(children: const [Text("Loading...")]),
              );
            }
            return Center(child: child);
          },
        ),
      ),
    );
  }
}

class MyListItem extends StatelessWidget {
  var list = [];

  MyListItem({Key? key, required this.list}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
                Text('STR:'+list[5]),
                Text('VIT:'+list[6]),
                Text('MAG:'+list[7]),
                Text('AGI:'+list[8]),
                Text('LUK:'+list[9]),
              ],
            ),
            Column(
              children: [
                //weakness info
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black)
                      ),
                      width: 26,
                        child: Column(
                          children: [
                            Image.asset('assets/icons/phy.png'),
                            Text(list[10])
                          ],
                        )
                    ),
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black)
                        ),
                        width: 26,
                        child: Column(
                          children: [
                            Image.asset('assets/icons/fir.png'),
                            Text(list[11])
                          ],
                        )
                    ),
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black)
                        ),
                        width: 26,
                        child: Column(
                          children: [
                            Image.asset('assets/icons/ice.png'),
                            Text(list[12])
                          ],
                        )
                    ),
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black)
                        ),
                        width: 26,
                        child: Column(
                          children: [
                            Image.asset('assets/icons/ele.png'),
                            Text(list[13])
                          ],
                        )
                    ),
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black)
                        ),
                        width: 26,
                        child: Column(
                          children: [
                            Image.asset('assets/icons/force.png'),
                            Text(list[14])
                          ],
                        )
                    ),
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black)
                        ),
                        width: 26,
                        child: Column(
                          children: [
                            Image.asset('assets/icons/lig.png'),
                            Text(list[15])
                          ],
                        )
                    ),
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black)
                        ),
                        width: 26,
                        child: Column(
                          children: [
                            Image.asset('assets/icons/cur.png'),
                            Text(list[16])
                          ],
                        )
                    )
                  ],
                ),
                //affinity info
                Row()
              ],
            )
          ],
        )
      ],
    );
  }
}
