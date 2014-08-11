part of amf;

class AMFVersion {

  static const AMF0 = 0x00;

  static const AMF3 = 0x03;
}


class AMF0Type {
  static const int Number = 0x0;

  static const int Boolean = 0x1;

  static const int String = 0x2;

  static const int Object = 0x3;

  static const int MovieClip = 0x4;

  static const int Null = 0x5;

  static const int Undefined = 0x6;

  static const int Reference = 0x7;

  static const int ECMAArray = 0x8;

  static const int ObjectEnd = 0x9;

  static const int StrictArray = 0xA;

  static const int Date = 0xB;

  static const int LongString = 0xC;

  static const int Unsupported = 0xD;

  static const int Recordset = 0xE;

  static const int XMLObject = 0xF;

  static const int TypedObject = 0x10;

  static const int AVMPlusObject = 0x11;


}
//

class AMF3Type {
  static const int Undefined = 0x0;

  static const int Null = 0x1;

  static const int False = 0x2;

  static const int True = 0x3;

  static const int Integer = 0x4;

  static const int Double = 0x5;

  static const int String = 0x6;

  static const int XMLDoc = 0x7;

  static const int Date = 0x8;

  static const int Array = 0x9;

  static const int Object = 0xA;

  static const int XML = 0xB;

  static const int ByteArray = 0xC;

  static const int VectorInt = 0x0D;

  static const int VectorUint = 0x0E;

  static const int VectorNumber = 0x0F;

  static const int VectorObject = 0x10;

  static const int Dictionary = 0x11;
}
//
//enum
//{

class AMFConsts {
  static const int AMFUnarchiverUnpackArrayCollection = 0x1;

  static const int AMFUnarchiverUnpackObjectProxyOption = 0x2;

  //};

  //

  //enum

  //{

  static const int AMFArchiverPackArrayOption = 0x1;
// converts an array to an ArrayCollection
//};
//
}

class AMFErrorCode {
  static const int InvalidRequest = 1;

  static const int ServiceNotFound = 2;

  static const int MethodNotFound = 3;

  static const int ArgumentMismatch = 4;

  static const int InvalidArguments = 5;
}

abstract class AMF3TraitsInfo {

  // Dynamic -- don't know properties till runtime (Map style)
  bool _dynamic = false;

  // IExternalizable
  bool _externalizable = false;

  String get name;
}

class AMF3TraitsInfoAS extends AMF3TraitsInfo {

  String _className;
  List<String> _properties = new List();

  String get name => _className;

  bool get dynamic => _dynamic;

  List<String> get properties => _properties;

  void addProperty(String name) {
    _properties.add(name);
  }

}

class AMF3TraitsInfoDart extends AMF3TraitsInfo {
  Type _type;

  List<Symbol> _properties = new List();

  int get propertyCount => _properties.length;

  String get name {

    for (InstanceMirror md in reflectClass(_type).metadata) {

      if (md.reflectee.runtimeType == RemoteClass) {
        RemoteClass rc = md.reflectee;
        return rc.name;
      }

    }

    return _type.toString();
  }

  AMF3TraitsInfoDart(Object o) {
    _type = o.runtimeType;
    _externalizable = o is Externalizable;

    if (!_externalizable) {
      InstanceMirror instanceMirror = reflect(o);
      ClassMirror classMirror = instanceMirror.type;
      _getFields(classMirror);
    }

  }

  void _getFields(ClassMirror classMirror) {
    classMirror.declarations.forEach((name, declaration) {

      if (declaration is VariableMirror) {
        VariableMirror vm = declaration;
        // var strname = MirrorSystem.getName(name);

        _properties.add(name);


      } else if (declaration is MethodMirror) {
        MethodMirror mm = declaration;
        if (mm.isGetter) {


        }
      }

    });

    if (classMirror.superclass != null && classMirror.superclass.reflectedType != Object)_getFields(classMirror.superclass);
  }

  void addProperty(Symbol prop) {
    _properties.add(prop);
  }
}

class ASObject {
  String _type;
  bool _isExternalizable = false;
  Map _properties = new Map();
  List _data = null;

  void addObject(obj) {
    if (_data == null) _data = [];

    _data.add(obj);
  }

  void setValue(String key, value) {
    _properties[key] = value;
  }

  int get count {
    if (_isExternalizable) return _data.length;
    return _properties.length;
  }

  void operator []=(key, value) {
    _properties[key] = value;
  }

  Object operator [](key) {
    return _properties[key];
  }

  noSuchMethod(Invocation invocation) {
    // TODO: is this *really* the only way?
    String name = invocation.memberName.toString();
    name = name.substring(8, name.length - 2);

    return _properties[name];
  }
}
