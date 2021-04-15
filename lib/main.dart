import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var title = 'A Good Dog';
    var dogURL = imageURLFromAPI('https://dog.ceo/api/breeds/image/random');

    return MaterialApp(
        title: title,
        home: _homeScreen(dogURL,title),
    );
  }

  Widget _homeScreen(var dogURL, var title){
    //var dogName = _dogBreed(dogURL);
    //var dogImage = _dogImage(dogURL);
    return Scaffold(
          appBar: AppBar(title: Text(title)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () =>  runApp(MyApp()),
            label: const Text("Fetch"),
            icon: const Icon(Icons.refresh),
            tooltip: "Find a new picture",

          ),
          body: _mainBody(dogURL)

      );

  }

  Widget _mainBody(var dogURL){
    var dogName = _dogBreed(dogURL);
    var dogImage = _dogImage(dogURL);
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 20.0),
          ),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                dogName,
              ]
          ),
          Container(
            padding: const EdgeInsets.only(top: 20.0),
            child: dogImage,
          )
        ]
    );
  }

  Widget _dogImage(var dogURL){
    return Container(
      margin: const EdgeInsets.all(10.0),
      color: Colors.black,
      width: 300.0,
      height: 500.0,
      child: FutureBuilder(
        future: dogURL,
        builder: (context,snapshot){
          switch (snapshot.connectionState){
            case ConnectionState.none:
              return Text('none');
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Text('Image of a dog is loading');
            default:
              return Image.network(snapshot.data);
          }
        },
      ),
    );
  }

  Widget _dogBreed(var dogURL){
    return Container(
      child: FutureBuilder(
        future: dogURL,
        builder: (context,snapshot){
          switch (snapshot.connectionState){
            case ConnectionState.none:
              return Text('none');
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Column(
                children: [
                  Text('Dog is loading \n', style: TextStyle(fontSize: 15.0),),
                  Text(" ", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),),
                ],
              );
            default:
              return Column(
                children: [
                  Text(
                    "Their breed is: \n",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 15.0),
                  ),
                  Text(
                    _parseBreedFromURL(snapshot.data),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                  ),
                ],
              );
          }
        },
      ),
    );
  }

  String _parseBreedFromURL(String URL){
    String match;
    RegExp regex = RegExp("(?<=breeds\\\/).+(?=\\\/)");
    RegExp dash = RegExp("-");
    RegExp dashAhead = RegExp("(?<=-).+");
    RegExp dashBehind = RegExp(".+(?=-)");
    //print("match : "+regex.firstMatch(URL).group(0));
    match = regex.firstMatch(URL).group(0).capitalize();
    if (dash.hasMatch(match)){
      return dashAhead.firstMatch(match).group(0).capitalize()+" "+dashBehind.firstMatch(match).group(0);
    }else{
      return match;
    };


  }
}

Future<String> imageURLFromAPI(String apiURL) async{

  http.Response response = await http.get(Uri.parse(apiURL));
  String url = await json.decode(response.body)['message'];
  return url;
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}