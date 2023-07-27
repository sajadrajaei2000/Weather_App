class ForeCastDayModel {
  var _dataTime;
  var _temp;
  var _main;
  var _description;
  var _icon;

  ForeCastDayModel(
      this._dataTime, this._temp, this._main, this._description, this._icon);

  get dataTime => _dataTime;
  get temp => _temp;
  get main => _main;
  get description => _description;
  get icon => _icon;
}
