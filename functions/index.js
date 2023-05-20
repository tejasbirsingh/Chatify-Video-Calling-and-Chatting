// const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
// const admin = require('firebase-admin')
// admin.initializeApp()
// exports.sendNotification = functions.firestore.document("messages/{sender}/{receiver}/{notification}")
// .onCreate(async (snapshot,context)=>{

// try {
//     const notificationsDocument=snapshot.data()
//     console.log(notificationsDocument)
//     const uid = context.params.user;
//     const message = notificationsDocument.message;
//     const userDoc = await admin.firestore().collection("messages").doc(uid).collection(notificationsDocument.receiverId).get()
//     const tokenFcm=userDoc.data().token;
//     const message={
//         "notification":{
//             title:"New Message",
//             body: message
//         },
//         token:tokenFcm
//     }
//     return admin.messaging().send(message)

// } catch (error) {
//     console.log(error)
// }

// })

const functions = require('firebase-functions')
const admin = require('firebase-admin')
admin.initializeApp()

exports.sendNotification = functions.firestore
  .document('messages/{groupId1}/{groupId2}/{message}')
  .onCreate((snap, context) => {
    console.log('----------------start function--------------------')

    const doc = snap.data()
    console.log(doc)

    const idFrom = doc.senderId
    const idTo = doc.receiverId
    const contentMessage = doc.message

    // Get push token user to (receive)
    admin
      .firestore()
      .collection('users')
      .where('id', '==', idTo)
      .get()
      .then(querySnapshot => {
        querySnapshot.forEach(userTo => {
          console.log(`Found user to: ${userTo.data().name}`)
          if (userTo.data().pushToken && userTo.data().chattingWith !== idFrom) {
            // Get info user from (sent)
            admin
              .firestore()
              .collection('users')
              .where('id', '==', idFrom)
              .get()
              .then(querySnapshot2 => {
                querySnapshot2.forEach(userFrom => {
                  console.log(`Found user from: ${userFrom.data().name}`)
                  const payload = {
                    notification: {
                      title: `You have a message from "${userFrom.data().name}"`,
                      body: contentMessage,
                      badge: '1',
                      sound: 'default'
                    }
                  }
                  // Let push to the target device
                  admin
                    .messaging()
                    .sendToDevice(userTo.data().pushToken, payload)
                    .then(response => {
                      console.log('Successfully sent message:', response)
                    })
                    .catch(error => {
                      console.log('Error sending message:', error)
                    })
                })
              })
          } else {
            console.log('Can not find pushToken target user')
          }
        })
      })
    return null
  })