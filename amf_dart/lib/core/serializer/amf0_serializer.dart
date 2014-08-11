part of amf;

class AMF0Serializer {
  DataOutput _stream = new DataOutputStream();
  List<Object> _storedObjects = new List<Object>();

  DataOutput get stream => _stream;


  void serializeMessage(AMF0Message message) {
    _stream.writeShort(message.version);
    _stream.writeShort(message.headers.length);

    for (AMF0Header header in message.headers) {
      _writeHeader(header);
    }

    _stream.writeShort(message.bodies.length);

    for (AMF0Body body in message.bodies) {
      _writeBody(body);
    }
  }

  void _writeHeader(AMF0Header header) {
    _stream.writeUTF(header.key);
    _stream.writeBoolean(header.required);
    _stream.writeInt(-1);
    _writeData(header.value);
  }

  void _writeBody(AMF0Body body) {
    if (body.target == null)_stream.writeUTF("null");
    else_stream.writeUTF(body.target);

    if (body.response == null)_stream.writeUTF("null");
    else_stream.writeUTF(body.response);

    _stream.writeInt(-1);

    _writeData(body.value);

  }

  void _writeData(Object value) {
    if (value == null) {
      _stream.writeByte(AMF0Type.Null);
    } else if (value is AMF3Object) {
      _writeAMF3Data(value);
    } else if (value is String) {
      _writeString(value);
    } else if (value is int) {
      _stream.writeByte(AMF0Type.Number);
      _stream.writeDouble(value.toDouble());
    } else {
      // Object type

      if (_storedObjects.contains(value)) {
        _writeStoredObject(value);
        return;
      }
      _storedObjects.add(value);

      if (value is List) {
        _writeList(value);
      } else if (value is Map) {
        throw new UnimplementedError("Can't write data for ${value}");
      } else {
        _writeObject(value);
      }
    }
  }

  void _writeObject(Object value) {

    print(".. ser: ${value}");

    if (value == null)throw new StateError("Can't send null value");

    _stream.writeByte(AMF0Type.Object);

    // TODO: Serialization types?

    InstanceMirror instanceMirror = reflect(value);
    ClassMirror classMirror = instanceMirror.type;
    _writeObjectFields(classMirror, instanceMirror);

    _stream.writeShort(0);
    _stream.writeByte(AMF0Type.ObjectEnd);
  }

  void _writeObjectFields(ClassMirror classMirror, InstanceMirror instanceMirror) {
    classMirror.declarations.forEach((name, declaration) {

      if (declaration is VariableMirror) {
        VariableMirror vm = declaration;
        var strname = MirrorSystem.getName(name);
        _stream.writeUTF(strname);
        var data = instanceMirror.getField(name).reflectee;

        _writeData(data);
        print(".. ser ${strname} = ${data}");

      } else if (declaration is MethodMirror) {
        MethodMirror mm = declaration;
        if (mm.isGetter) {
          var x = instanceMirror.getField(name);

        }
      }

    });

    if (classMirror.superclass != null && classMirror.superclass.reflectedType != Object)_writeObjectFields(classMirror.superclass, instanceMirror);
  }

  void _writeList(List value) {
    _stream.writeByte(AMF0Type.StrictArray);
    _stream.writeInt(value.length);

    value.forEach((o) => _writeData(o));
  }

  void _writeStoredObject(Object value) {
    _stream.write(AMF0Type.Reference);
    // Assume the speed/size tradeoff is fine with a list. Could have a map.
    _stream.writeShort(_storedObjects.indexOf(value));
  }

  void _writeString(String value) {
    List codeUnits = value.codeUnits;

    if (codeUnits.length > 0xffff) {
      _stream.write(AMF0Type.LongString); // 4 bytes length
      _stream.writeInt(codeUnits.length);
    } else {
      _stream.write(AMF0Type.String); // 2 bytes length
      _stream.writeShort(codeUnits.length);
    }

    _stream.writeBytes(codeUnits);
  }

  void _writeAMF3Data(AMF3Object data) {
    _stream.write(AMF0Type.AVMPlusObject);
    AMF3Serializer amf3 = new AMF3Serializer(_stream);
    amf3.writeObject(data.value);
  }
}