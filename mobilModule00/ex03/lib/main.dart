import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ex02 Mobile Piscine',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
      ),
      home: const MyHomePage(title: 'Calculator'),
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
  
  String _expression = '';
  String _result = '0';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[400],
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: 
                Container(
                  color: Colors.grey[800],
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.all(16),
                  child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _expression,
                          style: TextStyle(color: Colors.white, fontSize: 32),
                        ),
                        Text(
                          _result,
                          style: TextStyle(color: Colors.white, fontSize: 32),
                        ),

                      ],
                    )
                  
                   
                ),        
            ),
          Expanded(
            flex: 5,
            child:
              Container(
                color: Colors.grey[400],
                width: double.infinity,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(16),
                child:
                    Column(
                      children:[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ElevatedButton(onPressed: () { setState((){_expression += '7';}); }, child: const Text('7')),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: () { setState((){_expression += '8';}); }, child: const Text('8')),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: () { setState((){_expression += '9';}); }, child: const Text('9')),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: () {
                              setState((){
                                 if (_expression.isNotEmpty) {
                                    _expression = _expression.substring(0, _expression.length - 1);
                                  }
                            });}, child: const Text('C')),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: () {
                              setState(() {
                                  _expression = '';
                                  _result = '0';
                                });
                                }, child: const Text('AC')),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ElevatedButton(onPressed: () { setState((){_expression += '4';}); }, child: const Text('4')),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: () { setState((){_expression += '5';}); }, child: const Text('5')),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: () { setState((){_expression += '6';});  }, child: const Text('6')),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: () { setState((){_expression += '+';}); }, child: const Text('+')),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: () { setState((){_expression += '-';});  }, child: const Text('-')),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ElevatedButton(onPressed: () { setState((){_expression += '1';}); }, child: const Text('1')),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: () { setState((){_expression += '2';}); }, child: const Text('2')),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: () { setState((){_expression += '3';}); }, child: const Text('3')),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: () { setState((){_expression += 'x';}); }, child: const Text('x')),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: () { setState((){_expression += '/';}); }, child: const Text('/')),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ElevatedButton(onPressed: () { setState((){_expression += '0';});  }, child: const Text('0')),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: () { setState((){_expression += '.';}); }, child: const Text('.')),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: () { setState((){_expression += '00';});  }, child: const Text('00')),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: () {
                              try {
                                Parser p = Parser();
                                Expression exp = p.parse(_expression.replaceAll('x', '*'));
                                ContextModel cm = ContextModel();
                                double eval = exp.evaluate(EvaluationType.REAL, cm);
                                setState(() {
                                  _result = eval.toString();
                                });
                              }
                              catch (e){
                                setState(() {
                                  _result = 'Error';
                                });
                              }
                            }, child: const Text('=')),
                          ],
                        ),
                      ],
                    ),
                ),
            ),
        ],
      ),
    );
  }
}
                    



