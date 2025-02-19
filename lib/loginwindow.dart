
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tap/Firebase_task.dart';
import 'package:tap/gamewindow.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  String Roomid = "";
  Random random = Random();
  TextEditingController  id_controller = TextEditingController();
  bool create_room = false;
  bool join_room = false;

  Widget nav_button(String name){

    return ElevatedButton(onPressed: ()async{
           String p;

           if(name=="Join"){
             if(await Join_Room(id_controller.text)){
               p="B";    // setting player for current device
               final fb = FirebaseFirestore.instance;
               await fb.collection("room").doc(id_controller.text).update({"player2":true}).then((value){
                 Navigator.push(context, MaterialPageRoute(builder: (context)=>GameWindow(roomid: id_controller.text,player:p)));
               });

             }

           }
           else{
              p="A";
              Create_Room(Roomid);
              create_room=false;
              Navigator.push(context, MaterialPageRoute(builder: (context)=>GameWindow(roomid: Roomid,player:p)));
           }


     }, child: Text(name));
  }

  Widget showid(){
      return Column(
         children: [
           Container(
             padding: EdgeInsets.all(10),
             width: 150,
             height: 50,
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(10),
               boxShadow: [BoxShadow(color: Colors.black12,spreadRadius: 2,blurRadius: 5)],
             ),
             margin: EdgeInsets.all(10),
             alignment: Alignment.center,
             child: Text(Roomid.toString(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.w500),),
           ),
            SizedBox(height: 10,),
           // redirect to the game window
           nav_button("start game ")
         ],
      );
  }

  
  Widget joinid(){
      return Column(
        children: [
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
            width: 150,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black12,spreadRadius: 2,blurRadius: 5)],
            ),
            child: Center(
              child: TextField(
                controller: id_controller,
                decoration: InputDecoration(
                  hintText: "Enter Room code",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          nav_button("Join")
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //  create room
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    if(!create_room){
                      Roomid = random.nextInt(1000).toString();
                      create_room=true;
                      join_room=false;
                    }
                    else{
                       create_room=false;
                    }

                  });

                },
                child: Text("Create Room")),

            // show room id
            create_room
                ? showid()
                : SizedBox(),
            SizedBox(height: 20,),


            // join room
            ElevatedButton(
                onPressed: () {
                setState(() {
                  if(!join_room){
                    join_room=true;
                    create_room=false;
                  }
                  else{
                    join_room=false;
                  }
                });
            }, child: Text("Join Room")),

            // enter room code
            join_room
                ? joinid()
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
