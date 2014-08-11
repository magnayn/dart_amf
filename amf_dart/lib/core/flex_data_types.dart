part of amf;

class FlexCommandMessageOperationType {
  static const int SubscribeOperation = 0;

  static const int UnsubscribeOperation = 1;

  static const int PollOperation = 2;

  static const int ClientSyncOperation = 4;

  static const int ClientPingOperation = 5;

  static const int ClusterRequestOperation = 7;

  static const int LoginOperation = 8;

  static const int LogoutOperation = 9;

  static const int SubscriptionInvalidateOperation = 10;

  static const int MultiSubscribeOperation = 11;

  static const int DisconnectOperation = 12;

  static const int TriggerConnectOperation = 13;

  static const int UnknownOperation = 1000;
}


@RemoteClass("flex.messaging.io.ArrayCollection")
class FlexArrayCollection extends ListBase<Object> implements Externalizable {
  List _source;

  int get length => _source.length;

  void set length(int length) {
    _source.length = length;
  }

  void operator []=(int index, Object value) {
    _source[index] = value;
  }

  Object operator [](int index) => _source[index];

  // Though not strictly necessary, for performance reasons
  // you should implement add and addAll.

  void add(Object value) => _source.add(value);

  void addAll(Iterable<Object> all) => _source.addAll(all);

  void writeExternal(ObjectOutput out) {
    out.writeObject(_source);
  }

  void readExternal(ObjectInput input) {
    _source = input.readObject();
  }
}

class FlexObjectProxy {
  Object object;
}

class FlexAbstractMessage {
  Object body;

  String clientId;

  String destination;

  var headers;

  // dict

  String messageId;

  num timeToLive = 0;

  num timestamp = 0;

  FlexAbstractMessage() {
    print("Make FlexAbstractMessage");
    messageId = "4D8845C0-6768-4942-9F9E-FC45E0215C8B";
    clientId = "4D8845C0-6768-4942-9F9E-FC45E021FFFF";
    timestamp = new DateTime.now().millisecondsSinceEpoch;
  }

  void writeObject(var coder) {
    coder.encodeObjectKeyValue("body", body);
    coder.encodeObjectKeyValue("clientId", clientId);
    coder.encodeObjectKeyValue("destination", destination);
    coder.encodeObjectKeyValue("headers", headers);
    coder.encodeObjectKeyValue("messageId", messageId);
    coder.encodeDoubleKeyValue("timeToLive", (timeToLive * 1000).toDouble());
    coder.encodeDoubleKeyValue("timestamp", (timestamp * 1000).toDouble());
  }

  void readObject(var coder) {
    body = coder.decodeObjectForKey("body");
    clientId = coder.decodeObjectForKey("clientId");
    destination = coder.decodeObjectForKey("destination");
    headers = coder.decodeObjectForKey("headers");
    messageId = coder.decodeObjectForKey("messageId");
    timeToLive = (coder.decodeDoubleForKey("timeToLive") / 1000).toInt();
    timestamp = (coder.decodeDoubleForKey("timestamp") / 1000).toInt();

  }
}

class FlexAsyncMessage extends FlexAbstractMessage {
  String correlationId;

}

class FlexCommandMessage extends FlexAsyncMessage {
  int operation;

  void writeObject(var coder) {
    super.writeObject(coder);
    coder.encodeObjectKeyValue("operation", operation);
  }
}

@RemoteClass("flex.messaging.messages.AcknowledgeMessage")
class FlexAcknowledgeMessage extends FlexAsyncMessage {
  FlexAcknowledgeMessage() : super () {
    print("make FlexAcknowledgeMessage");
  }
}

class FlexErrorMessage extends FlexAcknowledgeMessage {
  Object extendedData;

  String faultCode;

  String faultDetail;

  String faultString;

  Object rootCause;

  FlexErrorMessage() : super () {
    print("make FlexErrorMessage");
  }

  String toString() {
    return "faultCode: ${faultCode},\n faultDetail: ${faultDetail},\n faultString: ${faultString},\n rootCause: ${rootCause},\nextendedData: ${extendedData}";
  }

}

@RemoteClass("flex.messaging.messages.RemotingMessage")
class FlexRemotingMessage extends FlexAbstractMessage {
  String operation;

  String source;


}
