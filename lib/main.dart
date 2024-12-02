import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyAsyncApp());
}

class MyAsyncApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posts Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DataFetcherPage(),
    );
  }
}

class DataFetcherPage extends StatefulWidget {
  @override
  _DataFetcherPageState createState() => _DataFetcherPageState();
}

class _DataFetcherPageState extends State<DataFetcherPage> {
  // List to store fetched posts
  List<dynamic> _posts = [];

  // Loading and error state variables
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is first created
    _fetchPosts();
  }

  // Asynchronous method to fetch posts from JSONPlaceholder API
  Future<void> _fetchPosts() async {
    // Set loading state
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Perform network request asynchronously
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

      // Check if request was successful
      if (response.statusCode == 200) {
        // Parse JSON data
        final List<dynamic> fetchedPosts = json.decode(response.body);

        // Update state with fetched posts
        setState(() {
          _posts = fetchedPosts.take(10).toList(); // Limit to 10 posts
          _isLoading = false;
        });
      } else {
        // Handle error scenario
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      // Update error state
      setState(() {
        _errorMessage = 'Error fetching data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Method to delete a post
  void _deletePost(int index) {
    setState(() {
      _posts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts Viewer'),
      ),
      body: RefreshIndicator(
        // Pull-to-refresh functionality
        onRefresh: _fetchPosts,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchPosts,
        child: Icon(Icons.refresh),
        tooltip: 'Refresh Posts',
      ),
    );
  }

  Widget _buildBody() {
    // Handle different UI states
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchPosts,
              child: Text('Retry'),
            )
          ],
        ),
      );
    }

    // Display fetched posts as dismissible cards
    return ListView.builder(
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return Dismissible(
          key: Key(post['id'].toString()),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            _deletePost(index);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Post deleted')),
            );
          },
          child: Card(
            margin: EdgeInsets.all(8),
            elevation: 4,
            child: ListTile(
              title: Text(post['title'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              subtitle: Text(post['body'],
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deletePost(index),
              ),
            ),
          ),
        );
      },
    );
  }
}
