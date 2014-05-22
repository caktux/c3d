var strftime       = require('strftime');
var dirtyHack      = 0;
var c3dAddress     = 'tcp://127.0.0.1:31315';

var zeromq         = require('zmq');
var c3dSocket      = zeromq.socket('rep');

var ethBridge      = require('socket.io').listen(31313);

if (!Array.prototype.last){
    Array.prototype.last = function(){
        return this[this.length - 1];
    };
};

console.log( "[C3D-EPM::" + strftime('%F %T', new Date()) + "] eth<-c3d on port >>\t" + c3dAddress.split(':').last() );

c3dSocket.bind(c3dAddress, function(err) {
  if (err) throw err;
  ethBridge.sockets.on('connection', function(ethBridgeSocket) {

    c3dSocket.on('message', function(data) {
      dirtyHack = 1;

      var question = JSON.parse(data.toString());
      console.log( "[C3D-EPM::" + strftime('%F %T', new Date()) + "] Question asked >>\t" + question.command );

      if ( question.command == 'c3dRequestsAddBlob') {
        ethBridgeSocket.emit('transact', question.params);
        ethBridgeSocket.on('transactResponse', function(response) {
          respond(response,c3dSocket);
        });

      } else if ( question.command == 'c3dRequestsAddGroup' ) {
        ethBridgeSocket.emit('transact');
        ethBridgeSocket.on('transactResponse', function(response) {
          respond(response,c3dSocket);
        });

      } else if ( question.command == 'c3dRequestsAddresses' ) {
        ethBridgeSocket.emit('getAddresses');
        ethBridgeSocket.on('getAddressesResponse', function(response) {
          respond(response,c3dSocket);
        });

      } else if ( question.command == 'c3dRequestsStorage') {
        ethBridgeSocket.emit('getStorageAt', question.params);
        ethBridgeSocket.on('getStorageAtResponse', function(response) {
          respond(response, c3dSocket);
        });
      };
    });
  });
});

// todo == dirty hack for when multiple tx are sent... need to be ~1s apart.
// todo == debug why the new 'newt' is not working.

var respond = function(response, c3dSocket) {
  if(dirtyHack == 1) {
    dirtyHack++;
    answer = {success: 'true', answer: response};
    console.log( "[C3D-EPM::" + strftime('%F %T', new Date()) + "] Sending answer >>\t" + answer.success );
    c3dSocket.send(JSON.stringify(answer));
  }
};

process.on('SIGINT', function() {
  c3dSocket.close();
  ethBridge.socket.close();
});
