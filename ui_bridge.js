var strftime       = require('strftime');

var c3dAddress     = 'tcp://127.0.0.1:31314';
var zeromq         = require('zmq');
var c3dSocket      = zeromq.socket('rep');
c3dSocket.identity = 'uiResponder' + process.pid;

var uiBridge      = require('socket.io').listen(31316);

if (!Array.prototype.last){
    Array.prototype.last = function(){
        return this[this.length - 1];
    };
};

console.log( "[C3D-EPM::" + strftime('%F %T', new Date()) + "] c3d<-ui on port >>\t" + c3dAddress.split(':').last() );

c3dSocket.bind(c3dAddress, function(err) {
  if (err) throw err;
  uiBridge.sockets.on('connection', function(uiBridgeSocket) {
    uiBridgeSocket.on('command', function(data) {
      console.log( "[C3D-EPM::" + strftime('%F %T', new Date()) + "] Sending command >>\t" + data.command );
      c3dSocket.send('message', data, function(response) {
        socket.emit('command', JSON.parse(response.toString()));
      });
    });
  });
});

process.on('SIGINT', function() {
  c3dSocket.close();
  uiBridge.socket.close();
});
