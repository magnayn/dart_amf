dart_amf
========

AMF3 library for dart

Work in progress - not complete. Many things may not work. Not optimised. Lots of debug output currently that
 will be slowing things down. Etc., etc.

Uses dart mirrors, so understand the implications of that.

Usage
-----

Do something like the following:

- Initialise the AMF system, and make it search for classes with the @RemoteClass annotation

        AMF.init();        
        AMF.findAnnotatedClasses();

- Declare a Server class that uses channels

        class Server {
            String baseUrl;
            Channel _channel;
        
            Server(this.baseUrl); // Call with something like http://mysite:8080/messagebroker/amf
        
            Channel get channel {
              _channel = new Channel("my-channel-id", baseUrl);
              return _channel;
            }
        }

- Create a base class for your services

        class BaseAmfService {
          Server _server;
          String _service;
        
          BaseAmfService(this._service, this._server) {
        
          }
        
          RemoteService get remoteObject {
            RemoteService remoteObject = new RemoteService(_server.channel, _service);
        
              return remoteObject;
            }
        }

- Implement services that match your remote AMF protocol, and implement some methods

        class SomeKindOfService extends BaseAmfService {
            SomeKindOfService(Server server) : super("SomeKindOfServiceName", server)
            {
        
            }
        
            // Methods
            Future<Object> doSomething(bool param)
            {
               return remoteObject.callMethod("getRoles", [param])
                                  .then( (ResultEvent event) => event.result );
            }
        
        }

- Call your services!

        AMF.init();        
        AMF.findAnnotatedClasses();

        Server server = new Server("http://mysite:8080/messagebroker/amf");
                
        SomeKindOfService svc = new SomeKindOfService(server);
        
        svc.doSomething(true).then((r) {
          print("I got it ${r}");
        } );
        
Serialization options
---------------------
        
You can serialize your classes much like in Actionscript. 

- Named types that don't exist will be constructed as ASObject instances (and you can use it like a map).
        
- Named types that do exist will be constructed. If they implement Externalizable, that will be called. Otherwise
the object will be populated dynamically.

- Annotate your class with @RemoteClass("the.name.of.the.class") to name it.

(Externalizable must match on the java side)

E.g:

        @RemoteClass("com.nirima.model.Activity")
        class Activity implements Externalizable
        {
            bool done;
            Activity relatesToTask;
            
            void writeExternal(ObjectOutput output) {
               super.writeExternal(output);
               output.writeObject(done);
               output.writeObject(relatesToTask);
            }
        
            void readExternal (ObjectInput input) {
                super.readExternal(input);
                done = input.readObject();
                relatesToTask = input.readObject();
            }        
        }
        

