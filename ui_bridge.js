var strftime       = require('strftime');

var c3dAddress     = 'tcp://127.0.0.1:31314';
var zeromq         = require('zmq');
var c3dSocket      = zeromq.socket('rep');
c3dSocket.identity = 'uiResponder' + process.pid;

if (!Array.prototype.last){
    Array.prototype.last = function(){
        return this[this.length - 1];
    };
};

console.log( "[C3D-EPM::" + strftime('%F %T', new Date()) + "] eth<-c3d on port >>\t" + c3dAddress.split(':').last() );

c3dSocket.bind(c3dAddress, function(err) {
  if (err) throw err;

  c3dSocket.send('message', function(data) {

    var question = JSON.parse(data.toString());
    console.log( "[C3D-EPM::" + strftime('%F %T', new Date()) + "] Question asked >>\t" + question.command );

  });
});

process.on('SIGINT', function() {
  c3dSocket.close();
  ethBridge.socket.close();
});
