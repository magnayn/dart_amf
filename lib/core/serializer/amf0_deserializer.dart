part of amf;

class AMF0Deserializer {
  InputStream _rawStream;
  DataInput _stream;
  List<Object> _storedObjects = new List<Object>();

  AMF0Message _message = new AMF0Message();

  DataInput get stream => _stream;

  AMF0Message get message => _message;


  AMF0Deserializer(this._rawStream) {
    _stream = new DataInputStream(_rawStream);
    _readHeaders();
    _readBodies();
  }

  void _readHeaders() {

    _message.version = _stream.readUnsignedShort();
    int numHeaders = _stream.readUnsignedShort();

    for (int i = 0; i < numHeaders; i++) {
      String name = _stream.readUTF();
      bool mustUnderstand = _stream.readBoolean();
      _stream.readInt(); // Length

      int type = _stream.readByte();

      Object value = _readData(type);

      _message.addHeader(name, mustUnderstand, value);
    }
  }

  void _readBodies() {
    int numBodies = _stream.readUnsignedShort();

    for (int i = 0; i < numBodies; i++) {
      String targetURI = _stream.readUTF();
      String responseURI = _stream.readUTF();
      _stream.readInt(); // len
      int type = _stream.readByte();

      Object data = _readData(type);

      _message.addBody(targetURI, responseURI, data);
    }

  }

  Object _readData(int type) {
    switch (type) {

      case AMF0Type.Number :
        return _stream.readDouble();
        break;

      case AMF0Type.Boolean :
        return _stream.readBoolean();

        break;

      case AMF0Type.String :
        return _stream.readUTF();
        break;

      case AMF0Type.Object :
        return _readObject();
        break;

    // case AMF0Type.MovieClip : break;

      case AMF0Type.Null :
        return null;
        break;

      case AMF0Type.Undefined :
        return null;
        break;

      case AMF0Type.Reference :
        _readFlushedSO();
        break;

      case AMF0Type.ECMAArray :
        _stream.readInt();
        return _readObject();


      case AMF0Type.ObjectEnd :
        return null;


      case AMF0Type.StrictArray :
        return _readArray();

      case AMF0Type.Date :
        return _readDate();

      case AMF0Type.LongString:
        return _readLongUTF();

      case AMF0Type.Unsupported :
        return _readASObject();
        break;

      case AMF0Type.Recordset :
        return null;
        break;

      case AMF0Type.XMLObject :
        return _readXML();
        break;

      case AMF0Type.TypedObject :
        return _readCustomClass();

      case AMF0Type.AVMPlusObject:
        return _readAMF3Data();


      default:
        throw new Error();
    // Notimpl
    }

  }


  Object _readAMF3Data() {
    AMF3Deserializer amf3 = new AMF3Deserializer(_rawStream);
    return amf3.readObject();
  }
}