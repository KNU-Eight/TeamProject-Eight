import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prevent_rental_fraud/screens/intro_page.dart';
import 'package:prevent_rental_fraud/screens/login_page.dart';
import 'global_value_controller.dart';
import 'package:prevent_rental_fraud/screens/main_page_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  List<String> newsLinks = ["https://www.naver.com", "https://www.naver.com", "https://www.naver.com", "https://www.naver.com"];
  Get.put(GlobalValueController());
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(MyApp(newsLinks: newsLinks,));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.newsLinks
  });
  final List<String> newsLinks;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.find<GlobalValueController>().updateScreenHeight(MediaQuery.of(context).size.height);
    Get.find<GlobalValueController>().updateScreenWidth(MediaQuery.of(context).size.width);
    return GetMaterialApp(
      title: 'Flutter Demo',
      home: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 3), () => "Intro Completed."),
        builder: (context, snapshot){
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            child: _splashLoadingWidget(snapshot)
          );
        }
      )
    );
  }
  Widget _splashLoadingWidget(AsyncSnapshot<Object?> snapshot) {
    if(snapshot.hasError) {
      return const Text("Error!!"); // 에러 메시지
    } else if(snapshot.hasData) {
      // 사용자가 로그인되어 있다면 MainPageView로 이동
      if (snapshot.data is User) { // 사용자 객체인지 확인
        return SafeArea(child: MainPageView()); // MainPageView로 이동
      }
      return SafeArea(child: LoginPage(newsLinks: newsLinks)); // 로그인 페이지로 이동
    } else {
      return const SafeArea(child: IntroPage()); // 인트로 페이지로 이동
    }
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
