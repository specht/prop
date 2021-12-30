import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  double factor = 2.0;
  double x = 1.5;
  double y = 1.5 * 2.0;
  String leftUnit = 'kg';
  String rightUnit = '€';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            controlledGauge(x, leftUnit, true, (v) {
              setState(() {
                x = v;
                if (x < 0.01) x = 0.01;
                if (x > 10000.0) x = 10000.0;
                y = getDisplayValue(x) * factor;
              });
            }),
            controlledGauge(y, rightUnit, false, (v) {
              setState(() {
                y = v;
                if (y < 0.01) y = 0.01;
                if (y > 10000.0) y = 10000.0;
                x = getDisplayValue(y) / factor;
              });
            }),
          ],
        ),
      ),
    );
  }

  double getDisplayValue(value) {
    int exp = 0;
    int max = 1;
    while (value > max) {
      exp += 1;
      max *= 10;
    }
    return (value / max * 1000).floor().toDouble() * max / 1000.0;
  }

  Widget controlledGauge(
      double value, String unit, bool leftSide, ValueSetter<double> onChange) {
    int exp = 0;
    int max = 1;
    while (value > max) {
      exp += 1;
      max *= 10;
    }
    double displayValue = getDisplayValue(value);
    String prettyValue = displayValue.toString().replaceAll('.', ',');
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
          width: 100,
          height: 500,
          decoration: BoxDecoration(color: Colors.black12),
        ),
      ),
      SizedBox(
        width: 600,
        height: 600,
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
                minorTickStyle: const MinorTickStyle(
                    length: 0.03,
                    lengthUnit: GaugeSizeUnit.factor,
                    thickness: 1.5),
                majorTickStyle: const MajorTickStyle(
                    length: 0.06,
                    lengthUnit: GaugeSizeUnit.factor,
                    color: Colors.black45,
                    thickness: 1.5),
                minorTicksPerInterval: 10,
                pointers: <GaugePointer>[
                  NeedlePointer(
                      value: displayValue,
                      needleStartWidth: 1,
                      needleEndWidth: 3,
                      needleLength: 0.7,
                      lengthUnit: GaugeSizeUnit.factor,
                      knobStyle: KnobStyle(
                        knobRadius: 0.03,
                        sizeUnit: GaugeSizeUnit.factor,
                      ),
                      tailStyle: TailStyle(
                          width: 3,
                          lengthUnit: GaugeSizeUnit.logicalPixel,
                          length: 20))
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                      angle: 90,
                      positionFactor: 0.5,
                      widget: Text('${prettyValue} ${unit}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24))),
                ],
                axisLabelStyle: const GaugeTextStyle(
                    fontSize: 20, fontWeight: FontWeight.w500),
                axisLineStyle: const AxisLineStyle(
                    thickness: 3, color: Color(0xFF00A8B5))),
          ],
        ),
      ),
    ];
    if (!leftSide) children = children.reversed.toList();
    return Row(
      children: children,
    );
  }
}
