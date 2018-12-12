import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logs/logs.dart';
import 'package:url_launcher/url_launcher.dart';

import 'http.dart';
import 'model.dart';

final Log log = new Log('x-factor');

void main() {
  log.enabled = true;

  installHttpLogger();

  //debugProfileBuildsEnabled = true;

  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Crossfit X-Factor',
      theme: new ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Image.asset(
            'assets/logo_light.png',
            height: 44.0,
          ),
        ),
        body: new Center(
          child: new XFactorPage(
            title: 'Crossfit X-Factor',
          ),
        ),
      ),
    );
  }
}

class XFactorPage extends StatefulWidget {
  XFactorPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _XFactorPageState createState() => new _XFactorPageState();
}

class _XFactorPageState extends State<XFactorPage> {
  final GlobalKey<RefreshIndicatorState> indicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  final WodManager wodManager = new WodManager();

  List<Wod> wods = [];
  bool inited = false;

  @override
  Widget build(BuildContext context) {
    final RefreshIndicator indicator = new RefreshIndicator(
      key: indicatorKey,
      onRefresh: () async {
        try {
          final List<Wod> updated = await wodManager.retrieveWods();

          // TODO: remove these log statements
          if (updated.isNotEmpty) {
            Wod wod = updated.first;
            log.log(
              wod.toString(),
              data: {
                'title': wod.title,
                'description': wod.description,
                'date': wod.date,
                'category': wod.category,
                'url': wod.url,
              },
            );
            log.log(wod.toString());
          }

          setState(() {
            wods = updated;
          });
        } catch (error) {
          print('error: $error');

          Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text('Error retrieving WODs: $error'),
          ));
        }
      },
      child: new ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: wods.length,
        itemBuilder: (BuildContext context, int index) {
          final Wod wod = wods[index];
          return new WodWidget(wod);
        },
      ),
    );

    if (!inited) {
      Timer.run(() {
        inited = true;
        indicatorKey.currentState.show();
      });
    }

    return indicator;
  }
}

class WodWidget extends StatelessWidget {
  static const TextStyle titleStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
  );

  WodWidget(this.wod);

  final Wod wod;

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: GestureDetector(
        onTap: _openUrl,
        child: new Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                  wod.title,
                  style: titleStyle,
                ),
                spacer(8.0),
                new Text(wod.description),
                spacer(8.0),
                new Row(
                  children: <Widget>[
                    new Expanded(child: new Text(wod.date)),
                    new Text(wod.category),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openUrl() async {
    if (wod.url != null && await canLaunch(wod.url)) {
      await launch(wod.url);
    }
  }

  Widget spacer(double size) {
    return new Padding(
      padding: EdgeInsets.symmetric(
        vertical: size,
        horizontal: size,
      ),
    );
  }
}
