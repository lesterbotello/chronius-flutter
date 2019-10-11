import '../constants.dart';

class Chronius{
  int _id;
  String _name;
  String _description;
  DateTime _targetDate;
  DateTime _startingDate;
  int _isActive; // This should be a bool, but it's made an int so that it plays nice with Sqlite

  Chronius(this._name, this._description, this._targetDate, this._startingDate, int _isActive);
  Chronius.withId(this._id, this._name, this._description, this._targetDate, this._startingDate, int _isActive);

  int get id => _id;
  String get name => _name;
  String get description => _description;
  DateTime get targetDate => _targetDate;
  DateTime get startingDate => _startingDate;

  int get isActive {
    if(_isActive == null){
      _isActive = 0;
    }
      
    return _isActive;
  }

  set name(String newName){
    if(newName.length < 255){
      _name = newName;
    }
  }

  set description(String newDescription){
    if(description.length < 255){
      _description = description;
    }
  }

  set targetDate(DateTime date){
    if(date == null){
      throw new Exception("Target date must not be null");
    } else {
      _targetDate = date;
    }
  }

  set startingDate(DateTime date){
    if(date == null){
      throw new Exception("Target date must not be null");
    } else {
      _startingDate = date;
    }
  }

  Map<String, dynamic> toMap(){
    var map = Map<String, dynamic>();

    if(_id != null){
      map[Constants.COLUMN_ID] = _id;
    }

    map[Constants.COLUMN_NAME] = _name;
    map[Constants.COLUMN_DESCRIPTION] = _description;
    map[Constants.COLUMN_ISACTIVE] = this._isActive;
    map[Constants.COLUMN_TARGET_DATE] = this._targetDate.toString();
    map[Constants.COLUMN_STARTING_DATE] = this._startingDate.toString();

    return map;
  }

  Chronius.fromObject(dynamic o){
    this._id = o[Constants.COLUMN_ID];
    this._name = o[Constants.COLUMN_NAME];
    this._description = o[Constants.COLUMN_DESCRIPTION];
    this._isActive = o[Constants.COLUMN_ISACTIVE];
    this._targetDate = DateTime.parse(o[Constants.COLUMN_TARGET_DATE]);
    this._startingDate = DateTime.parse(o[Constants.COLUMN_STARTING_DATE]);
  }
}