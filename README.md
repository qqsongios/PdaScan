#PAD Scan Plugin

A Flutter plugin to access scan function on urovo i6s200 device

#Usage

 To use this plugin, add pda_scan as a dependency in your pubspec.yaml file.

#Example

```
import 'package:pda_scan/pda_scan.dart';

//Instantiate it
var _pdaScan = PdaScan();

_pdaScan.onScanResult.listen((String code){
        // DO something with result code
});
```