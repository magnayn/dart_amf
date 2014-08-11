library amf;

import 'dart:typed_data';
import 'dart:async';
import 'dart:mirrors';
import 'dart:collection';
import 'dart:html';

import 'package:xml/xml.dart';

part 'core/amf.dart';
part 'core/annotation.dart';
part 'core/types.dart';
part 'core/externalizable.dart';
part 'core/remoting.dart';
part 'core/flex_data_types.dart';

part 'core/messaging/messaging.dart';


part 'core/serializer/amf0_deserializer.dart';
part 'core/serializer/amf3_deserializer.dart';
part 'core/serializer/amf0_serializer.dart';
part 'core/serializer/amf3_serializer.dart';

part 'core/serializer/deserializer.dart';
part 'core/serializer/serializer.dart';
