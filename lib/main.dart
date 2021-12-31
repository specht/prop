import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:intl/intl.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

Offset oldPanPoint = Offset.zero;
double oldValue = 0.0;
int lastMax = 0;

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
  double x = 0;
  double y = 0;
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
  void initState() {
    super.initState();
    factor = 1.5;
    x = 3.0;
    y = factor * x;
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width * 0.38;
    if (size > MediaQuery.of(context).size.height * 0.7)
      size = MediaQuery.of(context).size.height * 0.7;
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: size * 2.475,
          height: size * 1.44,
          child: Stack(
            children: [
              Column(
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
                            Text(formatValue(factor),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: size * 0.07)),
                            if (leftUnit != rightUnit)
                              Text(" ${rightUnit} / ${leftUnit}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: size * 0.07)),
                            SizedBox(width: size * 0.05, height: 1),
                            Ink(
                                decoration: ShapeDecoration(
                                  color: factorLocked
                                      ? Colors.black12
                                      : Colors.green,
                                  shape: CircleBorder(),
                                ),
                                child: IconButton(
                                    iconSize: size * 0.07,
                                    onPressed: () {
                                      setState(() {
                                        factorLocked = !factorLocked;
                                      });
                                    },
                                    icon: Icon(
                                      factorLocked
                                          ? Icons.lock
                                          : Icons.lock_open,
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
                              if (x < 0.0) x = 0.0;
                              if (x > 10000.0) x = 10000.0;
                              x = quantizeValue(x);
                              if (factorLocked)
                                y = x * factor;
                              else {
                                if (x < 0.01) x = 0.01;
                                x = quantizeValue(x);
                                y = quantizeValue(y);
                                factor = y / x;
                                if (factor < 0.0001) {
                                  x = quantizeValue(y) / 0.0001;
                                  if (x < 0.01) x = 0.01;
                                  if (x > 10000.0) x = 10000.0;
                                  factor = 0.0001;
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
                                  initialIndex: availableUnits
                                      .indexOf(leftUnit)
                                      .toDouble(),
                                  dynamicItemSize: false,
                                  onItemFocus: (index) {
                                    setState(() {
                                      leftUnit = availableUnits[index];
                                    });
                                  },
                                  itemSize: size * 0.19,
                                  itemBuilder: (context, index) {
                                    bool selected =
                                        leftUnit == availableUnits[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: selected
                                              ? Colors.black12
                                              : Colors.white10,
                                          borderRadius: BorderRadius.circular(
                                              size * 0.03)),
                                      width: size * 0.19,
                                      alignment: Alignment.center,
                                      child: Text(availableUnits[index],
                                          style: TextStyle(
                                              color: selected
                                                  ? Colors.black87
                                                  : Colors.black54,
                                              fontSize: size *
                                                  (selected ? 0.06 : 0.06),
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
                              if (y < 0.0) y = 0.0;
                              if (y > 10000.0) y = 10000.0;
                              y = quantizeValue(y);
                              if (factorLocked)
                                x = y / factor;
                              else {
                                if (x < 0.01) x = 0.01;
                                x = quantizeValue(x);
                                y = quantizeValue(y);
                                factor = y / x;
                                if (factor < 0.0001) {
                                  y = quantizeValue(x) * 0.0001;
                                  if (y < 0.01) y = 0.01;
                                  if (y > 10000.0) y = 10000.0;
                                  factor = 0.0001;
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
                                  initialIndex: availableUnits
                                      .indexOf(rightUnit)
                                      .toDouble(),
                                  dynamicItemSize: false,
                                  onItemFocus: (index) {
                                    setState(() {
                                      rightUnit = availableUnits[index];
                                    });
                                  },
                                  itemSize: size * 0.19,
                                  itemBuilder: (context, index) {
                                    bool selected =
                                        rightUnit == availableUnits[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: selected
                                              ? Colors.black12
                                              : Colors.white10,
                                          borderRadius: BorderRadius.circular(
                                              size * 0.03)),
                                      width: size * 0.19,
                                      alignment: Alignment.center,
                                      child: Text(availableUnits[index],
                                          style: TextStyle(
                                              color: selected
                                                  ? Colors.black87
                                                  : Colors.black54,
                                              fontSize: size *
                                                  (selected ? 0.06 : 0.06),
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
                ],
              ),
              Positioned(
                  left: 0,
                  right: 0,
                  top: size * 0.99,
                  child: Center(
                      child: Icon(Icons.arrow_right_alt, size: size * 0.15))),
            ],
          ),
        ),
      ),
    );
  }

  double quantizeValue(double value) {
    const List<double> places = [100, 100, 10, 1, 0.1];
    int exp = 0;
    int max = 1;
    while (value > max) {
      exp += 1;
      max *= 10;
    }
    double p = 1;
    if (exp < places.length) p = places[exp];

    double result = (value * p).round().toDouble() / p;
    // developer.log('quantizeValue: $value $exp $max $result');
    return result;
  }

  String formatValue(double value) {
    String s = value.toStringAsFixed(4).replaceAll('.', ',');
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r',$'), '');
    return s;
  }

  double nextValue(double value) {
    double result = value;
    if (result < 10.0)
      result = quantizeValue(value) + 0.01;
    else if (result < 100.0)
      result = quantizeValue(value) + 0.1;
    else if (result < 1000.0)
      result = quantizeValue(value) + 1.0;
    else
      result = quantizeValue(value) + 10.0;
    return result;
  }

  double prevValue(double value) {
    double result = value;
    if (result > 1000.0)
      result = quantizeValue(value) - 10.0;
    else if (result > 100.0)
      result = quantizeValue(value) - 1.0;
    else if (result > 10.0)
      result = quantizeValue(value) - 0.1;
    else
      result = quantizeValue(value) - 0.01;
    return result;
  }

  Widget controlledGauge(double size, double value, String unit, bool leftSide,
      ValueSetter<double> onChange) {
    int exp = 0;
    int max = 1;
    while (value > max) {
      exp += 1;
      max *= 10;
    }
    // double displayValue = getDisplayValue(value);
    String prettyValue = formatValue(value);
    List<Widget> children = [
      GestureDetector(
        onVerticalDragStart: (details) {
          oldPanPoint = details.localPosition;
          oldValue = value;
          lastMax = max;
        },
        onVerticalDragUpdate: (details) {
          if (max != lastMax) {
            oldPanPoint = details.localPosition;
            oldValue = value;
            lastMax = max;
          }
          Offset delta = details.localPosition - oldPanPoint;
          double sign = delta.dy > 0 ? -1 : 1;
          double magnitude = delta.dy.abs() * 500.0 / size;
          // magnitude = math.pow(magnitude, 2.0).toDouble() * 0.00001;
          // magnitude *= 0.0001;
          magnitude /= 10;
          double dy = magnitude * sign * max;
          int steps = magnitude.toInt();
          double newValue = oldValue;
          for (int i = 0; i < steps; i++) {
            newValue = sign == 1 ? nextValue(newValue) : prevValue(newValue);
          }
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
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: size * 0.04),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      child: Icon(
                        FeatherIcons.chevronUp,
                        size: size * 0.1,
                        color: Colors.black38,
                      ),
                      onTap: () {
                        onChange(nextValue(value));
                      },
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                        child: Icon(
                          FeatherIcons.chevronDown,
                          size: size * 0.1,
                          color: Colors.black38,
                        ),
                        onTap: () {
                          onChange(prevValue(value));
                        }),
                  ),
                ]),
          ),
        ),
      ),
      SizedBox(
        width: size,
        height: size,
        child: LayoutBuilder(builder: (context, constraints) {
          return GestureDetector(
            onPanUpdate: (details) {
              if (lastMax != max) {
                oldPanPoint = details.localPosition;
                oldValue = value;
                lastMax = max;
              }
              Offset centerOfGestureDetector =
                  Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
              double oldAngle =
                  (oldPanPoint - centerOfGestureDetector).direction;
              double newAngle =
                  (details.localPosition - centerOfGestureDetector).direction;
              double delta = newAngle - oldAngle;
              if (delta.abs() > math.pi) {
                oldPanPoint = details.localPosition;
                oldValue = value;
                lastMax = max;
              }
              while (delta < -math.pi) delta += math.pi * 2;
              while (delta > math.pi) delta -= math.pi * 2;
              double sign = delta > 0 ? 1 : -1;
              double magnitude = delta.abs() * 0.212;
              double dy = magnitude * sign * max;
              double newValue = quantizeValue(oldValue + dy);
              // if (newValue > max) newValue = max.toDouble();
              onChange(newValue);
              // oldPanPoint = details.localPosition;
            },
            onPanStart: (details) {
              oldPanPoint = details.localPosition;
              oldValue = value;
              lastMax = max;
            },
            child: SfRadialGauge(
              enableLoadingAnimation: true,
              axes: <RadialAxis>[
                RadialAxis(
                    minimum: 0,
                    maximum: max.toDouble(),
                    startAngle: 135,
                    endAngle: 405,
                    // canScaleToFit: true,
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
                          value: value,
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
                        widget: Text('${formatValue(value)} ${unit}',
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
          );
        }),
      ),
    ];
    if (!leftSide) children = children.reversed.toList();
    return Row(
      children: children,
    );
  }
}
