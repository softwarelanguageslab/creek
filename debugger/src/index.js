import './style.css';

var current_stream_id = null;

var editor = CodeMirror.fromTextArea(document.getElementById('editor'), {
    mode: "ruby",
    lineNumbers: true,
});
editor.save()

var streams = [];
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

function updateSelectedNode() {
    console.log(`Clicked on node ${selected_node}`);
    
    
    var node = nodes.get(selected_node);
    var node_id = node.id;
    var node_label = node.label;
    document.getElementById("node_id").textContent = node_id;
    document.getElementById("node_label").textContent = node_label;

    editor.doc.setValue("# " + node_label);

    document.getElementById("node_data").style.display = "flex";
    document.getElementById("edge_data").style.display = "none";

    socket.send(JSON.stringify({ "node_details": node_id, "stream": null }))
};
function updateSelectedEdge() {
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
        updateSelectedNode();
        return;
    }
    if (params.edges != null && params.edges.length > 0) {
        selected_edge = params.edges[0];
        updateSelectedEdge();
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

function requestStreamData(stream_id) {
    var message = {"message": "stream_details", "stream_id": stream_id};
    socket.send(JSON.stringify(message))
}

function streamClick(event) {
    var streamid = event.target.innerHTML.substring(7)
    current_stream_id = streamid;
    socket.send(JSON.stringify({"message": "stream_details", "stream_id": streamid}));
}
function addStream(stream) {
    var streams = document.getElementById("streamlist");
    var btn = document.createElement("button");
    btn.setAttribute("type", "button");
    btn.setAttribute("class", "streambtn btn btn-primary");
    btn.onclick = streamClick;
    btn.innerHTML = `Stream ${stream.id}`;
    streams.appendChild(btn);
}
let socket = new WebSocket("ws://localhost:4000/ws");

socket.onopen = function (e) {
    socketOn();
    // socket.send(JSON.stringify({ "message": "hello" }));
};

socket.onmessage = function (event) {
    console.log(event);
    var payload = JSON.parse(event.data);
    handleServerEvent(payload);
};

socket.onclose = function (event) {
    socketOff();
    if (event.wasClean) {
        console.log(`[close] Connection closed cleanly, code=${event.code} reason=${event.reason}`);
    } else {
        // e.g. server process killed or network down
        // event.code is usually 1006 in this case
        console.log('[close] Connection died');
    }
};

socket.onerror = function (error) {
    socketOff();
    alert(`[error] ${error.message}`);
};


function handleServerEvent(event) {
    if (event.message == "streamlist") {
        event.streams.forEach(stream => {
            addStream(stream);
        });
    }
    if (event.message == "stream_details") {
        nodes.clear();
        edges.clear();

        event.stream.operators.forEach(operator => {
            var op = {id: operator.ref, label: operator.type}
            nodes.add(op)
        });

        event.stream.edges.forEach(edge => 
            {
                console.log(edge)
                var e = {from: edge.from, to: edge.to, label: ""}
                edges.add(e);
            })
    }
}