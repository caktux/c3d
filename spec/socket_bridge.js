var io = require('socket.io').listen(31313);

transact = function(socket, data) {
  socket.emit('transact', data);
};

io.sockets.on('connection', function(socket) {

  socket.on('clientRequestsAddBlob', function(data) {
    socket.broadcast.emit('transact', data);
  });

  socket.on('clientRequestsAddresses', function(data) {
    socket.broadcast.emit('getAddresses');
  });

  socket.on('getAddresses', function(data) {
    socket.broadcast.emit('clientRequestsAddresses', data);
  });

  // socket.emit('getStorageAt', [
  //   'd00383d79aaede0ed34fab69e932a878e00a8938',
  //   '0x2A519DE3379D1192150778F9A6B1F1FFD8EF0EDAC9C91FA7E6F1853700600005'
  // ]);
  // socket.on('getStorageAt', function(data) {
  //   console.log("StorageAt --->")
  //   console.log(data);
  // });

  // socket.emit('newBlock');
  // socket.on('newBlock', function(data) {
  //   console.log("New Block --->");
  //   console.log(data);
  // });
});