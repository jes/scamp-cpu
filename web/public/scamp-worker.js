// pass in text input, return text output
let scamptick = function(cycles, input) {
    return ccall('tick', 'string', ['number','string'], [cycles, input]);
};

let inputbuf = '';
let ticksperrun = 10000;
let lastrunend = Date.now();
let scamprun = function() {
    let thisinput = inputbuf;
    // XXX: is there a race window in between grabbing inputbuf and setting it to ''?
    inputbuf = '';

    // TODO: [nice] should we adjust the number of ticks based on how fast it's running?
    let out = scamptick(ticksperrun, thisinput);
    if (out != "") {
        postMessage({
            type: 'output',
            text: out,
        });
    }

    // try to target 1 MHz
    let now = Date.now();
    let duration = now - lastrunend;
    lastrunend = now;

    let delay = (ticksperrun / 1000) - duration;
    if (delay < 0) delay = 0;

    setTimeout(scamprun, delay);
};

onmessage = function(m) {
    let o = m.data;
    if (o.type == "input") {
        inputbuf += o.text;
    }
};

var Module = {
    onRuntimeInitialized: function() {
        setTimeout(scamprun, 0);
    },
    printErr: function(text) {
        if (arguments.length > 1) text = Array.prototype.slice.call(arguments).join(' ');
        postMessage({
            type: 'printErr',
            text: text,
        });
    },
    setStatus: function(text) {
        postMessage({
            type: 'setStatus',
            text: text,
        });
    },
    totalDependencies: 0,
    monitorRunDependencies: function(left) {
        this.totalDependencies = Math.max(this.totalDependencies, left);
        Module.setStatus(left ? 'Preparing... (' + (this.totalDependencies-left) + '/' + this.totalDependencies + ')' : 'All downloads complete.');
    },

};

Module.setStatus('Downloading...');
console.log("worker begins");
importScripts("scamp.js");
