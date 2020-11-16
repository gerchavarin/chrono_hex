import 'dart:async';

import 'package:flutter/material.dart';

class FlutterStopWatch extends StatefulWidget {
  @override
  _FlutterStopWatchState createState() => _FlutterStopWatchState();
}

class _FlutterStopWatchState extends State<FlutterStopWatch> {
  bool flag = true;
  Stream<int> timerStream;
  StreamSubscription<int> timerSubscription;
  int seconds = 0;
  String secondsStr_hex = '000000';
  bool started = false;
  List laps = [];

  void addLap() {
    String lap = secondsStr_hex;
    setState(() {
      this.laps.add(lap);
      print(lap);
    });
  }

  Stream<int> stopWatchStream() {
    StreamController<int> streamController;
    Timer timer;
    Duration timerInterval = Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer.cancel();
        timer = null;
        counter = 0;
        streamController.close();
      }
    }

    void tick(_) {
      counter++;
      streamController.add(counter);
      if (!flag) {
        stopTimer();
      }
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cronómetro Hexadecimal")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$secondsStr_hex",
              style: TextStyle(
                fontSize: 90.0,
              ),
            ),
            SizedBox(height: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  padding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  onPressed: () {
                    if(started) {
                      started = false;
                      timerSubscription.cancel();
                      timerStream = null;
                      setState(() {
                        seconds = 0;
                      });
                    } else {
                      started = true;
                      timerStream = stopWatchStream();
                      timerSubscription = timerStream.listen((int newTick) {
                        setState(() {
                          seconds += 1;
                          secondsStr_hex = seconds.toRadixString(16).toUpperCase().padLeft(6, '0');
                        });
                      });
                    }
                  },
                  color: started ? Colors.red : Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    started ? 'Stop' : 'Start',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                    ),

                  ),
                ),
                SizedBox(width: 40.0),
                RaisedButton(
                  padding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  onPressed: () {
                    this.laps.add(secondsStr_hex);
                    print(secondsStr_hex);
                  },
                  color: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    'Lap',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                    ),
                  ),
                ),

              ],
            ),

            Expanded(
              child:
              new ListView.builder
                (
                  padding:
                  EdgeInsets.symmetric(horizontal: 50.0, vertical: 8.0),
                  itemCount: laps.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return new Text('lap ' + (index + 1).toString()  + ': ' + laps[index]);
                  }
              )
            )
          ],
        ),
      ),
    );
  }
}