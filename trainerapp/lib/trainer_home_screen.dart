import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class TrainerHomeScreen extends StatefulWidget {
  @override
  _TrainerHomeScreenState createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  List<Map<String, dynamic>> files = [];
  List<Map<String, dynamic>> filteredFiles = [];
  bool _isLoading = true;
  bool _sortedByNewest = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadImages();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadImages() async {
    if (FirebaseAuth.instance.currentUser != null) {
      print("Fetching data from all users...");
      try {
        final ListResult result =
            await FirebaseStorage.instance.ref('uploads').listAll();
        List<Map<String, dynamic>> loadedFiles = [];

        for (var userFolder in result.prefixes) {
          final userFiles = await userFolder.listAll();
          for (var item in userFiles.items) {
            var downloadUrl = await item.getDownloadURL();
            var metadata = await item.getMetadata();

            loadedFiles.add({
              'url': downloadUrl,
              'description':
                  metadata.customMetadata?['description'] ?? 'No description',
              'weight': metadata.customMetadata?['weight'] ?? 'No weight',
              'date': DateTime.tryParse(metadata.customMetadata?['date'] ?? ''),
              'userId': userFolder.name,
              'userEmail':
                  metadata.customMetadata?['userEmail'] ?? 'No email provided',
            });
          }
        }

        setState(() {
          files = loadedFiles;
          filteredFiles =
              List.from(files); // Initially, filteredFiles shows all data
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

  void _onSearchChanged() {
    List<Map<String, dynamic>> newFilteredFiles = files
        .where((file) => file['userEmail']
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
        .toList();
    if (_sortedByNewest) {
      newFilteredFiles.sort((a, b) => b['date'].compareTo(a['date']));
    }
    setState(() {
      filteredFiles = newFilteredFiles;
    });
  }

  void _toggleSortByNewest() {
    setState(() {
      _sortedByNewest = !_sortedByNewest;
      filteredFiles.sort((a, b) => _sortedByNewest
          ? b['date'].compareTo(a['date'])
          : a['date'].compareTo(b['date']));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All User Data"),
        actions: [
          IconButton(
            icon: Icon(Icons.sort_by_alpha),
            onPressed: _toggleSortByNewest,
            tooltip: 'Sort by newest',
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Email',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredFiles.isEmpty
                    ? Center(child: Text("No data available"))
                    : ListView.builder(
                        itemCount: filteredFiles.length,
                        itemBuilder: (context, index) {
                          var file = filteredFiles[index];
                          return ListTile(
                            leading: Image.network(file['url'],
                                width: 100, height: 100, fit: BoxFit.cover),
                            title: Text(file['description']),
                            subtitle: Text(
                                "Weight: ${file['weight']}, Date: ${DateFormat('yyyy-MM-dd').format(file['date'])}, User: ${file['userId']}, Email: ${file['userEmail']}"),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
