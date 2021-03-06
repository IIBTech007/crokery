import 'dart:io';
import 'package:capsianfood/networks/network_operations.dart';
import 'package:capsianfood/screens/WelcomeScreens/SplashScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/localization_delegate.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:geolocator/geolocator.dart';


// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]).then((_) {
//     SharedPreferences.getInstance().then((prefs) {
//       var darkModeOn = prefs.getBool('darkMode') ?? true;
//       runApp(
//         ChangeNotifierProvider<ThemeNotifier>(
//           create: (_) => ThemeNotifier(darkModeOn ? darkTheme : lightTheme),
//           child: MyApp(),
//         ),
//       );
//     });
//   });
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final themeNotifier = Provider.of<ThemeNotifier>(context);
//     return MaterialApp(
//       title: 'Chitr',
//       debugShowCheckedModeBanner: false,
//       theme: themeNotifier.getTheme(),
//       home: SplashScreen(,
//     );
//   }
// }


void main() async{
  FirebaseMessaging _firebaseMessaging;
  final Geolocator _geolocator = Geolocator();
  Position _currentPosition;
  var delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en_US',
      supportedLocales: ['en_US', 'es','ur', 'ar']);
    await _geolocator.isLocationServiceEnabled().then((value) {
      if(!value){
        _geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) async {
          _currentPosition = position;
        }).catchError((e) {
          print(e);
        });
      }
    });

  _firebaseMessaging= FirebaseMessaging();
  _firebaseMessaging.getToken().then((value) {
    print(value+"Device ID");
  });
  _firebaseMessaging.configure(
      onMessage:(Map<String, dynamic> message)async{
        print(message);
        showOverlayNotification((context) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: SafeArea(
              child: ListTile(
                leading:Icon(Icons.notifications,color: Theme.of(context).primaryColor,size: 40,),
                title: Text(message['notification']['title']),
                 subtitle: Text(message['notification']['body']),
                onTap: (){
                  // push(context, MaterialPageRoute(builder: (context)=>NotificationListPage()));
                  //  Navigator.push(context, MaterialPageRoute(builder: (context)=>MainPage()));

                },
                trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      OverlaySupportEntry.of(context).dismiss();
                    }),
              ),
            ),
          );
        }, duration: Duration(milliseconds: 5000));
      },
      onBackgroundMessage: Platform.isIOS ? null : networksOperation.myBackgroundMessageHandler,
      onResume: (Map<String, dynamic> message) async{
        print(message.toString());
      },
      onLaunch: (Map<String, dynamic> message)async{
        print(message.toString());
      }
  );

  runApp(LocalizedApp(delegate, MyApp()));
}

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: OverlaySupport(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Translate Demo',
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            localizationDelegate
          ],
          supportedLocales: localizationDelegate.supportedLocales,
          locale: localizationDelegate.currentLocale,
          //theme: ThemeData(primarySwatch: Colors.blue),
          home: SplashScreen(),
          //AwesomeCard()// MainPage()

        ),
      ),
    );
  }
}
