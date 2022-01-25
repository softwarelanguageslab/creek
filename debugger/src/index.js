import './style.css';


var editor = CodeMirror.fromTextArea(document.getElementById('editor'), {
    mode: "ruby",
    lineNumbers: true,
});
editor.save()

var editor2 = CodeMirror.fromTextArea(document.getElementById('editor2'), {
    mode: "ruby",
    lineNumbers: true,
});
editor2.save()

var stream_cache = {};
var operators_cache = {};
var current_stream_id = null;
// create an array with nodes
// var nodes = new vis.DataSet([
//     { id: 1, label: "Node 1" },
//     { id: 2, label: "Node 2" },
//     { id: 3, label: "Node 3" },
// ]);
var nodes = new vis.DataSet([]);

// create an array with edges
// var edges = new vis.DataSet([
//     { from: 1, to: 2, label: "middle", font: { align: "middle" } },
//     { from: 1, to: 3, label: "middle", font: { align: "middle" } },
// ]);
var edges = new vis.DataSet([])
var container = document.getElementById("mynetwork");
var data = {
    nodes: nodes,
    edges: edges,
};

var options = { physics: true };
var network = new vis.Network(container, data, options);

var selected_node = null;
var selected_edge = null;

function updateNodeDetails() {
    var node = nodes.get(selected_node);
    var node_id = node.id;
    var node_label = node.label;

    var operator = operators_cache[node_id];
    console.log(operator);
    document.getElementById("node_id").textContent = node_id;
    document.getElementById("node_name").textContent = operator.name;
    document.getElementById("node_pid").textContent = operator.pid;
    document.getElementById("node_arity").textContent = `${operator.in}:${operator.out}`;
    editor.doc.setValue(operator.arg);
    editor2.doc.setValue(operator.opts);

    document.getElementById("node_data").style.display = "flex";
    document.getElementById("edge_data").style.display = "none";

    editor.refresh()
    editor2.refresh()
};
function updateEdgeDetails() {
    console.log(`Clicked on edge ${selected_edge}`);

    var edge = edges.get(selected_edge);
    var edge_id = edge.id;
    var edge_label = edge.label;

    setLabelEdge(edge_id);

    document.getElementById("edge_id").textContent = edge_id;
    document.getElementById("edge_label").textContent = edge_label;

    document.getElementById("node_data").style.display = "none";
    document.getElementById("edge_data").style.display = "flex";
};

function setLabelEdge(edge_id, label) {
    var edge = edges.get(edge_id);
    var from = edge.from;
    var to = edge.to;
    edges.update({ id: edge.id, from: from, to: to, label: label });
}

function terminateNode(node_id) {
    var node = nodes.get(node_id);

    node.color = {
        border: 'red',
        background: 'red',
        highlight: {
            border: 'red',
            background: 'red'
        }
    };
    nodes.update(node);
}

function completeNode(node_id) {
    var node = nodes.get(node_id);

    node.color = {
        border: 'green',
        background: 'green',
        highlight: {
            border: 'green',
            background: 'green'
        }
    };
    nodes.update(node);
}

function nodeEmitted(node_id, value) {
    var node = nodes.get(node_id);

    var edges = network.getConnectedEdges(node.id);
    edges.forEach(element => {
        setLabelEdge(element, value);
    });
}

network.on("click", function (params) {
    socketOff();
    if (params.nodes != null && params.nodes.length > 0) {
        selected_node = params.nodes[0];
        updateNodeDetails();
        return;
    }
    if (params.edges != null && params.edges.length > 0) {
        selected_edge = params.edges[0];
        updateEdgeDetails();
        return;
    }
});

function socketOn() {
    document.getElementById("socket_off").style.removeProperty("display");
    document.getElementById("socket_on").style.display = "none";
}
function socketOff() {
    document.getElementById("socket_on").style.removeProperty("display");
    document.getElementById("socket_off").style.display = "none";
}

function streamClick(event) {
    var streamid = event.target.innerHTML.substring(7);
    var stream = stream_cache[streamid];

    current_stream_id = streamid;
    operators_cache = {};
    nodes.clear();
    edges.clear();

    stream.forEach(edge => {
        var from = { id: edge.from.pid, label: edge.from.name }
        var to = { id: edge.to.pid, label: edge.to.name }
        console.log(edge.from)
        console.log(to)
        var edg = { from: from.id, to: to.id, label: "" }
        operators_cache[edge.from.pid] = edge.from;
        operators_cache[edge.to.pid] = edge.to;
        nodes.update(from);
        nodes.update(to);
        edges.update(edg);

    });
}

function addStreamButton(stream_id) {
    var streams = document.getElementById("streamlist");
    var btn = document.createElement("button");
    btn.setAttribute("type", "button");
    btn.setAttribute("class", "streambtn btn btn-primary");
    btn.onclick = streamClick;
    btn.innerHTML = `Stream ${stream_id}`;
    streams.appendChild(btn);
}
let socket = new WebSocket("ws://localhost:4000/ws");

socket.onopen = function (e) {
    socketOn();
};

socket.onmessage = function (event) {
    var payload = JSON.parse(event.data);
    handleServerEvent(payload);
};

socket.onclose = function (event) {
    socketOff();
    if (event.wasClean) {
        console.log(`Connection closed cleanly, code=${event.code} reason=${event.reason}`);
    } else {
        console.log('Connection died abruptly!');
    }
};

socket.onerror = function (error) {
    socketOff();
    alert(`Socket error ${error.message}`);
};


function handleServerEvent(event) {
    if (event.message == "streamlist") {
        nodes.clear();
        edges.clear();

        stream_cache = event.streams;
        for (const key in event.streams) {
            addStreamButton(key);
        }
    }

    if (event.message == "new_stream") {
        stream_cache[event.id] = event.stream;
        addStreamButton(event.id);
    }

    if (event.message == "incoming") {
        if (current_stream_id == null) {
            return;
        }
        // Check if this event pertains to the current stream.
        var current_stream = stream_cache[current_stream_id];
        var found = null;
        for (let i = 0; i < current_stream.length; i++) {
            var edge = current_stream[i]
            if (edge.from.pid == event.pid) {
                found = edge.from;
            }
            if (edge.to.pid == event.pid) {
                found = edge.to;
            }
        }

        nodeEmitted(found.pid, event.value);

        

    }

    // if (event.message == "stream_details") {
    //     nodes.clear();
    //     edges.clear();

    //     event.stream.operators.forEach(operator => {
    //         var op = { id: operator.ref, label: operator.type }
    //         nodes.add(op)
    //     });

    //     event.stream.edges.forEach(edge => {
    //         console.log(edge)
    //         var e = { from: edge.from, to: edge.to, label: "" }
    //         edges.add(e);
    //     })
    // }
}