import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'home/_time_controller_area.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:charts_flutter/flutter.dart' as charts;
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Smart Task Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Smart Task Demo Page'),
    );
  }
}



class MyHomePage extends StatefulWidget{

  MyHomePage({Key? key,required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  String dropdownValue = '日間';
  int _counter = 0;
  final timeControllerList = <TimeData>[];

  @override
  Future<Widget> build(BuildContext context) async{
    return MaterialApp(
      home: Scaffold(
        key: _key,
        drawerEdgeDragWidth: 0,
        drawer: Drawer(),
        appBar: AppBar(
          // centerTitle: true,
          // title: const Text('SmartTask'),
          backgroundColor: Colors.orange,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    _key.currentState!.openDrawer();
                    print('drawer');
                  },
              );
            },
          ),
        ),

        body: Container(
          child: Column(
            children: <Widget>[
              await _timeControllerArea(),
              _taskControllerArea(),
              _bannerAdsArea(),
            ],
          ),
        ),
        //floatingActionButton: _floatingActionButton(),
      ),
      title: 'task',
    );
  }

//時間管理
  Future<Widget> _timeControllerArea() async{
    return Container(
      height: 260,
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(_getDay()),
              _dayChangedDropDownButton(),
            ],
          ),
          await _timeSeriesChart(),
        ],
      ),
    );
  }
//データ取得日時範囲変更
  Widget _dayChangedDropDownButton() {
    return DropdownButton<String>(
      value: dropdownValue,
      style: const TextStyle(
        color: Colors.black,
      ),
      underline: Container(
        height: 1,
        color: Colors.black,
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },
      items: <String>['月間', '年間']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),

        );
      })
          .toList(),
    );
  }

//日付取得
  String _getDay() {
    var prevday;
    var today;
    setState(() {
      today = DateFormat('yyyy:MM:dd').format(DateTime.now());
      var now = DateTime.now();
      switch (dropdownValue) {
      // case '日間':
      //   prevday = DateFormat('yyyy:MM:dd').format(
      //       new DateTime(now.year, now.month, now.day - 1));
      //   break;
        case '月間':
          prevday = DateFormat('yyyy:MM:dd').format(
              new DateTime(now.year, now.month - 1, now.day));
          break;
        case '年間':
          prevday = DateFormat('yyyy:MM:dd').format(
              new DateTime(now.year - 1, now.month, now.day));
          break;
      }
    });
    return '$prevday  ~  $today';
  }

//スマホを触った時間やタスクをこなした時間のデータを内部保存
  void _setIntPrefs() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateFormat('yyyy:MM:dd').format(DateTime.now()).toString();

    _counter = (prefs.getInt('setDay' + today) ?? 1) + 1;
    prefs.setInt('setDay' + today,_counter);
    print('_setIntPrefs$_counter');
  }

  //グラフの表示
  Future<Widget> _timeSeriesChart() async{
    return Container(
      height: 200,
      width: double.infinity,
      child: charts.TimeSeriesChart(
        await _createTimeData( _createTimeDataList()),
      ),
    );
  }




  Future<List<charts.Series<TimeData, DateTime>>> _createTimeData(
      Future<List<TimeData>> timeControllerList) async{
    return [
      charts.Series<TimeData, DateTime>(
        id: 'TimeController',
        data: await timeControllerList,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (timeData,_) => timeData.day,
        measureFn: (timeData, _) => timeData.usePhone,
      )
    ];
  }

  Future <List<TimeData>> _createTimeDataList() async{
    final SharedPreferences prefs =  await SharedPreferences.getInstance();
    String today = DateFormat('yyyy:MM:dd').format(DateTime.now()).toString();
    var now = DateTime.now();
    timeControllerList.add(TimeData(now,10));

    switch (dropdownValue) {
      case '月間':
        break;
      case '年間':
        break;
    }

    return Future<List<TimeData>>.value(timeControllerList);
  }

  Widget _taskControllerArea() {
    return Expanded(
        child: Container(
          color: Colors.white,
        )
    );
  }

  Widget _bannerAdsArea() {
    return Container(
      height: 60,
      color: Colors.blue,
    );
  }

  // Widget _floatingActionButton() {
  //   return FloatingActionButton(
  //     child: Icon(Icons.add),
  //     onPressed: () {
  //       _setIntPrefs();
  //     },
  //   );
  // }
}


