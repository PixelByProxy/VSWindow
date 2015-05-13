
var socket = {
  
    clientSocket: null,
    dataReader: null,
    dataWriter: null,
    connected: false,
    closing: false,
    subscriber: null,
    listeners: [],
    receivedData: "",
    onOpened: [],
    onClosed: [],
    onFailed: [],
    onReceived: [],
    
    addOnOpened: function(func) {
        socket.onOpened.push(func);
    },
    
    addOnClosed: function (func) {
        socket.onClosed.push(func);
    },

    addOnFailed: function (func) {
        socket.onFailed.push(func);
    },

    addOnReceived: function (func) {
        socket.onReceived.push(func);
    },

    open: function (serverName, port) {
        if (socket.clientSocket) {
            socket.close();
        }
        socket.closing = false;
        var serverHostName = new Windows.Networking.HostName(serverName);
        var serviceName = port;
        socket.clientSocket = new Windows.Networking.Sockets.StreamSocket();
        //socketsSample.displayStatus("Client: connection started.");
        socket.clientSocket.connectAsync(serverHostName, serviceName, Windows.Networking.Sockets.SocketProtectionLevel.plainSocket).done(function () {
            
            socket.connected = true;
            socket.dataWriter = new Windows.Storage.Streams.DataWriter(socket.clientSocket.outputStream);
            socket.dataReader = new Windows.Storage.Streams.DataReader(socket.clientSocket.inputStream);
            socket.dataReader.inputStreamOptions = Windows.Storage.Streams.InputStreamOptions.partial;

            for (var i in socket.onOpened)
                socket.onOpened[i](serverHostName, serviceName);

            socket.receive();

        }, socket.onError);
    },
    
    close: function() {
        socket.closing = true;
        if (socket.clientSocket) {
            socket.clientSocket.close();
            socket.clientSocket = null;
            socket.connected = false;

            for (var i in socket.onOpened)
                socket.onClosed[i]();
        }
    },
    
    send: function (message) {
        if (!socket.connected) {
            socket.displayStatus("Client: you must connect the client before using it.");
            return;
        }
        var writer = new Windows.Storage.Streams.DataWriter(socket.clientSocket.outputStream);
        //var len = writer.measureString(message); // Gets the UTF-8 string length.
        //writer.writeInt32(len);
        writer.writeString(message);
        console.log("Client sending: " + message + ".");
        writer.storeAsync().done(function () {
            console.log("Client sent: " + message + ".");
            writer.detachStream();
        }, socket.onError);
    },
    
    receive: function() {
        socket.dataReader.loadAsync(100).done(function (sizeBytesRead) {
            //countOfDataReceived += sizeBytesRead;
            //document.getElementById("dataReceived").value = countOfDataReceived;

            var incomingBytes = new Array(sizeBytesRead);
            socket.dataReader.readBytes(incomingBytes);

            for (var i = 0; i < incomingBytes.length; i++) {
                if (incomingBytes[i] == 0) {
                    var obj = JSON.parse(socket.receivedData);

                    console.log(socket.receivedData);
                    //Windows.UI.Popups.MessageDialog(socket.receivedData).showAsync().then();

                    for (var m in socket.onReceived)
                        socket.onReceived[m](obj);

                    socket.receivedData = "";
                } else {
                    socket.receivedData += String.fromCharCode(incomingBytes[i]);
                }
            }
            
            // Do something with the data.
            // Alternatively you can use DataReader to read out individual  
            // booleans, ints, strings, etc.

            socket.receive(); // Start another read
        }, socket.onError);
    },
    
    onError: function (reason) {
        socket.clientSocket = null;

        // When we close a socket, outstanding async operations will be canceled and the
        // error callbacks called.  There's no point in displaying those errors.
        if (!socket.closing) {

            for (var i in socket.onFailed)
                socket.onFailed[i]();

            Windows.UI.Popups.MessageDialog(reason).showAsync().then();
        }
    }
};