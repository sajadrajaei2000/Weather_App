// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, non_constant_identifier_names, avoid_print, unused_local_variable, prefer_typing_uninitialized_variables
import 'dart:async';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:project1/Model/CurrentCityDataModel.dart';
import 'package:intl/intl.dart';
import 'package:project1/Model/ForeCastDayModel.dart';
import 'package:weather_icons/weather_icons.dart';

void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //! create an object and  initialize with constructor to pass in the controller parameter
  TextEditingController textEditingController = TextEditingController();
  //! an object of CurrentCityDataModel class that is StreamController
  late StreamController<CurrentCityDataModel> currenweatherfuture;
  //! an object of List<ForeCastDayModel>  that is StreamController
  late StreamController<List<ForeCastDayModel>> streamforecastfuture;

  var cityname = 'tehran';
  double? lat;
  double? lon;

  @override
  void initState() {
    super.initState();
    //! to get response frome api and initialize first class model and streamcontroller
    SendRequestCurrentWeather(cityname);

    //! initialize created objects with Streamcontroller constructor
    currenweatherfuture = StreamController<CurrentCityDataModel>();
    streamforecastfuture = StreamController<List<ForeCastDayModel>>();
  }

  @override
  void dispose() {
    super.dispose();

    textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 20,
        title: Text('Weather App'),
        actions: <Widget>[
          //! The way to build popupmenubotton
          PopupMenuButton<String>(itemBuilder: (BuildContext context) {
            return {'Setting', 'Profile', 'Logout'}.map((String choice) {
              return PopupMenuItem(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          })
        ],
      ),
      body: StreamBuilder<CurrentCityDataModel>(
          stream: currenweatherfuture.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              //! create an object of first class model and initialize it with snapshot's data
              CurrentCityDataModel? cityDataModel = snapshot.data;
              //! Call this function for initialize second class model and streamcontroller
              SendRequest5DayForecast(lat, lon);
              //! use Dataformat from intl package.
              final formatter = DateFormat.jm();
              var sunset = formatter.format(DateTime.fromMillisecondsSinceEpoch(
                cityDataModel!.sunset * 1000,
                isUtc: true,
              ));
              var sunrise =
                  formatter.format(DateTime.fromMillisecondsSinceEpoch(
                cityDataModel.sunrise * 1000,
                isUtc: true,
              ));

              return Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.cover,
                  image: ExactAssetImage('images/mypic5.jpg.jpg'),
                )),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Center(
                    //! use SingleChildScrollView to fix error of pixels oversize on the screen.
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        //!  To rebuild API and run build widget again
                                        SendRequestCurrentWeather(
                                            textEditingController.text);
                                      });
                                    },
                                    child: Text('find'),
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: textEditingController,
                                    decoration: InputDecoration(
                                        hintText: 'enter a city name',
                                        border: OutlineInputBorder(),
                                        hintStyle:
                                            TextStyle(color: Colors.white)),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                                '${cityDataModel.cityname.toUpperCase()}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 35)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text('${cityDataModel.description}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 40)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: SetIconFromId(cityDataModel.icon, 70),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Text(
                              '${cityDataModel.temp}' '\u00B0',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 60),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'max',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      '${cityDataModel.temp_max}' '\u00B0',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.black,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  children: [
                                    Text(
                                      'min',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        '${cityDataModel.temp_min}' '\u00B0',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Container(
                              height: 1,
                              width: double.infinity,
                              color: Colors.black,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Container(
                                height: 100,
                                width: double.infinity,
                                child: Center(
                                  //! this how to use streambuilder
                                  child: StreamBuilder<List<ForeCastDayModel>>(
                                      //! we initialized streamforecastfuture before in the SendRequest7DayForecast()
                                      stream: streamforecastfuture.stream,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          List<ForeCastDayModel>?
                                              forecastdatamodel = snapshot.data;
                                          return ListView.builder(
                                              itemCount: 5,
                                              scrollDirection: Axis.horizontal,
                                              shrinkWrap: true,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int pos) {
                                                //! it returnes a function with output widget and input of second class model.
                                                return Listviewitems(
                                                    forecastdatamodel![pos]);
                                              });
                                        } else {
                                          return Center(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Checking Network...',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20),
                                                  ),
                                                  JumpingDotsProgressIndicator(
                                                    color: Colors.black,
                                                    fontSize: 60,
                                                    dotSpacing: 10,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      }),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Container(
                              height: 1,
                              width: double.infinity,
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Text('wind speed',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                        '${cityDataModel.windSpeed} m/s',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 18)),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, top: 15),
                                child: Container(
                                  width: 1,
                                  height: 70,
                                  color: Colors.black,
                                ),
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, left: 15),
                                    child: Text('sunrise',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 15),
                                    child: Text(sunrise,
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 18)),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, top: 15),
                                child: Container(
                                  width: 1,
                                  height: 70,
                                  color: Colors.black,
                                ),
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, left: 15),
                                    child: Text('sunset',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 15),
                                    child: Text(sunset,
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 18)),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, top: 15),
                                child: Container(
                                  width: 1,
                                  height: 70,
                                  color: Colors.black,
                                ),
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, left: 15),
                                    child: Text('humidity',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 15),
                                    child: Text('${cityDataModel.humidity}%',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 18)),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 280),
                      child: Text(
                        'Checking Network...',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                    JumpingDotsProgressIndicator(
                      color: Colors.black,
                      fontSize: 60,
                      dotSpacing: 10,
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }

  Container Listviewitems(ForeCastDayModel model) {
    return Container(
      height: 70,
      width: 68,
      child: Card(
        color: Colors.transparent,
        child: Column(
          children: [
            Text(
              model.dataTime.toString(),
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            //! create and show related ICONS
            SetIconFromId(model.icon, 30)!,
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                '${model.temp.round()}\u00B0',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

//! A function to create and return related icons into program.
  Icon? SetIconFromId(String iconid, double size) {
    switch (iconid) {
      case '01d':
        return Icon(
          WeatherIcons.day_sunny,
          size: size,
          color: Colors.white,
        );

      case '01n':
        return Icon(WeatherIcons.day_sunny, size: size, color: Colors.white);

      case '02d':
        return Icon(WeatherIcons.day_cloudy, size: size, color: Colors.white);
      case '02n':
        return Icon(WeatherIcons.night_alt_cloudy,
            size: size, color: Colors.white);
      case '03d':
        return Icon(WeatherIcons.cloudy, size: size, color: Colors.white);
      case '03n':
        return Icon(WeatherIcons.cloudy, size: size, color: Colors.white);
      case '04d':
        return Icon(WeatherIcons.cloud, size: size, color: Colors.white);
      case '04n':
        return Icon(WeatherIcons.cloud, size: size, color: Colors.white);
      case '09d':
        return Icon(WeatherIcons.day_showers, size: size, color: Colors.white);
      case '09n':
        return Icon(WeatherIcons.night_showers,
            size: size, color: Colors.white);
      case '10d':
        return Icon(WeatherIcons.day_rain, size: size, color: Colors.white);
      case '10n':
        return Icon(WeatherIcons.night_rain, size: size, color: Colors.white);
      case '11d':
        return Icon(WeatherIcons.day_thunderstorm,
            size: size, color: Colors.white);
      case '11n':
        return Icon(WeatherIcons.night_thunderstorm,
            size: size, color: Colors.white);
      case '13d':
        return Icon(WeatherIcons.day_snow, size: size, color: Colors.white);
      case '13n':
        return Icon(WeatherIcons.night_snow, size: size, color: Colors.white);
      case '50d':
        return Icon(WeatherIcons.day_fog, size: size, color: Colors.white);
      case '50n':
        return Icon(WeatherIcons.night_fog, size: size, color: Colors.white);
      default:
        return Icon(WeatherIcons.windy, size: size, color: Colors.white);
    }
  }

  void SendRequestCurrentWeather(String cityname) async {
    var apikey = 'b74d9054755f6b8f345fb04be0c67ac0';
    try {
      var response = await Dio().get(
          "https://api.openweathermap.org/data/2.5/weather",
          queryParameters: {'q': cityname, 'appid': apikey, 'units': 'metric'});
      print(response.data);
      print('stat:${response.statusCode}');
      lat = response.data['coord']['lat'];
      lon = response.data['coord']['lon'];
//! initializing first class model with constructor and create an object to use.
      var datamodel = CurrentCityDataModel(
          cityname,
          response.data['coord']['lon'],
          response.data['coord']['lat'],
          response.data['weather'][0]['main'],
          response.data['weather'][0]['description'],
          response.data['main']['temp'],
          response.data['main']['temp_min'],
          response.data['main']['temp_max'],
          response.data['main']['pressure'],
          response.data['main']['humidity'],
          response.data['wind']['speed'],
          response.data['dt'],
          response.data['sys']['country'],
          response.data['sys']['sunrise'],
          response.data['sys']['sunset'],
          response.data['weather'][0]['icon']);

      print(datamodel.temp);
//! To initialize object of StraemController
      currenweatherfuture.add(datamodel);
    } on DioError catch (e) {
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'Please Enter a valid city name.',
        style: TextStyle(color: Colors.white, fontSize: 20),
      )));
    }
  }

  void SendRequest5DayForecast(double? lat, double? lon) async {
    //! create a list of second class model
    List<ForeCastDayModel> list = [];
    var apikey = 'b74d9054755f6b8f345fb04be0c67ac0';
    try {
      var response = await Dio().get(
          "https://api.openweathermap.org/data/2.5/forecast",
          queryParameters: {
            'lat': lat,
            'lon': lon,
            'appid': apikey,
            'units': 'metric'
          });
      final formatter = DateFormat.MMMd();

      for (int i = 7; i < response.data['list'].length; i += 8) {
        //! format time before initializing second class model
        var model = response.data['list'][i];

        var dt = formatter.format(DateTime.fromMillisecondsSinceEpoch(
          model['dt'] * 1000,
          isUtc: true,
        ));
        //! initializing second class model
        var forecast5daymodel = ForeCastDayModel(
            dt,
            model['main']['temp'],
            model['weather'][0]['main'],
            model['weather'][0]['description'],
            model['weather'][0]['icon']);
//! intitializing created list of second class model
        list.add(forecast5daymodel);
      }
      //! initializing object of streamcontroller
      streamforecastfuture.add(list);
    } on DioError catch (e) {
      print(e.message);
      Scaffold(
          body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 280),
              child: Text(
                'There is an error massege :\n ${e.message}',
                style: TextStyle(color: Colors.black, fontSize: 70),
              ),
            )
          ],
        ),
      ));
    }
  }
}
