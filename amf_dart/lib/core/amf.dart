part of amf;

class AMF {

  static Map _typeMap = new Map();
  static Map _functionMap = new Map();

  static Map<Type, String> _nameMap = new Map();

  static void init() {
//    registerAnnotatedClass(FlexAcknowledgeMessage);
//    registerAnnotatedClass(FlexArrayCollection);
//    registerAnnotatedClass(FlexRemotingMessage);
  }

  static void trace(Uint8List list) {
    String str = "";
    String txt = "";
    int c = 0;
    list.forEach((x) {
      String hex = x.toRadixString(16);
      if (hex.length == 1) hex = "0" + hex;
      str += "${hex} ";
      if (x < 32 || x > 127)txt += "."; elsetxt += new String.fromCharCode(x);

      c++;
      if (c % 16 == 0) {
        str += "  ${txt}\n";
        txt = "";
      } else if (c % 8 == 0) {
        str += "  ";
        txt += " ";
      }

    });

    //c++;
    while (c % 16 != 0) {
      str += "   ";
      txt += " ";
      c++;
      if (c % 16 != 0 && c % 8 == 0) {
        str += "  ";
        txt += " ";
      }
    }
    str += "  ${txt}\n";

    print("${str}");
  }

  static void traceRecv(Uint8List list) {
    print("Received ${list.length} bytes");
    trace(list);
  }

  static void traceSend(Uint8List list) {
    print("Sending ${list.length} bytes");
    trace(list);

  }

  static void findAnnotatedClasses() {
    MirrorSystem mirrorSystem = currentMirrorSystem();
    mirrorSystem.libraries.forEach((lk, l) {
      l.declarations.forEach((dk, d) {
        if (d is ClassMirror) {
          ClassMirror cm = d as ClassMirror;
          cm.metadata.forEach((md) {
            InstanceMirror metadata = md as InstanceMirror;
            if (metadata.type == reflectClass(RemoteClass)) {
              print('found: ${cm.simpleName}');
              registerAnnotatedClass(cm.reflectedType);
            }
          });
        }
      });
    });
  }

  static void registerAnnotatedClass(Type t, [Function f]) {
    print("Register type ${t}");
    AnnotationInfo ai = new AnnotationInfo(reflectClass(t));
    RemoteClass rc = ai.remoteClass;
    if (rc == null)return;

    String name = rc.name;
    print("Registering classmirror for ${name} = ${ai.classMirror}");
    if (_typeMap.containsKey(name)) {
      throw new StateError("Type map already has an entry for ${name} pointing to ${_typeMap[name]}");
    }

    _typeMap[rc.name] = ai.classMirror;
    _nameMap[t] = rc.name;
    if (f != null)_functionMap[rc.name] = f;

  }

  static ClassMirror findClassMirror(String name) {
    if (_typeMap.containsKey(name)) return _typeMap[name];

    print("Having to look for classmirror");

    for (var lib in currentMirrorSystem().libraries.values) {
      var mirror = lib.declarations[MirrorSystem.getSymbol(name)];
      if (mirror != null) return mirror;
    }
    //throw new ArgumentError("Class $name does not exist");
    return null;
  }

  static Object createClassByName(String classname) {
    print("CreateclassByName ${classname}");
    if (_functionMap[classname] != null) return _functionMap[classname]();
    ClassMirror classMirror = findClassMirror(classname);
    if (classMirror == null) throw new ArgumentError("Class $classname does not exist");
    print("building from ${classMirror}");

    // We have to get the right number of constructor parameters,
    // otherwise the JS version won't fly.
    // This works on Dart, but not JS if the constructor has optional
    // parameters:
    //   return classMirror.newInstance(const Symbol(''), []).reflectee;
    List<DeclarationMirror> constructors = new List.from(classMirror.declarations.values.where((declare) {
      return declare is MethodMirror && declare.isConstructor;
    }));

    int len = 0;

    constructors.forEach((constructor) {
      if (constructor is MethodMirror) {
        List<ParameterMirror> parameters = constructor.parameters;
        len = parameters.length;
      }
    });

    return classMirror.newInstance(const Symbol(''), new List(len)).reflectee;

  }

  static String classNameForClass(type) {
    String name = _nameMap[type];
    if (name == null) {
      throw new StateError("No such class for ${type}");
    }
    return name;
  }
}

class AnnotationInfo {

  ClassMirror classMirror;

  AnnotationInfo(this.classMirror) {
  }

  RemoteClass get remoteClass {
    Set<RemoteClass> rcs = _getRC();

    if (classMirror.superclass != null) {
      Set<RemoteClass> par = new AnnotationInfo(classMirror.superclass)._getRC();
      rcs.removeAll(par);
    }
    if (rcs.length == 0)return null;
    if (rcs.length > 1)throw new StateError("Multiple RemoteClass annotations");
    return rcs.first;
  }

  Set<RemoteClass> _getRC() {
    Set<RemoteClass> items = new HashSet();

    for (InstanceMirror metadata in classMirror.metadata) {
      if (metadata.reflectee is RemoteClass) {
        items.add(metadata.reflectee);
      }
    }
    return items;
  }
}

