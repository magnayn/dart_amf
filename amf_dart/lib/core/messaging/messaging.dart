part of amf;

class AMF0Message {

  int version = 3;
  final List<AMF0Header> headers = new List<AMF0Header>();
  final List<AMF0Body> bodies = new List<AMF0Body>();

  getBodyCount() {
    return bodies.length;
  }


  getHeaderCount() {
    return headers.length;
  }

  getVersion() {
    return version;
  }

  void addBody(String target, String response, var value, [int type]) {
    bodies.add(new AMF0Body(target, response, value));
  }

  void addHeader(String key, bool required1, Object object) {
    headers.add(new AMF0Header(key, required1, object));
  }

  setVersion(value) {
    version = value;
  }

  AMF0Message() {
  }


}


class AMF0Header {
  String _key;
  bool _required;
  Object _value;

  AMF0Header(this._key, this._required, this._value) {
  }

  Object get value => _value;

  bool get required => _required;

  String get key => _key;
}

class AMF0Body {
  String _target;
  String _response;
  Object _value;

  // int _type; // From AMF0Types ??

  AMF0Body(this._target, this._response, this._value) {
  }

  Object get value {
    return _value;
  }

  String get response {
    return _response;
  }

  /**
   * TargetURI
   */

  String get target {
    return _target;
  }
}

class AMF3Object {
  final Object value;

  AMF3Object(this.value);
}

