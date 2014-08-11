part of amf;

abstract class DataInput {
  int read();

  int readInt();

  int readShort();

  int readUnsignedShort();

  double readDouble();

  bool readBoolean();

  String readUTF();

  int readByte();

  List readBytes();
}

abstract class ObjectInput extends DataInput {
  Object readObject();
}

abstract class InputStream {
  ByteData get data;

  int get position;

  int positionIncrement(int amount);
}

class ByteDataStream extends InputStream {
  Uint8List _dataList;
  var _buffer;
  ByteData _data;
  int _position = 0;

  ByteDataStream(this._dataList) {
    _buffer = _dataList.buffer;
    _data = new ByteData.view(_buffer);
  }

  ByteData get data => _data;

  int get position => _position;

  int positionIncrement(int amount) {
    int pos = _position;
    _position += amount;
    return pos;
  }
}

class DataInputStream extends DataInput {
  InputStream _stream;

  DataInputStream(this._stream) {

  }

  int read() {
    return _stream.data.getInt8(_stream.positionIncrement(1));
  }

  int readInt() {
    int value = _stream.data.getInt32(_stream.positionIncrement(4));
    return value;
  }

  int readShort() {
    int value = _stream.data.getInt16(_stream.positionIncrement(2));
    return value;
  }

  int readUnsignedShort() {
    int value = _stream.data.getUint16(_stream.positionIncrement(2));
    return value;
  }

  double readDouble() {
    double value = _stream.data.getFloat64(_stream.positionIncrement(8));
    return value;
  }

  bool readBoolean() {
    return read() != 0;
  }

  String readUTF() {
    int length = readShort();

    String result = "";

    for (int i = 0; i < length; i++) {
      int char = _stream.data.getUint8(_stream.positionIncrement(1));
      result += new String.fromCharCode(char);
    }
    return result;
  }

  int readByte() {
    return read();
  }

  List readBytes() {

  }
}