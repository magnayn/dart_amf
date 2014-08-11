part of amf;

class AMF3Deserializer extends DataInputStream implements ObjectInput {

  List<Object> _storedObjects = new List<Object>();
  List _stringTable = new List();
  List _traitsTable = new List();

  AMF3Deserializer(dataList) : super(dataList) {
  }


  Object readObject() {
    return _readObject(_readAMF3Integer());
  }

  Object _readObject(int type) {
    switch (type) {
      case AMF3Type.Undefined :case AMF3Type.Null :
        return null;

      case AMF3Type.False :
        return false;
      case AMF3Type.True :
        return true;
      case AMF3Type.Integer :
        return _readAMF3Integer();
      case AMF3Type.Double :
        return _readAMF3Double();
      case AMF3Type.String :
        return _readAMF3String();
      case AMF3Type.XMLDoc :
        return _readAMF3XML();
      case AMF3Type.Date :
        return _readAMF3Date();
      case AMF3Type.Array :
        return _readAMF3Array();
      case AMF3Type.Object :
        return _readAMF3Object();
      case AMF3Type.XML :
        return _readAMF3XmlString();
      case AMF3Type.ByteArray :
        return _readAMF3ByteArray();
      case AMF3Type.VectorInt :
        return _readAMF3VectorInt();
      case AMF3Type.VectorUint :
        return _readAMF3VectorUint();
      case AMF3Type.VectorNumber :
        return _readAMF3VectorNumber();
      case AMF3Type.VectorObject :
        return _readAMF3VectorObject();
      case AMF3Type.Dictionary :
        return _readAMF3Dictionary();
      default:
        throw new Error();
    }
  }

  // TODO

  DateTime _readAMF3Date() {
    throw new UnimplementedError();
  }

  List _readAMF3ByteArray() {
    throw new UnimplementedError();
  }

  Object _readAMF3VectorInt() {
    throw new UnimplementedError();
  }

  Object _readAMF3VectorUint() {
    throw new UnimplementedError();
  }

  Object _readAMF3VectorNumber() {
    throw new UnimplementedError();
  }

  Object _readAMF3VectorObject() {
    throw new UnimplementedError();
  }

  Map _readAMF3Dictionary() {
    throw new UnimplementedError();
  }


  int _readAMF3Integer() {
    int value;
    int ch = read() & 0xFF;

    if (ch < 128) {
      return ch;
    }

    value = (ch & 0x7F) << 7;
    ch = read() & 0xFF;
    if (ch < 128) {
      return value | ch;
    }

    value = (value | (ch & 0x7F)) << 7;
    ch = read() & 0xFF;
    if (ch < 128) {
      return value | ch;
    }

    value = (value | (ch & 0x7F)) << 8;
    ch = read() & 0xFF;
    return value | ch;
  }

  Object _readAMF3Array() {
    int ref = _readAMF3Integer();
    if ((ref & 1) == 0) {
      ref = (ref >> 1);
      return _storedObjects[ref];
    }
    int length = (ref >> 1);
    Object array;
    for (; ;) {
      String name = _readAMF3String();
      if (name == null || name.length == 0) break;
      if (array == null) {
        array = new Map();
        _storedObjects.add(array);
      }
      (array as Map)[name] = readObject();
    }

    if (array == null) {
      array = [];
      _storedObjects.add(array);
      for (int i = 0; i < length; i++) {
        (array as List).add(readObject());
      }
    } else {
      for (int i = 0; i < length; i++) {
        (array as List)[i] = readObject();
      }
    }
    return array;
  }

  XmlDocument _readAMF3XmlString() {
    String xmlString = _readAMF3String();

    return parse(xmlString);
  }


  Object _readAMF3Object() {
    Object result = null;
    int type = _readAMF3Integer();
    if ((type & 0x01) == 0) {
      return _storedObjects[type >> 1];
    }

    AMF3TraitsInfoAS traitsInfo = _decodeTraits(type);


    // Create correct class

    if (traitsInfo.dynamic) {
      result = new Map();
      _storedObjects.add(result);

      String key = _readAMF3String();
      while (key != null && key.length > 0) {
        (result as Map)[key] = readObject();
        key = _readAMF3String();
      }
      return result;
    }

    try {
      result = AMF.createClassByName(traitsInfo.name);
    }
    on ArgumentError catch(ex) {
      print("Couldn't build by name ${traitsInfo.name}; ${ex.message}");
      result = new ASObject();
    }
    _storedObjects.add(result);

    if (result is Externalizable) {
      print("via Externalizable");
      (result as Externalizable).readExternal(this);
    } else {
      print("not Externalizable");
      InstanceMirror instanceMirror = reflect(result);
      for (String key in traitsInfo.properties) {
        print("${key}");

        instanceMirror.setField(new Symbol(key), readObject());
      }
    }


    return result;


//      
//      if (traitsInfo.name != null && traitsInfo._className.length > 0) {
//        object = new ASObject();
//        object._type = traitsInfo._className;
//        object._isExternalizable = traitsInfo._externalizable;
//      } else {
//        object = new Map();
//      }
//
//      _objectTable.add(object);
//
//
//          String key;
//          for (key in traitsInfo._properties) {
//            object[key] = decodeObject();
//          }
//
//          if (traitsInfo._dynamic) {
//            key = decodeUTF();
//            while (key != null && key.length > 0) {
//              object[key] = decodeObject();
//              key = decodeUTF();
//            }
//          }
//
//          if (!(object is ASObject)) {
//            return object;
//          }
//
//          Object desObject = _deserializeObject(object);
//          if (desObject == object) {
//            return object;
//          }
//          
//    }
//    
//    Object _deserializeObject(ASObject object) {
//        if (object._type == null) return object;
//        String classname = object._type;
//
//        // Options around FlexArraycollection
//
//        ClassMirror cm = AMF.findClassMirror(classname);
//        if (cm == null) {
//          if (object._isExternalizable) throw new ArgumentError(
//              "No class mirror for ${classname} but it should be externalizable"); else return
//              object; // Just use the AS representation.
//        }
//
//        ASObject lastDeserializedObject = _currentDeserializedObject;
//        _currentDeserializedObject = object;
//
//        Object desObject = AMF.createClassByName(classname);
//
//        _objectTable[_objectTable.indexOf(object)] = desObject;
//
//        if (desObject is Externalizable) desObject.readObject(this); else {
//          // Party like it's 1599
//          print("FISH");
//          InstanceMirror instanceMirror = reflect(desObject);
//          for (String key in object._properties.keys) {
//            print("${key}");
//
//            instanceMirror.setField(new Symbol(key), object._properties[key]);
//          }
//        }
//        _currentDeserializedObject = lastDeserializedObject;
//        return desObject;
  }

  AMF3TraitsInfoAS _decodeTraits(int infoBits) {
    if ((infoBits & 3) == 1) {
      infoBits = (infoBits >> 2);
      return _traitsTable[infoBits];
    }
    bool externalizable = (infoBits & 4) == 4;
    bool dynamic = (infoBits & 8) == 8;
    int count = infoBits >> 4;
    String className = _readAMF3String();

    AMF3TraitsInfoAS info = new AMF3TraitsInfoAS();
    info._className = className;
    info._dynamic = dynamic;
    info._externalizable = externalizable;

    for (int i = 0;i < count;i++) {
      info.addProperty(_readAMF3String());
    }

    _traitsTable.add(info);

    return info;
  }

  double _readAMF3Double() {
    return readDouble();
  }

  String _readAMF3String() {
    int ref = _readAMF3Integer();
    if ((ref & 1) == 0) {
      ref = (ref >> 1);
      return _stringTable[ref];
    }
    int length = ref >> 1;
    if (length == 0) {
      return "";
    }
    //Narp. Already read length. String value = readUTF();

    String value = "";

    for (int i = 0; i < length; i++) {
      int char = readByte();
      value += new String.fromCharCode(char);
    }


    _stringTable.add(value);
    return value;
  }

  XmlDocument _readAMF3XML() {
    return parse(_readAMF3String());
  }


}