function moveCamera(direction) {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.open("GET", "/camera/move/" + direction, true);
  xmlhttp.send();
}

function refreshSnapshot() {
  document.getElementById('snapshot').src = "/camera/snapshot?t=" + new Date().getTime();
}

/*
window.onload = function() {
  if (document.getElementById('snapshot')) {
    setInterval(refreshSnapshot, 2000);
  }
}
*/
