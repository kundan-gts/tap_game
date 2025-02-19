import 'package:cloud_firestore/cloud_firestore.dart';

String Room= "room";





// create room
void Create_Room(String id  )async{
   final fb = FirebaseFirestore.instance;
   fb.collection(Room).doc(id).set({"position":0,"player1":true,"player2":false,"winner":"none"});
}

// join room
Future<bool>Join_Room(String id)async{
  final fb = FirebaseFirestore.instance;

  DocumentSnapshot snapshot= await fb.collection(Room).doc(id).get();
  if(snapshot.exists){
      print("room founded");
      return true;
  }
  else{
     print("room not founded");
     return false;
  }
}


void updateWinner(String documentId,String winner) async {
  final fb = FirebaseFirestore.instance;
  DocumentSnapshot docSnapshot = await fb.collection("room").doc(documentId).get();

  // Check if the winner field contains "none"
  if (docSnapshot.exists && docSnapshot.get("winner") == "none") {
    // Update the winner field to "A"
    await fb.collection("room").doc(documentId).update({"winner":winner});
  }
}





// set position
void Set_Position (String player,int pos,String Rid)async{

   if(player=="A"){
       pos=pos+20;

   }
   else{
       pos=pos-20;
   }

   // set position value in firebase
   final fb = FirebaseFirestore.instance;
   await fb.collection("room").doc(Rid).update({
       "position":pos
   });
   Set_data({"position":pos}, Rid);
}

void Set_data(Map<String,dynamic> data,String id)async{
  final fb = FirebaseFirestore.instance;
  await fb.collection("room").doc(id).update(data);
}



void Delete_Room(String id){
  final fb = FirebaseFirestore.instance;
  fb.collection(Room).doc(id).delete();
}



Stream<DocumentSnapshot> position (String id ){
    final fb = FirebaseFirestore.instance;
    return  fb.collection("room").doc(id).snapshots();
}