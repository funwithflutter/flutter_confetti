import 'dart:isolate';

class DataObject {
  final int number;
  final String message;

  DataObject(this.number, this.message);
}

void main() {
  // Create a new isolate and send it some data
  ReceivePort receivePort = ReceivePort();
  Isolate.spawn(isolateFunction, receivePort.sendPort);

  // Listen for a response from the isolate
  receivePort.listen((response) {
    if (response is DataObject) {
      print(response.number);
      print(response.message);
    }
  });
}

void isolateFunction(SendPort sendPort) {
  // Send a response back to the main isolate
  DataObject response = DataObject(42, "Hello, Isolate!");
  sendPort.send(response);
}
