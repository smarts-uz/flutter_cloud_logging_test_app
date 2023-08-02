import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/logging/v2.dart';
import 'package:googleapis_auth/auth_io.dart';

late final LoggingApi logger;

Future<void> logEvent(String descr) async {
  final Map<String, String> params = {'message': descr};
  final logEntry = LogEntry(
    logName: 'projects/cloudloggingtestapp/logs/test-log',
    jsonPayload: params,
    resource: MonitoredResource(type: 'global'),
    labels: {'isWeb': '0'},
  );
  final req = WriteLogEntriesRequest(entries: [logEntry]);
  logger.entries.write(req);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final f = await rootBundle.loadString('assets/logger.json');
  AutoRefreshingAuthClient httpClient = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(String.fromCharCodes(f.codeUnits)), [
    LoggingApi.loggingWriteScope,
  ]);

  logger = LoggingApi(httpClient);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cloud Logging',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Cloud Logging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    logEvent('test log no. $_counter');
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
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
      ),
    );
  }
}
