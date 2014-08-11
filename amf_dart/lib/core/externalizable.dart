part of amf;

abstract class Externalizable {
  void writeExternal(ObjectOutput ser);

  void readExternal(ObjectInput ser);
}

