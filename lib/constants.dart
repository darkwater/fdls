import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const double fdlsBarHeight = 64;
const double fdlsSmallComponentWidth = 90;
const double fdlsMediumComponentWidth = 150;
const Color fdlsBackgroundColor = Color.fromRGBO(0x21, 0x27, 0x33, 0.8);

const Size fdlsPopupSize = Size(240, 140);
const Size fdlsPopupFullSize = Size(480, 300);

const Duration fdlsUpdateFrequency =
    kDebugMode ? Duration(seconds: 1) : Duration(seconds: 10);
const Duration fdlsGraphPer100Px =
    kDebugMode ? Duration(minutes: 1) : Duration(minutes: 5);

final Duration fdlsDefaultKeepHistory =
    fdlsGraphPer100Px * (fdlsPopupFullSize.width ~/ 100);
