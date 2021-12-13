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

class MyApp extends StatelessWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(title: 'appTitle', storage: DataStorage())
    );
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
  const MyHomePage({Key? key, required this.title, required this.storage}) : super(key: key);
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
    temp.removeLast();
    var temp2 = [];
    for (int i=0; i<temp.length; i++){
      temp2.add(temp[i].split(';'));
    }
    return temp2;
  }

  @override
  void initState(){
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
            if (snapshot.hasData){
              child = ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int index){
                  return Container(
                      height: 40,
                      child: Center(
                          child: Text(snapshot.data![index][2]))
                    );
                  },
                );
            } else if (snapshot.hasError){
              child = Text('Error');
            } else {
              child = Text("Something");
            }
            return Center(child: child);
          } ,
        ),
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(widget.title),
    //   ),
    //   body: ListView.builder(
    //     itemCount: readFile.length,
    //     itemBuilder: (BuildContext context, int index) {
    //       return Container(
    //         height: 40,
    //         child: Text(readFile[index][2]),
    //       );
    //     },
    //   )
    // );
  }
}
