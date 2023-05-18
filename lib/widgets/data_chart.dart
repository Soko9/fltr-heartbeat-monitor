import 'package:flutter/material.dart';
import 'package:heart_beat_monitor/models/sensor_data.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:heart_beat_monitor/utils/constants.dart';

class DataChart extends StatelessWidget {
  const DataChart({
    super.key,
    required this.data,
    required this.scheme,
  });

  final List<SensorData> data;
  final String scheme;

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      [
        charts.Series<SensorData, DateTime>(
          id: 'Value',
          colorFn: (SensorData datum, index) {
            switch (scheme) {
              case kSchemeKeyRed:
                return charts.MaterialPalette.red.shadeDefault;
              case kSchemeKeyBlue:
                return charts.MaterialPalette.blue.shadeDefault;
              case kSchemeKeyYellow:
                return charts.MaterialPalette.deepOrange.shadeDefault;
              case kSchemeKeyGreen:
                return charts.MaterialPalette.green.shadeDefault;
              default:
                return charts.MaterialPalette.red.shadeDefault;
            }
          },
          domainFn: (SensorData datum, index) => datum.time,
          measureFn: (SensorData datum, index) => datum.value,
          data: data,
        ),
      ],
      animate: false,
      primaryMeasureAxis: const charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(zeroBound: false),
        renderSpec: charts.NoneRenderSpec(),
      ),
      domainAxis: const charts.DateTimeAxisSpec(
        renderSpec: charts.NoneRenderSpec(),
      ),
    );
  }
}
