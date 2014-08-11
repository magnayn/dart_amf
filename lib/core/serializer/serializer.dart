part of amf;

abstract class DataOutput {
  void write(int v);

  void writeInt(int v);

  void writeShort(int v);

  void writeDouble(double d);

  void writeBoolean(bool v);

  void writeUTF(String str);

  void writeByte(int b);

  void writeBytes(List l);

}

abstract class ObjectOutput extends DataOutput {
  void writeObject(Object o);
}

class DataOutputStream extends DataOutput {
  Uint8List _dataList;
  var _buffer;
  ByteData _data;
  int _position = 0;

  DataOutputStream() {
    _dataList = new Uint8List(102400);
    _buffer = _dataList.buffer;
    _data = new ByteData.view(_buffer);
  }

  get data => new Uint8List.view(_buffer, 0, _position);

  void _ensureLength(int length) {
    // TODO : resize the buffer?
  }

  void write(int v) {
    writeByte(v);
  }

  void writeInt(int v) {
    _ensureLength(4);
    _data.setInt32(_position, v);
    _position += 4;
  }

  void writeShort(int value) {
    _ensureLength(2);
    _data.setUint16(_position, value);
    _position += 2;
  }

  void writeDouble(double d) {
    _ensureLength(8);
    _data.setFloat64(_position, d);
    _position += 8;
  }

  void writeBoolean(bool v) {
    write(v ? 1 : 0);
  }

  void writeUTF(String s) {
    writeShort(s.length);
    _ensureLength(s.length);
    for (int i = 0; i < s.length; i++) {
      var cc = s.codeUnitAt(i);
      _data.setUint8(_position++, cc);
    }
  }

  void writeByte(int b) {
    _ensureLength(1);
    _data.setUint8(_position++, b);
  }

  void writeBytes(List value) {
    _ensureLength(value.length);
    _dataList.setRange(_position, _position + value.length, value);
    _position += value.length;
  }
}