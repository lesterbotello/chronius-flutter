import 'dart:async';
import 'package:chronius/chroniusDetail.dart';
import 'package:chronius/helpers/dbhelper.dart';
import 'package:chronius/model/chronius.dart';
import 'package:flutter/material.dart';
import 'dart:core';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chronius',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Montserrat'
      ),
      home: MyHomePage(title: 'Chronius'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _count = 0;
  var _activeChroni = <Chronius>[];
  var _helper = DbHelper();
  var _countdownText = <String>[];

  @override
  void initState(){
    if(_activeChroni == null || _activeChroni.length == 0){
      super.initState();
      getData();
    }
  }

  void updateCountdowns() {
    for(var i = 0; i < _activeChroni.length; i++) {
      final now = DateTime.now();
      final name = _activeChroni[i].name;
      final distance = _activeChroni[i].targetDate.difference(now);
      final days = distance.inDays;
      final hours = distance.inHours.remainder(24);
      final minutes = distance.inMinutes.remainder(60);
      final seconds = distance.inSeconds.remainder(60);

      String str;

      if(distance.inSeconds < 0){
        str = "$name happened ${days.abs()} days, ${hours.abs()} hours, ${minutes.abs()} minutes and ${seconds.abs()} seconds ago.";
      } else {
        str = "$name is happening in $days days, $hours hours, $minutes minutes and $seconds seconds.";
      }

      setState(() {
        if(i >= _countdownText.length){
          _countdownText.add(str);
        }
        else{
          _countdownText[i] = str;
        }
      });
    }
  }

  void beginUpdateTimers(){
    Timer.periodic(Duration(seconds: 1), (timer) => updateCountdowns());
  }

  Widget getChroniList(){
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(10, 120, 10, 0),
      itemCount: _count,
      itemBuilder: (BuildContext context, int position){
        return InkWell(
          onTap: null, // TODO: Add edit event...
          child: Container(
            decoration: ShapeDecoration(
              color: Colors.black45,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))
              )
            ),
            padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
            margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: Center(
              child: Column(
                children: <Widget>[
                  Text(
                    _countdownText[position],
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xff455A64),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0.0), 
                        topRight: Radius.circular(20.0), 
                        bottomLeft: Radius.circular(20.0), 
                        bottomRight: Radius.circular(0.0)
                      ),
                    ),
                  )
                ],
            ),
          )
        ),
      );
    });
  }

  Widget empty(){
    return Center(
      child: Text(
        'Wow, such empty :(\n\nUse the "+" button below to add a Chronius',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.1, 0.5, 0.7, 0.9],
              colors: [
                Colors.indigo[800],
                Colors.indigo[700],
                Colors.indigo[600],
                Colors.indigo[400],
              ],
            )
          ),
          child: _count == 0 ? empty() : getChroniList(),
        ),
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: AppBar(
            title: Text(widget.title),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToAdd(context),
        tooltip: 'Add Chronius',
        child: Icon(Icons.add),
      ),
    );
  }

  void navigateToAdd(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (context) => ChroniusDetail()));
  }

  void getData(){
    _helper.initializeDb().then((result){
      _helper.getAllChroni().then((result){
        var chroni = List<Chronius>();
        for(int i = 0; i < result.length; i++){
          var c = Chronius.fromObject(result[i]);
          chroni.add(c);
          debugPrint(c.name);
        }

        // Important, this needs to be called BEFORE the first setState() call...
        if(result.length > 0){
          _activeChroni = chroni;
          _count = result.length;
          beginUpdateTimers();
        }

        debugPrint("Items: $_count");
      });
    });
  }
}
