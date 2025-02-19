
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tap/Firebase_task.dart';
import 'package:tap/loginwindow.dart';

class GameWindow extends StatefulWidget {
  final roomid;
  final String player;

  const GameWindow({super.key, this.roomid, required this.player});

  @override
  State<GameWindow> createState() => _GameWindowState();
}

class _GameWindowState extends State<GameWindow> {
  int topPosition = 0;
  int tapdistance = 30;
  bool is_showdialog = false;
  bool is_gamerest_dialog = false;
  bool dialog = false;
  int countdown = 5;
  bool win = false;

  void showdialog(String win) {

    is_gamerest_dialog = true;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Game end "),
            content: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  "Winner : $win",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Delete_Room(widget.roomid);
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => login()));
                  },
                  child: Text("Go Back"))
            ],
          );
        });

    Set_data({"winner":"none"}, widget.roomid);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (widget.player == "B") {
      Set_data({"player2": false}, widget.roomid);
    } else {
      Set_data({"player1": false}, widget.roomid);
      Delete_Room(widget.roomid);
    }
  }

  // void moveUp() {
  //   setState(() {
  //     topPosition -= tapdistance;
  //     if (topPosition < -220.0) {
  //       topPosition = 0;
  //       showdialog("Player B");
  //     }
  //   });
  // }
  //
  // void moveDown() {
  //   setState(() {
  //     topPosition += tapdistance;
  //     if (topPosition > 220.0) {
  //       topPosition = 0;
  //       showdialog("Player A");
  //     }
  //   });
  // }

  void win_logic() {
    bool tmp = false;
    if (dialog == false) {
      if (topPosition > 220.0 && topPosition != 0) {
        updateWinner(widget.roomid, "A");
        tmp=true;
        // showdialog("Player A");
      }
      if (topPosition < -220.0 && topPosition != 0) {
        updateWinner(widget.roomid, "B");
        tmp=true;
        // showdialog("Player B");
      }

      if (tmp) {
        Set_data({"position": 0}, widget.roomid);
        topPosition=0;
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tap Game (Room ID : ${widget.roomid})"),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(10),
          constraints: BoxConstraints(
            maxWidth: 400,
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black12, spreadRadius: 5, blurRadius: 5)
              ]),
          child: Column(
            children: [
              // player one control
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    if (widget.player == "A") {
                      if (topPosition > 220.0) {
                        topPosition = 0;
                        showdialog("Player A");
                      }
                      Set_Position(widget.player, topPosition, widget.roomid);
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.greenAccent,
                    ),
                    child: Center(
                      child: Text(
                        "A",
                        style: TextStyle(
                            fontSize: 60, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ),

              // game board
              Expanded(
                flex: 4,
                child: StreamBuilder<DocumentSnapshot>(
                    stream: position(widget.roomid) ?? null,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.exists) {
                          topPosition = snapshot.data!["position"];
                          win_logic();

                          WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) {

                            if(snapshot.data!["winner"]!="none" && dialog==false){
                                 topPosition=0;
                                 dialog=true;
                                 showdialog("${snapshot.data!["winner"]}");
                            }

                            // check player status
                            if (snapshot.data!["player1"] == false ||
                                snapshot.data!["player2"] == false) {
                              is_showdialog = true;
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Center(
                                        child: Text(
                                            "${snapshot.data!["player1"] == false ? "Game ended " : "Waiting for Player"}"),
                                      ),
                                      content: Container(
                                          height: 50,
                                          child: Center(
                                              child: snapshot
                                                          .data!["player1"] ==
                                                      false
                                                  ? SizedBox()
                                                  : CircularProgressIndicator())),
                                      actions: [
                                        Center(
                                          child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            login()));
                                              },
                                              child: Text("Go back ")),
                                        )
                                      ],
                                    );
                                  });
                            } else {

                              if (is_showdialog) {
                                is_showdialog = false;
                                Navigator.pop(context);
                              }
                            }
                          });
                        }
                      }
                      return LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.blueAccent),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 10,
                                width: double.infinity,
                                color: Colors.white,
                              ),
                              AnimatedPositioned(
                                duration: Duration(milliseconds: 200),
                                top: constraints.maxHeight / 2.3 + topPosition,
                                child: Center(
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.yellow,
                                      border: Border.all(
                                        width: 10,
                                        color: Colors.blueAccent,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.limeAccent,
                                          spreadRadius: 10,
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                    }),
              ),

              // player 2 control
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    if (widget.player == "B") {
                      if (topPosition < -220.0) {
                        topPosition = 0;
                        showdialog("Player B");
                      }
                      Set_Position("B", topPosition, widget.roomid);
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.greenAccent,
                    ),
                    child: Center(
                      child: Text(
                        "B",
                        style: TextStyle(
                            fontSize: 60, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class testing extends StatefulWidget {
  const testing({super.key});

  @override
  State<testing> createState() => _testingState();
}

class _testingState extends State<testing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          print(constraints.maxHeight / 2);
          return Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Container(
                //    height: 20,
                //    color: Colors.blueAccent,
                // ),
                Positioned(
                  height: 100,
                  bottom: constraints.maxHeight / 2,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.greenAccent,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
