import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skype_clone/models/message.dart';

class LastMessageContainer extends StatelessWidget {
  final stream;

  LastMessageContainer({
    @required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          var docList = snapshot.data.docs;

          if (docList.isNotEmpty) {
            Message message = Message.fromMap(docList.last.data());
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                   message.message.length > 20 ?  message.message.substring(0,20) : message.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
       
                    style: GoogleFonts.cuprum(textStyle :TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                    ),)
                  ),
                  
                  Text(dateTimeFormat(message.timestamp.toDate()),
                    style: GoogleFonts.cuprum(textStyle :TextStyle(
                      color: Colors.grey,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold
                    ),))
                ],
              ),
            );
          }
          return Text(
            "No Message",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          );
        }
        return Text(
          "..",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        );
      },
    );
  }

  String dateTimeFormat(DateTime time){
   return  time.day.toString() +"/" +time.month.toString() + "/" + time.year.toString();
  }
}
