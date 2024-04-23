import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'training_data_screen.dart';
import 'statistics_screen.dart'; // Import the new screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  Future<void> uploadImageAndDetails(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;
    File file = File(image.path);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
        var storageRef =
            FirebaseStorage.instance.ref('uploads/${user.uid}/$fileName');

        var metadata = SettableMetadata(customMetadata: {
          'description': descriptionController.text,
          'weight': weightController.text,
          'calories': caloriesController.text,
          'date': DateFormat('yyyy-MM-dd').format(selectedDate),
          'userId': user.uid,
          'userEmail': user.email ?? '',
        });

        var uploadTask = storageRef.putFile(file, metadata);
        await uploadTask.whenComplete(() => {});

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload successful')));
        descriptionController.clear();
        weightController.clear();
        caloriesController.clear();
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Image"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: weightController,
              decoration: InputDecoration(labelText: 'Weight'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: caloriesController,
              decoration: InputDecoration(labelText: 'Calories Consumed'),
              keyboardType: TextInputType.number,
            ),
            ListTile(
              title: Text(
                  "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            ElevatedButton(
              onPressed: () => uploadImageAndDetails(ImageSource.gallery),
              child: Text('Upload from Gallery'),
            ),
            ElevatedButton(
              onPressed: () => uploadImageAndDetails(ImageSource.camera),
              child: Text('Use Camera'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TrainingDataScreen())),
              child: Text('View Uploaded Data'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => StatisticsScreen())),
              child: Text('View Statistics'),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}
