import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/joke_model.dart';
import '../utils/api_urls.dart';


class MyFinalHomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VerticalViewPager(),
    );
  }
}

class VerticalViewPager extends StatefulWidget {
  const VerticalViewPager({super.key});

  @override
  _VerticalViewPagerState createState() => _VerticalViewPagerState();
}

class _VerticalViewPagerState extends State<VerticalViewPager> {
  late Future<List<JokeList>> _jokesFuture = Future(() => []);
  bool isInternetConnected = false; // not using
  late SharedPreferences prefs;
  List<JokeList> bookmarkedJokesList = [];

  @override
  void initState() {
    super.initState();
    checkInternetConnectivity();
  }

  /* to check whether mobile/wifi is ON or OFF & call useCase*/
  Future<void> checkInternetConnectivity() async {
    prefs = await SharedPreferences.getInstance();
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        _jokesFuture = fetchJokes(); // ON Case
      });
    } else {
      setState(() {
        _jokesFuture = fetchOffLineJokes(); // OFF Case
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<JokeList>>(
        future: _jokesFuture,
        builder: (BuildContext context, AsyncSnapshot<List<JokeList>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          else {
            final jokes = snapshot.data!;
            return PageView.builder(
              itemCount: jokes.length,
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/jokelistbg.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Center(
                      child: Card(
                          elevation: 0,
                          child: SizedBox(
                            width: 300,
                            height: 450,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                        Colors.grey, BlendMode.srcIn),
                                    child: Image.asset(
                                      'assets/voice.png',
                                      fit: BoxFit.fill,
                                      width: 70,
                                      height: 70,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Text(
                                  jokes[index].setup,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Text(
                                  jokes[index].delivery,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 80),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      jokes[index].addToBookMark =
                                          !jokes[index].addToBookMark;
                                    });
                                    addToBookmarks(jokes[index]);
                                  },
                                  child: ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                        Colors.grey, BlendMode.srcIn),
                                    child: Image.asset(
                                      jokes[index].addToBookMark
                                          ? 'assets/bookmark.png'
                                          : 'assets/ribbon.png',
                                      width: 70,
                                      height: 70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),
                    /* to show back arrow and setting icon */
                  ],
                );
              },
              scrollDirection: Axis.vertical,
            );
          }
        },
      ),
    );
  }

  /* calling api */
  Future<List<JokeList>> fetchJokes() async {
    final response = await http.get(Uri.parse(ApiUrls.jokes_list_Url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> jokesData = jsonData['jokes'];
      final jokeList = jokesData
          .map<JokeList>((jokeData) => JokeList.fromJson(jokeData))
          .toList();

      /* checking to show selected items from db to original list,setting flag true */
      final offLineJokeList = await fetchOffLineJokes();
      for (var jokes in jokeList) {
        for (var offlineJoke in offLineJokeList) {
          if (jokes.setup == offlineJoke.setup &&
              jokes.delivery == offlineJoke.delivery) {
            jokes.addToBookMark = true;
          }
        }
      }
      return jokeList;
    } else {
      throw Exception('Failed to load jokes');
    }
  }

  /* fetch jokes from */
  Future<List<JokeList>> fetchOffLineJokes() async {
    final jokes = prefs.getStringList('bookmarked_jokes');
    if (jokes != null && jokes.isNotEmpty) {
      final List<JokeList> bookmarkedJokesList = jokes
          .map((string) => JokeList.fromJson(json.decode(string)))
          .toList();
      return bookmarkedJokesList;
    } else {
      return Future.value([]);
    }
  }

  /* for saving in preference */
  Future<void> addToBookmarks(JokeList joke) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(joke.addToBookMark
            ? 'Joke added to bookmark'
            : 'Joke removed from bookmark'),
      ),
    );
    final offlineList = await fetchOffLineJokes();
    bookmarkedJokesList = offlineList;
    if (joke.addToBookMark) {
      bookmarkedJokesList.add(joke);
    } else {
      final List<JokeList> list = [];
      for (var jokes in bookmarkedJokesList) {
        if (jokes.setup != joke.setup && jokes.delivery != joke.delivery) {
          list.add(jokes);
        }
      }
      bookmarkedJokesList.clear();
      bookmarkedJokesList.addAll(list);
    }
    final List<String> bookmarkedJokes = bookmarkedJokesList
        .map((bookmark) => json.encode(bookmark.toJson()))
        .toList();
    prefs.setStringList('bookmarked_jokes', bookmarkedJokes);
  }
}
