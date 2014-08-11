part of amf;

class AMF3Serializer {
  final DataOutput _stream;

  List<Object> _storedObjects = new List<Object>();
  List _stringTable = [];
  List _traitsTable = [];


  DataOutput get stream => _stream;

  AMF3Serializer(this._stream) {
  }

  void writeObject(Object o) {

    if (o == null) {
      _stream.write(AMF3Type.Null);
      //            else if (o is AMFSpecialValue)
    }
    //              writeAMF3SpecialValue((AMFSpecialValue<?>)o); else if (!(o is Externalizable)) {

    //                if (converters.hasReverters())
    //                    o = converters.revert(o);

    if (o == null) {
      _stream.write(AMF3Type.Null);
    } else if (o is String) //|| o is Character) {
      _writeAMF3String(o);
  }

  else

  if

  (

  o

  is

  bool

  )

  {
  _stream.write(o ? AMF3Type.True : AMF3Type.False);
  }

  else

  if

  (

  o

  is

  int

  )

  {
  _writeAMF3Integer(o);
  }

  else

  if

  (

  o

  is

  double

  )

  {
  _writeAMF3Number(o);
  }

  else

  if

  (

  o

  is

  DateTime

  )

  {
  _writeAMF3Date(o);
  }

  else

  if

  (

  o

  is

  Iterable

  )

  {
  _writeAMF3Collection(o);
  }

  else

  if

  (

  o

  is

  XmlDocument

  )

  {
  _writeXMLDocument(o);
  }

  //          else if (o.getClass().isArray()) {
  //              if (o.getClass().getComponentType() == Byte.TYPE)
  //                  writeAMF3ByteArray((byte[])o);
  //              else
  //                  writeAMF3Array(o);
  //          } else // Externalizable

  _writeAMF3Object(o);
}
else
{
_writeAMF3Object(o);
}

}

void _writeAMF3Collection(Iterable o) {
  _stream.write(AMF3Type.Array);
  if (_storedObjects.contains(o)) {
    _writeAMF3IntegerData(_storedObjects.indexOf(o) << 1);
  } else {
    _storedObjects.add(o);

    _writeAMF3IntegerData((o.length << 1) | 1);
    _stream.write((0 << 1) | 1);
    o.forEach((e) {
      writeObject(e);
    });
  }
}

void _writeXMLDocument(XmlDocument doc) {

  _stream.write(AMF3Type.XML);
  _writeAMF3StringData(doc.toXmlString());
}

void _writeAMF3Number(double d) {
  _stream.write(AMF3Type.Double);
  _stream.writeDouble(d);
}

void _writeAMF3Integer(int i) {
  _stream.write(AMF3Type.Integer);
  _writeAMF3IntegerData(i);
}

_writeAMF3Date(DateTime dt) {
  _stream.write(AMF3Type.Date);
  if (_storedObjects.contains(dt)) {
    _writeAMF3IntegerData(_storedObjects.indexOf(dt) << 1);
  } else {
    _storedObjects.add(dt);
    _writeAMF3IntegerData(1);
    _stream.writeDouble(dt.millisecondsSinceEpoch.toDouble());
  }

}

void _writeAMF3IntegerData(int i) {
  if (i < 0 || i >= 0x200000) {
    _stream.write(((i >> 22) & 0x7F) | 0x80);
    _stream.write(((i >> 15) & 0x7F) | 0x80);
    _stream.write(((i >> 8) & 0x7F) | 0x80);
    _stream.write(i & 0xFF);
  } else {
    if (i >= 0x4000) _stream.write(((i >> 14) & 0x7F) | 0x80);
    if (i >= 0x80) _stream.write(((i >> 7) & 0x7F) | 0x80);
    _stream.write(i & 0x7F);
  }
}

void _writeAMF3Object(Object o) {
  _stream.write(AMF3Type.Object);

  if (_storedObjects.contains(o)) {
    _writeAMF3IntegerData(_storedObjects.indexOf(o) << 1);
  } else {
    _storedObjects.add(o);


    AMF3TraitsInfoDart traits = new AMF3TraitsInfoDart(o);

    // Send the traits
    _writeAMF3Traits(traits);

    if (o is Externalizable) {
      o.writeExternal(_stream);
    } else {
      InstanceMirror instanceMirror = reflect(o);
      traits._properties.forEach((k) {
        if (traits._dynamic) {
          // ?
          _writeAMF3String(k.toString());
        }

        var data = instanceMirror.getField(k).reflectee;

        // TODO :More guff here
        writeObject(data);
      });
    }

  }
}


void _writeAMF3Traits(AMF3TraitsInfoDart traits) {
  if (_traitsTable.contains(traits)) {
    _writeAMF3IntegerData((_traitsTable.indexOf(traits) << 2) | 1);
    return;
  }
  _traitsTable.add(traits);
  var infoBits = 3;
  if (traits._externalizable) infoBits |= 4;
  if (traits._dynamic) infoBits |= 8;
  infoBits |= (traits.propertyCount << 4);
  _writeAMF3IntegerData(infoBits);

  // The type name
  _writeAMF3StringData(traits.name);

  for (Symbol s in traits._properties) {
    //String s = traits._properties[i];
    _writeAMF3StringData(MirrorSystem.getName(s));
  }
}


void _writeAMF3String(String s) {
  _stream.write(AMF3Type.String);
  _writeAMF3StringData(s);
}

void _writeAMF3StringData(String value) {
  if (value.length == 0) {
    _stream.write(0x01);
    return;
  }

  if (_stringTable.contains(value)) {
    _writeAMF3IntegerData(_stringTable.indexOf(value) << 1);
    return;
  }
  _stringTable.add(value);


  List codeUnits = value.codeUnits;

  _writeAMF3IntegerData(((codeUnits.length) << 1) | 1);

  //encodeDataObject(codeUnits);
  _stream.writeBytes(codeUnits);

}

//  void _writeAMF3IntegerData(uint32value) {
//
//    if (uint32value < 0x80) {
//      _stream.writeByte(uint32value);
//    } else if (uint32value < 0x4000) {
//      _stream.writeByte(((uint32value >> 7) & 0x7F) | 0x80);
//      _stream.writeByte((uint32value & 0x7F));
//    } else if (uint32value < 0x200000) {
//      _stream.writeByte(((uint32value >> 14) & 0x7F) | 0x80);
//      _stream.writeByte(((uint32value >> 7) & 0x7F) | 0x80);
//      _stream.writeByte((uint32value & 0x7F));
//    } else {
//      _stream.writeByte(((uint32value >> 22) & 0x7F) | 0x80);
//      _stream.writeByte(((uint32value >> 15) & 0x7F) | 0x80);
//      _stream.writeByte(((uint32value >> 8) & 0x7F) | 0x80);
//      _stream.writeByte((uint32value & 0x7F));
//    }
//  }

}
