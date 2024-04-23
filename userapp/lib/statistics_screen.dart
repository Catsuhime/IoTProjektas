import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<charts.Series<WeightData, String>> _seriesBarData = [];
  String lastCalories = "Loading...";
  String lastWeight = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchLatestData();
  }

  Future<void> _fetchLatestData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var storageRef = FirebaseStorage.instance.ref('uploads/${user.uid}');
      var listResult = await storageRef.listAll();
      if (listResult.items.isNotEmpty) {
        var item =
            listResult.items.last; // Assuming last item is the most recent
        var metadata = await item.getMetadata();
        String calories = metadata.customMetadata?['calories'] ?? 'No data';
        String weight = metadata.customMetadata?['weight'] ?? 'No data';
        setState(() {
          lastCalories = calories;
          lastWeight = weight;
        });
        _loadChartData(listResult.items);
      }
    }
  }

  Future<void> _loadChartData(List<Reference> items) async {
    List<WeightData> data = [];
    for (var item in items) {
      var metadata = await item.getMetadata();
      String weight = metadata.customMetadata?['weight'] ?? '0';
      String date = metadata.customMetadata?['date'] ?? '';
      data.add(WeightData(date, double.parse(weight)));
    }
    setState(() {
      _seriesBarData.add(
        charts.Series(
          data: data,
          domainFn: (WeightData weightData, _) => weightData.date,
          measureFn: (WeightData weightData, _) => weightData.weight,
          id: 'Weight',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Statistics"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Last Recorded Calories: $lastCalories"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Last Recorded Weight: $lastWeight"),
            ),
            SizedBox(
              height: 200.0,
              child: charts.BarChart(_seriesBarData, animate: true),
            ),
          ],
        ),
      ),
    );
  }
}

class WeightData {
  final String date;
  final double weight;

  WeightData(this.date, this.weight);
}
