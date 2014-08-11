part of amf;

class RemoteService {
  Channel _channel;
  String _id;

  RemoteService(this._channel, this._id);

  Future callMethod(String method, List args) {
    FlexRemotingMessage message = new FlexRemotingMessage();
    message.body = (args == null ? [] : args);
    message.operation = method;
    message.destination = _id;

    AsyncToken token = new AsyncToken(message);
    /*
     * Options to call method with responders
     */

    return _channel.sendToken(token);
  }
}

class AsyncToken {
  FlexAbstractMessage _message;
  List _responders;
  AbstractEvent _responseEvent;

  AsyncToken(FlexAbstractMessage message) {
    _message = message;
    _responders = [];
  }
}

class Channel {
  String _id;
  String _url;
  String _credentials;

  bool _connected;
  bool _authenticated;

  int _timeout;

  List _pendingTokens;
  List _sentTokens;

  XAMFRequest _request;

  Channel(this._id, this._url);

  Future sendToken(AsyncToken token) {
    // Some kind of parallel stuff

    List messages = [];

    FlexAbstractMessage message = token._message;

    messages.add(message);

    AMF0Message amf0 = _createAMF0MessageWithMessages(messages);

    AMF0Serializer serializer = new AMF0Serializer();
    serializer.serializeMessage(amf0);

    var data = serializer.stream.data;

    return _atomicSendRequest(data);

  }

  Future _atomicSendRequest(var data) {
    _request = new XAMFRequest();
    return _request.process(_url, data);
  }

  AMF0Message _createAMF0MessageWithMessages(List messages) {
    AMF0Message amf0 = new AMF0Message();
    messages.forEach((E) {
      amf0.addBody("", "/1", [new AMF3Object(E)]);
    });
    return amf0;
  }
}

class ChannelNotification {
  Channel _channel;
  int _level;
  String _message;
  var _error;
  var _exception;

  Map _userInfo;
}


class Configuration {

}

class AbstractEvent {

}

class FaultEvent {
  FlexErrorMessage _response;
}


class ResultEvent extends AbstractEvent {
  FlexAcknowledgeMessage _response;

  ResultEvent(this._response);

  Object get result => _response.body;
}


class XAMFRequest {
  Future process(String url, var body) {

    HttpRequest request = new HttpRequest();

    request.open('POST', url);
    request.responseType = "arraybuffer";
    request.setRequestHeader("Content-Type", "application/x-amf");
    //request.setRequestHeader("User-Agent", "DartAMF");

    AMF.traceSend(body);

    return HttpRequest.request(url, method: "POST", responseType: "arraybuffer", sendData: body).then((request) {
      //this is a hack for dart2js because of a bug
      Uint8List buffer = new Uint8List.view(request.response, 0, (request.response as ByteBuffer).lengthInBytes);
      AMF.traceRecv(buffer);
      Object obj = decodeResponse(buffer);
      print("Request OK : ${obj}");
      return obj;
    });

  }

  Object decodeResponse(Uint8List data) {

    AMF0Deserializer ser = new AMF0Deserializer(new ByteDataStream(data));

    List responses = ser.message.bodies;

    int count = responses.length;
    print("${count} responses");

    for (int i = 0; i < count; i++) {
      Object object = responses[i].value;
      print("1st response = ${object}");

      if (object is FlexAsyncMessage) {
        //FlexAsyncMessage response = (FlexAsyncMessage)object;
        AbstractEvent event;

        if (object is FlexErrorMessage) {
          print("ERROR: ${object}");
          throw object;
        } else if (object is FlexAcknowledgeMessage) {
          event = new ResultEvent(object);
          return event;
        }

      }

    }
    return null;
  }
}
