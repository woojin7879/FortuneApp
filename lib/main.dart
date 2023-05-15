import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _timer;
  late String _currentQuote;

  final List<String> quotes = [
    "행운은 준비된 사람의 기회다.\n\n- 로망 로랑 -",

    "성공의 열쇠는\n 기회의 문을 열 준비가 되어 있는 것이다.\n\n- 벤자민 디즈라엘리 -",

    "운은 용기 있는 자에게만 손을 내밀어 준다.\n\n- 버지니아 울프 -",

    "사람은 자신의 운명의 주인이며,\n 자신의 행운의 조종사이다.\n\n- 스네이크 -",

    "자신의 운명을 믿고 달려가라.\n 그리고 행운은 따르게 될 것이다.\n\n- 알렉산더 그레이엄 벨 -",

    "당신이 행운을 찾는다면,\n 우연히 찾은 기회 뒤에 숨어있는\n 노력과 준비를 잊지 마세요.\n\n- 콜린 푸렐 -",

    "운이 없다고 생각한다면,\n 운을 찾아 다니며\n 그 안에 들어가려 노력해보세요.\n\n- 제임스 콜리어 -",

    "행운은 용기와 결단력을 가져야\n 비로소 찾아온다.\n\n- 데미온 -",

    "행운은 용기 있는 자의 곁에 서 있다.\n\n- 루시우스 애네우스 세네카 -",

    "행운은 우리가 만들어낼 수 있는 것이다.\n 노력하고, 기다리고, 올바른 선택을 하면\n 행운은 우리와 함께한다.\n\n- 데즈몬드 투투 -",
  ];

  @override
  void initState() {
    super.initState();
    _loadRandomQuote();
    _timer = Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FortuneCookieApp()),
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _loadRandomQuote() {
    final Random random = Random();
    final int randomIndex = random.nextInt(quotes.length);
    setState(() {
      _currentQuote = quotes[randomIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[200],
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 100.0), // Add desired top and bottom padding
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '포춘 쿠키로 찾는 로또',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: Image.asset(
                  'assets/cookie.png',
                  width: 200.0,
                  height: 200.0,
                ),
              ),
              SizedBox(height: 16),
              Container(
                alignment: Alignment.center,
                child: Text(
                  _currentQuote,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fortune Cookie',
      home: SplashScreen(), // 앱 로딩 화면으로 시작
      routes: {
        '/home': (context) => FortuneCookieApp(), // 메인 화면
      },
    );
  }
}

class FortuneCookieApp extends StatefulWidget {
  @override
  _FortuneCookieAppState createState() => _FortuneCookieAppState();
}

class _FortuneCookieAppState extends State<FortuneCookieApp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  List<String> fortunes = [];
  List<String> record = [];
  final Random _random = Random();
  late SharedPreferences _preferences;

  bool _showMessage = true;

  List<int> generateLottoNumbers() {
    final List<int> numbers = List<int>.generate(45, (index) => index + 1);
    numbers.shuffle();
    return numbers.sublist(0, 6);
  }

  @override
  void initState() {
    super.initState();
    _loadFortunes();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _initializeSharedPreferences();
  }

  Future<void> _initializeSharedPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    final savedRecords = _preferences.getStringList('records') ?? [];
    setState(() {
      record = savedRecords;
    });
  }

  Future<void> _loadFortunes() async {
    final data = await rootBundle.loadString('assets/fortunes.txt');
    setState(() {
      fortunes = data.split('\n');
    });
  }

  void _showFortuneDialog(BuildContext context) {
    if (_controller.isCompleted) {
      _controller.reset();
    }
    _controller.forward();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final lottoNumbers = generateLottoNumbers()..sort();
        final fortune = _getRandomFortune();
        return AlertDialog(
          title: Text('포춘 쿠키와 로또 번호'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            AnimatedBuilder(
            animation: _animation!,
            builder: (BuildContext context, Widget? child) {
              return Transform.scale(
                scale: 1.0 + (_animation!.value * 0.3),
                child: child!,
              );
            },
            child: Image.asset(
              'assets/cookie.png',
              width: 200.0,
              height: 200.0,
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: lottoNumbers
                .map((number) => LottoBall(
              number: number,
              animation: _animation,
            ))
                .toList(),
          ),
          SizedBox(height: 16.0),
          Text(
            fortune,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
              child: Text('기록 저장'),
              onPressed: () {
                  _saveRecord(lottoNumbers, fortune);
                  Navigator.of(context).pop();
                  _controller.reset();
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                _controller.reset();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveRecord(List<int> lottoNumbers, String fortuneCookie) async {
    final recordString = '${DateTime.now()} - ${[...lottoNumbers, fortuneCookie].join(', ')}';
    setState(() {
      record.add(recordString);
    });
    await _preferences.setStringList('records', record);
  }

  String _getRandomFortune() {
    final randomIndex = _random.nextInt(fortunes.length);
    return fortunes[randomIndex];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 8.0),
            Text('포춘 쿠키와 로또 번호'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('앱 설명'),
                    content: Text(
                      '포춘 쿠키 앱은 랜덤한 로또 번호와 포춘 쿠키를 제공하는 앱입니다. '
                          '포춘 쿠키를 터치하여 로또 번호와 특별한 메시지를 확인하고, '
                          '기록에 저장하여 나중에 확인할 수 있습니다.',
                    ),
                    actions: [
                      TextButton(
                        child: Text('닫기'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            _showFortuneDialog(context);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/cookie.png',
                width: 200.0,
                height: 200.0,
              ),
              AnimatedOpacity(
                opacity: _showMessage ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    '쿠키를 터치해 행운을 확인하세요!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.history),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecordPage(record: record),
            ),
          );
        },
      ),
    );
  }
}

class RecordPage extends StatefulWidget {
  final List<String> record;

  const RecordPage({required this.record});

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _deleteRecord(int index) {
    setState(() {
      widget.record.removeAt(index);
    });
    _saveRecords(widget.record);
  }

  Future<void> _saveRecords(List<String> records) async {
    await SharedPreferences.getInstance()
        .then((preferences) => preferences.setStringList('records', records));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('뽑은 기록'),
      ),
      body: ListView.builder(
        itemCount: widget.record.length,
        itemBuilder: (context, index) {
          final recordString = widget.record[index];
          final splitRecord = recordString.split(' - ');
          final dateTime = DateTime.parse(splitRecord.first);
          final lottoNumbers = splitRecord.last.split(', ');
          final fortuneCookie = lottoNumbers.removeLast();

          return Dismissible(
            key: Key(recordString),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _deleteRecord(index);
            },
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '날짜와 시간:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '로또 번호:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: lottoNumbers.map((number) {
                      int parsedNumber;
                      try {
                        parsedNumber = int.parse(number);
                      } catch (e) {
                        // Handle the error, such as displaying an error message or using a default value
                        parsedNumber = 0;
                      }
                      return LottoBall(number: parsedNumber, animation: _animation!);
                    }).toList(),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '포춘 쿠키:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    fortuneCookie,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}










class LottoBall extends StatelessWidget {
  final int number;
  final Animation<double> animation;

  const LottoBall({required this.number, required this.animation});

  Color _getBallColor(int number) {
    if (number <= 10) {
      return Colors.red;
    } else if (number <= 20) {
      return Colors.orange;
    } else if (number <= 30) {
      return Colors.green;
    } else if (number <= 40) {
      return Colors.blue;
    } else {
      return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ballColor = _getBallColor(number);

    return RotationTransition(
      turns: animation,
      child: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ballColor,
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
