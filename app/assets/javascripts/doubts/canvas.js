var isMouseDown = false
  canvas1 = null
  ctx = null;

var linesArray = [];
  currentSize = 5;
var currentColor = "rgb(0,0,0)";
var currentBg = "white";

function init() {
  // hack to fix, tabs[0] undefined raised by artic admin
  setTimeout(() => $(document).off("click touchstart", "body"), 1000);

  canvas1 = document.getElementById('canvas1');
  ctx = canvas1.getContext('2d');

  ctx.fillStyle = currentBg;
  ctx.fillRect(0, 0, canvas1.width, canvas1.height);

}

function clearCanvas() {
  const m = confirm('Are you sure, you want to clear canvas ?');
  if (!!m){
    linesArray = [];
    ctx.fillRect(0, 0, canvas1.width, canvas1.height);
  }
}

function setupEvents() {
  document.getElementById('colorpicker').addEventListener('change', function () {
    currentColor = this.value;
  });
  document.getElementById('bgcolorpicker').addEventListener('change', function () {
    ctx.fillStyle = this.value;
    ctx.fillRect(0, 0, canvas1.width, canvas1.height);
    redraw();
    currentBg = ctx.fillStyle;
  });
  document.getElementById('controlSize').addEventListener('change', function () {
    currentSize = this.value;
    document.getElementById("showSize").innerHTML = this.value;
  });
  document.getElementById('saveToImage').addEventListener('click', function () {
    downloadCanvas(this, 'canvas1', 'doubt_answer.png');
  }, false);

  document.getElementById('eraser').addEventListener('click', eraser);
  document.getElementById('clear').addEventListener('click', clearCanvas);

  // REDRAW 

  function redraw() {
    for (var i = 1; i < linesArray.length; i++) {
      ctx.beginPath();
      ctx.moveTo(linesArray[i - 1].x, linesArray[i - 1].y);
      ctx.lineWidth = linesArray[i].size;
      ctx.lineCap = "round";
      ctx.strokeStyle = linesArray[i].color;
      ctx.lineTo(linesArray[i].x, linesArray[i].y);
      ctx.stroke();
    }
  }

  // DRAWING EVENT HANDLERS

  canvas1.addEventListener('mousedown', function () { mousedown(canvas1, event); });
  canvas1.addEventListener('mousemove', function () { mousemove(canvas1, event); });
  canvas1.addEventListener('mouseup', mouseup);

  // CREATE CANVAS
  // DOWNLOAD CANVAS

  function downloadCanvas(link, canvas1, filename) {
    link.href = document.getElementById(canvas1).toDataURL();
    link.download = filename;
  }

  // SAVE FUNCTION

  function save() {
    localStorage.removeItem("savedCanvas");
    localStorage.setItem("savedCanvas", JSON.stringify(linesArray));
    console.log("Saved canvas!");
  }

  // LOAD FUNCTION

  function load() {
    if (localStorage.getItem("savedCanvas") != null) {
      linesArray = JSON.parse(localStorage.savedCanvas);
      var lines = JSON.parse(localStorage.getItem("savedCanvas"));
      for (var i = 1; i < lines.length; i++) {
        ctx.beginPath();
        ctx.moveTo(linesArray[i - 1].x, linesArray[i - 1].y);
        ctx.lineWidth = linesArray[i].size;
        ctx.lineCap = "round";
        ctx.strokeStyle = linesArray[i].color;
        ctx.lineTo(linesArray[i].x, linesArray[i].y);
        ctx.stroke();
      }
      console.log("Canvas loaded.");
    }
    else {
      console.log("No canvas in memory!");
    }
  }

  // ERASER HANDLING

  function eraser() {
    currentSize = 50;
    currentColor = ctx.fillStyle
  }

  // GET MOUSE POSITION

  function getMousePos(canvas, evt) {
    var rect = canvas.getBoundingClientRect();
    return {
      x: evt.clientX - rect.left,
      y: evt.clientY - rect.top
    };
  }

  function mousedown(canvas, evt) {
    var mousePos = getMousePos(canvas, evt);
    isMouseDown = true
    var currentPosition = getMousePos(canvas, evt);
    ctx.moveTo(currentPosition.x, currentPosition.y)
    ctx.beginPath();
    ctx.lineWidth = currentSize;
    ctx.lineCap = "round";
    ctx.strokeStyle = currentColor;

  }

  function mousemove(canvas, evt) {

    if (isMouseDown) {
      var currentPosition = getMousePos(canvas, evt);
      ctx.lineTo(currentPosition.x, currentPosition.y)
      ctx.stroke();
      store(currentPosition.x, currentPosition.y, currentSize, currentColor);
    }
  }

  function store(x, y, s, c) {
    var line = {
      "x": x,
      "y": y,
      "size": s,
      "color": c
    }
    linesArray.push(line);
  }

  function mouseup() {
    isMouseDown = false
    store()
  }
}

