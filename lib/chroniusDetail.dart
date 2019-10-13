import 'package:chronius/constants.dart';
import 'package:chronius/model/chronius.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'helpers/dbhelper.dart';

class ChroniusDetail extends StatefulWidget{
  final String title;
  final Chronius editedChronius;
  ChroniusDetail({Key key, this.title, this.editedChronius}) : super(key: key);

  @override
  ChroniusDetailState createState() => ChroniusDetailState(editedChronius);
}

class ChroniusDetailState extends State<ChroniusDetail>{
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final mainTextStyle = TextStyle(fontFamily: 'Montserrat', color: Colors.white);
  final _helper = DbHelper();
  bool _messageVisible = false;
  Chronius _editedChronius;

  ChroniusDetailState(Chronius chronius){
    _editedChronius = chronius;
  }

  @override
  void initState(){
    super.initState();
    if(_editedChronius != null){
      nameController.text = _editedChronius.name;
      descriptionController.text = _editedChronius.description;
      dateController.text = _editedChronius.targetDate.toString();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 120.0, left: 0.0, right: 0.0, bottom: 0.0),
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
            child: Column(
              children: <Widget>[
              TextField(
                style: mainTextStyle,
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: mainTextStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)
                  )
                ),
              ),
              TextField(
                style: mainTextStyle,
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: mainTextStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)
                  )
                ),
              ),
              InkWell(
                onTap: () => selectDate(),
                child: IgnorePointer(
                  child: TextField(
                  style: mainTextStyle,
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: "Date",
                    labelStyle: mainTextStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)
                    )
                  ),
                  )
                )
              ),
              Padding(
                padding: EdgeInsets.all(30.0),
                child: RaisedButton(
                  onPressed: () {
                    try
                    {
                      if(_editedChronius == null){
                        // no Chronius was passed, create new...
                        var newChronius = Chronius(
                          nameController.text,
                          descriptionController.text,
                          DateTime.parse(dateController.text),
                          DateTime.now()
                        );

                        _helper.insertChronius(newChronius).then((result) {
                          if(result < 1){
                            showMessage();
                          } else {
                            Navigator.pop(context, Constants.CHRONIUS_ADDED);
                          }
                        }); 
                      } else {
                        _editedChronius.name = nameController.text;
                        _editedChronius.description = descriptionController.text;
                        _editedChronius.targetDate = DateTime.parse(dateController.text);

                        _helper.updateChronius(_editedChronius).then((result){
                          if(result < 1){
                            showMessage();
                          } else {
                            Navigator.pop(context, Constants.CHRONIUS_EDITED);
                          }
                        });
                      }
                    }
                    catch(ex)
                    {
                      showMessage();
                    }
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(color: Colors.indigo),
                  ),
                  color: Colors.white,
                )
              ),
              Padding(
                padding: EdgeInsets.all(30.0),
                child: AnimatedOpacity(
                  opacity: _messageVisible ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: Center(
                    child: Text(
                      "Adding Chronius failed, check the values and try again", 
                      style: mainTextStyle)
                  ),
                )
              )
            ],)
          ),
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: AppBar(
            title: Text(_editedChronius == null ? "Add chronius" : "Edit chronius"),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
            ),
          ), 
        ]
      ),
    );
  }

  Future selectDate() async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2016),
      lastDate: DateTime(2099)
    );

    if(picked != null) setState(() => dateController.text = picked.toString());
  }

  // Displays a message and schedule a hide after a while...
  void showMessage(){
    setState(() => _messageVisible = !_messageVisible);

    // Begin the countdown to hide the message...
    Timer(Duration(seconds: 4), () {
      setState(() => _messageVisible = !_messageVisible);
    });
  }
}