import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:yomu_no_ikiru/Api/firebase_messaging.dart';
import 'constants.dart';
import 'model/firebase_options.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';
import 'package:rive/rive.dart';
import 'dart:io';

import 'model/rive_assets.dart';
import 'view/Pages/user_page.dart';
import 'controller/google_sign_in_provider.dart';
import 'controller/utils.dart';
import 'view/Pages/home_page.dart';
import 'view/Pages/library_page.dart';
import 'view/Pages/search_page.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
  // await dotenv.load(fileName: ".env");
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: Utils.messengerKey,
      title: 'Manga!',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const NavigationBarWidget(),
      routes: {
        LibraryPage.route: (context) => const LibraryPage(),
      },
    );
  }
}

class NavigationBarWidget extends StatefulWidget {
  const NavigationBarWidget({super.key});

  @override
  State<NavigationBarWidget> createState() => _NavigationBarWidgetState();
}

class _NavigationBarWidgetState extends State<NavigationBarWidget> {
  int _selectPage = 0;

  RiveAsset selectedButton = bottomNavigators.first;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: NavigationBarTheme(
            data: Theme.of(context).navigationBarTheme,
            child: NavigationBar(
              selectedIndex: _selectPage,
              height: 45,
              animationDuration: const Duration(milliseconds: 400),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              onDestinationSelected: (value) {
                bottomNavigators[value].input!.change(true);
                Future.delayed(
                  const Duration(seconds: 1),
                  () {
                    bottomNavigators[value].input!.change(false);
                  },
                );
                setState(() {
                  selectedButton = bottomNavigators[value];
                  _selectPage = value;
                });
              },
              destinations: [
                ...List.generate(
                  bottomNavigators.length,
                  (index) => NavigationDestination(
                    icon: SizedBox(
                      height: 36,
                      width: 36,
                      child: Opacity(
                        opacity: bottomNavigators[index] == selectedButton ? 1 : .5,
                        child: RiveAnimation.asset(
                          bottomNavigators.first.src,
                          artboard: bottomNavigators[index].artboard,
                          onInit: (artboard) {
                            StateMachineController controller = Utils.getRiveController(artboard,
                                stateMachineName: bottomNavigators[index].stateMachineName);
                            bottomNavigators[index].input = controller.findSMI("active");
                          },
                        ),
                      ),
                    ),
                    label: bottomNavigators[index].title,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: LazyLoadIndexedStack(
          index: _selectPage,
          children: const [
            HomePage(),
            SearchPage(),
            LibraryPage(),
            UserPage(),
          ],
        ),
      ),
    );
  }
}
