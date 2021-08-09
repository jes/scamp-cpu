// pass in text input, return text output
let scamptick = function(cycles, input) {
    return ccall('tick', 'string', ['number','string'], [cycles, input]);
};

let inputbuf = '';
let scamprun = function() {
    let thisinput = inputbuf;
    // XXX: is there a race window in between grabbing inputbuf and setting it to ''?
    inputbuf = '';

    let out = scamptick(1000000, thisinput);
    if (out != "") {
        postMessage({
            type: 'output',
            text: out,
        });
    }

    // XXX: is there a better way to run an infinite loop without blocking onmessage() invocation?
    setTimeout(scamprun, 0);
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
