import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:intl/intl.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proportionale Zuordnungen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Umrechner für proportionale Zuordnungen'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

typedef ValueSetter<T> = void Function(T value);

class _MyHomePageState extends State<MyHomePage> {
  double factor = 1.5;
  double x = 3.0;
  double y = 3.0 * 1.5;
  String leftUnit = 'kg';
  String rightUnit = '€';
  bool factorLocked = true;
  final List<String> availableUnits = [
    'Stück',
    '€',
    'g',
    'kg',
    't',
    's',
    'min',
    'h',
    'mm',
    'cm',
    'm',
    'km',
    'm²',
    'l',
  ];

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width * 0.38;
    if (size > MediaQuery.of(context).size.height * 0.64)
      size = MediaQuery.of(context).size.height * 0.64;
    return Scaffold(
      body: Transform.translate(
        offset: Offset(0, size * 0.05),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size * 2.475,
                height: size * 0.15,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size * 0.1),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(),
                        Text("Proportionalitätsfaktor: ",
                            style: TextStyle(fontSize: size * 0.07)),
                        SizedBox(width: size * 0.05, height: 1),
                        SizedBox(
                          width: size * 0.28,
                          child: Text(formatValue(getDisplayValue(factor)),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size * 0.07)),
                        ),
                        if (leftUnit != rightUnit)
                          Text(" ${rightUnit} / ${leftUnit}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size * 0.07)),
                        SizedBox(width: size * 0.05, height: 1),
                        Ink(
                            decoration: ShapeDecoration(
                              color:
                                  factorLocked ? Colors.black12 : Colors.amber,
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                                iconSize: size * 0.05,
                                onPressed: () {
                                  setState(() {
                                    factorLocked = !factorLocked;
                                  });
                                },
                                icon: Icon(
                                  factorLocked ? Icons.lock : Icons.lock_open,
                                  color: factorLocked
                                      ? Colors.black54
                                      : Colors.white,
                                ))),
                        Spacer(),
                      ]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      controlledGauge(size, x, leftUnit, true, (v) {
                        setState(() {
                          x = v;
                          if (x < 0.01) x = 0.01;
                          if (x > 10000.0) x = 10000.0;
                          if (factorLocked)
                            y = getDisplayValue(x) * factor;
                          else {
                            factor = getDisplayValue(
                                getDisplayValue(y) / getDisplayValue(x));
                            if (factor < 0.0001) {
                              x = getDisplayValue(y) / 0.0001;
                              if (x < 0.01) x = 0.01;
                              if (x > 10000.0) x = 10000.0;
                              factor = getDisplayValue(
                                  getDisplayValue(y) / getDisplayValue(x));
                            }
                          }
                        });
                      }),
                      Padding(
                          padding: EdgeInsets.only(
                              bottom: size * 0.04,
                              right: size * 0.1,
                              left: size * 0.3),
                          child: Text('unabhängige Größe',
                              style: TextStyle(fontSize: size * 0.05))),
                      Center(
                        child: SizedBox(
                          width: size * 1.2,
                          height: size * 0.1,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: size * 0.3, right: size * 0.1),
                            child: ScrollSnapList(
                              initialIndex:
                                  availableUnits.indexOf(leftUnit).toDouble(),
                              dynamicItemSize: false,
                              onItemFocus: (index) {
                                setState(() {
                                  leftUnit = availableUnits[index];
                                });
                              },
                              itemSize: size * 0.17,
                              itemBuilder: (context, index) {
                                bool selected =
                                    leftUnit == availableUnits[index];
                                return Container(
                                  color: Colors.white10,
                                  width: size * 0.17,
                                  alignment: Alignment.center,
                                  child: Text(availableUnits[index],
                                      style: TextStyle(
                                          color: selected
                                              ? Colors.black
                                              : Colors.black54,
                                          fontSize:
                                              size * (selected ? 0.06 : 0.06),
                                          fontWeight: (selected
                                              ? FontWeight.bold
                                              : FontWeight.normal))),
                                );
                              },
                              itemCount: availableUnits.length,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      controlledGauge(size, y, rightUnit, false, (v) {
                        setState(() {
                          y = v;
                          if (y < 0.01) y = 0.01;
                          if (y > 10000.0) y = 10000.0;
                          if (factorLocked)
                            x = getDisplayValue(y) / factor;
                          else {
                            factor = getDisplayValue(
                                getDisplayValue(y) / getDisplayValue(x));
                            if (factor < 0.0001) {
                              y = getDisplayValue(x) * 0.0001;
                              if (y < 0.01) y = 0.01;
                              if (y > 10000.0) y = 10000.0;
                              factor = getDisplayValue(
                                  getDisplayValue(y) / getDisplayValue(x));
                            }
                          }
                        });
                      }),
                      Padding(
                          padding: EdgeInsets.only(
                              bottom: size * 0.04,
                              left: size * 0.1,
                              right: size * 0.3),
                          child: Text('abhängige Größe',
                              style: TextStyle(fontSize: size * 0.05))),
                      Center(
                        child: SizedBox(
                          width: size * 1.2,
                          height: size * 0.1,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: size * 0.1, right: size * 0.3),
                            child: ScrollSnapList(
                              initialIndex:
                                  availableUnits.indexOf(rightUnit).toDouble(),
                              dynamicItemSize: false,
                              onItemFocus: (index) {
                                setState(() {
                                  rightUnit = availableUnits[index];
                                });
                              },
                              itemSize: size * 0.17,
                              itemBuilder: (context, index) {
                                bool selected =
                                    rightUnit == availableUnits[index];
                                return Container(
                                  color: Colors.white10,
                                  width: size * 0.17,
                                  alignment: Alignment.center,
                                  child: Text(availableUnits[index],
                                      style: TextStyle(
                                          color: selected
                                              ? Colors.black
                                              : Colors.black54,
                                          fontSize:
                                              size * (selected ? 0.06 : 0.06),
                                          fontWeight: (selected
                                              ? FontWeight.bold
                                              : FontWeight.normal))),
                                );
                              },
                              itemCount: availableUnits.length,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Transform.translate(
                  offset: Offset(0, -size * 0.375),
                  child: Icon(Icons.arrow_right_alt, size: size * 0.15)),
            ],
          ),
        ),
      ),
    );
  }

  double getDisplayValue(double value) {
    const List<int> places = [100, 100, 10, 1, 1];
    int exp = 0;
    int max = 1;
    while (value > max) {
      exp += 1;
      max *= 10;
    }
    int p = 1;
    if (exp < places.length) p = places[exp];

    double result = (value * p).floor().toDouble() / p;
    developer.log('$result');
    return result;
  }

  String formatValue(double value) {
    String s = value.toStringAsFixed(10).replaceAll('.', ',');
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r',$'), '');
    return s;
  }

  Widget controlledGauge(double size, double value, String unit, bool leftSide,
      ValueSetter<double> onChange) {
    int exp = 0;
    int max = 1;
    while (value > max) {
      exp += 1;
      max *= 10;
    }
    double displayValue = getDisplayValue(value);
    String prettyValue = formatValue(displayValue);
    List<Widget> children = [
      GestureDetector(
        onVerticalDragUpdate: (details) {
          double sign = details.delta.dy > 0 ? -1 : 1;
          double magnitude = details.delta.dy.abs();
          magnitude = math.pow(magnitude, 2.0).toDouble() * 0.0001;
          double dy = magnitude * sign * max;
          double newValue = value + dy;
          onChange(newValue);
        },
        child: Container(
          width: size * 0.2,
          height: size,
          decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/metal.jpg'),
                fit: BoxFit.cover,
              ),
              // color: Colors.black12,
              borderRadius: BorderRadius.all(Radius.circular(size * 0.05))),
          child: Opacity(
            opacity: 0.4,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: size * 0.04),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      FeatherIcons.chevronUp,
                      size: size * 0.1,
                    ),
                    Icon(FeatherIcons.chevronDown, size: size * 0.1),
                  ]),
            ),
          ),
        ),
      ),
      SizedBox(
        width: size,
        height: size,
        child: SfRadialGauge(
          // enableLoadingAnimation: true,
          axes: <RadialAxis>[
            RadialAxis(
                minimum: 0,
                maximum: max.toDouble(),
                startAngle: 135,
                endAngle: 405,
                canScaleToFit: true,
                interval: max / 10,
                radiusFactor: 0.95,
                labelFormat: '{value}',
                labelsPosition: ElementsPosition.outside,
                canRotateLabels: true,
                ticksPosition: ElementsPosition.inside,
                labelOffset: 25,
                numberFormat: NumberFormat.compact(locale: 'de'),
                minorTickStyle: MinorTickStyle(
                    length: size * 0.01,
                    lengthUnit: GaugeSizeUnit.logicalPixel,
                    color: Colors.black26,
                    thickness: size * 0.003),
                majorTickStyle: MajorTickStyle(
                    length: size * 0.02,
                    lengthUnit: GaugeSizeUnit.logicalPixel,
                    color: Colors.black45,
                    thickness: size * 0.003),
                minorTicksPerInterval: 9,
                pointers: <GaugePointer>[
                  NeedlePointer(
                      value: displayValue,
                      needleStartWidth: size * 0.001,
                      needleEndWidth: size * 0.003,
                      needleLength: size * 0.35,
                      lengthUnit: GaugeSizeUnit.logicalPixel,
                      knobStyle: KnobStyle(
                        knobRadius: size * 0.02,
                        sizeUnit: GaugeSizeUnit.logicalPixel,
                      ),
                      tailStyle: TailStyle(
                          width: size * 0.005,
                          lengthUnit: GaugeSizeUnit.logicalPixel,
                          length: size * 0.1))
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    angle: 90,
                    positionFactor: 0.8,
                    widget: Text(
                        '${NumberFormat.compact(locale: 'de').format(displayValue)} ${unit}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size * 0.07)),
                  ),
                ],
                axisLabelStyle: GaugeTextStyle(
                    fontSize: size * 0.05, fontWeight: FontWeight.w500),
                axisLineStyle: AxisLineStyle(
                    thickness: size * 0.01, color: Colors.blueGrey)),
          ],
        ),
      ),
    ];
    if (!leftSide) children = children.reversed.toList();
    return Padding(
      padding: EdgeInsets.only(bottom: size * 0.05),
      child: Row(
        children: children,
      ),
    );
  }
}
