import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TrainingDataScreen extends StatefulWidget {
  @override
  _TrainingDataScreenState createState() => _TrainingDataScreenState();
}

class _TrainingDataScreenState extends State<TrainingDataScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    User? user = _auth.currentUser;
    if (user != null) {
      print('User is logged in, attempting to fetch data...');
      try {
        final ListResult result =
            await FirebaseStorage.instance.ref('uploads/${user.uid}').listAll();
        List<Map<String, dynamic>> loadedFiles = [];

        for (var item in result.items) {
          var downloadUrl = await item.getDownloadURL();
          var metadata = await item.getMetadata();

          loadedFiles.add({
            'url': downloadUrl,
            'description':
                metadata.customMetadata?['description'] ?? 'No description',
            'weight': metadata.customMetadata?['weight'] ?? 'No weight',
            'calories': metadata.customMetadata?['calories'] ??
                'No calories', // Fetching calorie data
            'date': metadata.customMetadata?['date'] ?? 'No date',
          });
        }

        setState(() {
          files = loadedFiles;
          _isLoading = false;
        });
      } catch (e) {
        print("Error loading data from Firebase Storage: $e");
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print("User is not logged in");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Training Data"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : files.isEmpty
              ? Center(child: Text("No data available"))
              : ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Image.network(
                        files[index]['url'],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.broken_image),
                      ),
                      title: Text(files[index]['description']),
                      subtitle: Text(
                          "Weight: ${files[index]['weight']}, Calories: ${files[index]['calories']}, Date: ${files[index]['date']}"), // Displaying the calories
                    );
                  },
                ),
    );
  }
}
