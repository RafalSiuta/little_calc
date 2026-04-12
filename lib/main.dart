import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'model/calculator_logic.dart';
import 'utils/column_row_builder.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CalculatorLogic(),
        ),
      ],
      child: MaterialApp(
        title: 'Little calc',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> keysList = [
    'C',
    '+/-',
    '%',
    "*",
    "7",
    "8",
    "9",
    "/",
    "4",
    "5",
    "6",
    "-",
    "1",
    "2",
    "3",
    "+",
    "0",
    ".",
    "="
  ];
  List row1 = [];
  List row2 = [];
  List row3 = [];
  List row4 = [];
  List row5 = [];
  @override
  void initState() {
    super.initState();
    row1 = keysList.getRange(0, 4).toList();
    row2 = keysList.getRange(4, 8).toList();
    row3 = keysList.getRange(8, 12).toList();
    row4 = keysList.getRange(12, 16).toList();
    row5 = keysList.getRange(16, 19).toList();
    // print(keysList.length);
    // print(keysList.getRange(0, 4));
    // print(keysList.getRange(4, 8));
    // print(keysList.getRange(8, 12));
    // print(keysList.getRange(12, 16));
    // print(keysList.getRange(16, 19));
    // var first = 0;
    // var last = 0;
    // for (var i = 0; i < keysList.length; i++) {
    //   if (i % 4 == 0) {
    //     first = i;
    //     last += 4;
    //     if (last > 16) {
    //       break;
    //     }
    //     print("##########");
    //     print("first:${first}");
    //     print("last:${last}");
    //     print(keysList.getRange(first, last));
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    const displayStyle =
        TextStyle(fontSize: 45, color: Colors.green, fontFamily: 'Exo');
    const btnStyle =
        TextStyle(fontSize: 21, color: Color(0xff5E5A5A), fontFamily: 'Exo');
    const btnOperatorStyle =
        TextStyle(fontSize: 21, color: Color(0xff5E5A5A), fontFamily: 'Calc');
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<CalculatorLogic>(
        builder: (context, data, child) {
          return Container(
            width: 320,
            height: 600,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  const Color(0xff000201).withOpacity(0.3), //Color(0xff1B2727)
                  const Color(0xff104908).withOpacity(0.5),
                ])),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 9.0, top: 20, bottom: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RichText(
                        text:
                            TextSpan(style: displayStyle, children: <TextSpan>[
                          TextSpan(
                            text: data.display.length >= 11
                                ? '${data.display.substring(0, 11)}\n'
                                : data.display,
                          ),
                          TextSpan(
                              text: data.display.length >= 12
                                  ? data.display
                                      .substring(12, data.display.length)
                                  : '',
                              style: displayStyle.copyWith(fontSize: 15))
                        ]),
                        maxLines: 3,
                      ),
                      //Text(data.display, style: displayStyle),
                      const SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
                // ColumnBuilder(
                //     itemCount: 5,
                //     itemBuilder: (context, colIndex) {
                //       if (colIndex % 4 == 0) {
                //         // print(colIndex);
                //         first = colIndex;
                //         last += 4;
                //
                //         if (last > 16) {
                //           keysList.getRange(first, last).toList();
                //         }
                //         if (colIndex == 4) {
                //           keysList.getRange(16, 19).toList();
                //         }
                //       }
                //       print("first:${first}");
                //       print("last:${last}");
                //       return RowBuilder(
                //         itemCount: keysList.length,
                //         itemBuilder: (context, index) {
                //           return Expanded(
                //             flex: colIndex == 4 && index == 4 ? 3 : 1,
                //             child: TextButton(
                //               onPressed: () {},
                //               child: Padding(
                //                   padding: const EdgeInsets.symmetric(
                //                       horizontal: 6.0, vertical: 12),
                //                   child: Text(
                //                     keysList[index],
                //                     style: index == 3 ? btnOperatorStyle : btnStyle,
                //                   )),
                //             ),
                //           );
                //         },
                //       );
                //     }),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  color: const Color(0xff1B2727),
                  child: Column(
                    children: [
                      const Divider(
                        height: 0.5,
                        thickness: 0.5,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      RowBuilder(
                        itemCount: row1.length,
                        itemBuilder: (context, index) {
                          return Expanded(
                            child: TextButton(
                              onPressed: () {
                                data.multifunction(row1[index]);
                              },
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 12),
                                  child: Text(
                                    row1[index],
                                    style: index == 3
                                        ? btnOperatorStyle
                                        : btnStyle,
                                  )),
                            ),
                          );
                        },
                      ),
                      RowBuilder(
                        itemCount: row2.length,
                        itemBuilder: (context, index) {
                          return Expanded(
                            child: TextButton(
                              onPressed: () {
                                data.multifunction(row2[index]);
                              },
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 12),
                                  child: Text(
                                    row2[index],
                                    style: index == 3
                                        ? btnOperatorStyle
                                        : btnStyle,
                                  )),
                            ),
                          );
                        },
                      ),
                      RowBuilder(
                        itemCount: row3.length,
                        itemBuilder: (context, index) {
                          return Expanded(
                            child: TextButton(
                              onPressed: () {
                                data.multifunction(row3[index]);
                              },
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 12),
                                  child: Text(
                                    row3[index],
                                    style: index == 3
                                        ? btnOperatorStyle
                                        : btnStyle,
                                  )),
                            ),
                          );
                        },
                      ),
                      RowBuilder(
                        itemCount: row4.length,
                        itemBuilder: (context, index) {
                          return Expanded(
                            child: TextButton(
                              onPressed: () {
                                data.multifunction(row4[index]);
                              },
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 12),
                                  child: Text(
                                    row4[index],
                                    style: index == 3
                                        ? btnOperatorStyle
                                        : btnStyle,
                                  )),
                            ),
                          );
                        },
                      ),
                      RowBuilder(
                        itemCount: row5.length,
                        itemBuilder: (context, index) {
                          return Expanded(
                            flex: index == 2 ? 2 : 1,
                            child: TextButton(
                              onPressed: () {
                                data.multifunction(row5[index]);
                              },
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 12),
                                  child: Text(
                                    row5[index],
                                    style: index == 3
                                        ? btnOperatorStyle
                                        : btnStyle,
                                  )),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
