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
var current_node_id = null;


document.addEventListener('readystatechange', () => {
    if (document.readyState == 'complete') {
        // Attach event handler to button
        const btn = document.querySelector('#updateArgButton');
        btn.addEventListener('click', handler);
    }
});


// create an array with nodes
// var nodes = new vis.DataSet([
//     { id: 1, label: "Node 1" },
//     { id: 2, label: "Node 2" },
//     { id: 3, label: "Node 3" },
// ]);
var nodes = new vis.DataSet([]);

var emissions = {};
var receives = {};

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

var options = {
    layout: {
        hierarchical: {
            direction: "UD",
            sortMethod: "directed",
        },
    },
    edges: {
        arrows: "to",
    },
    nodes: {
        borderWidth: 15,
        borderWidthSelected: 15,
        brokenImage: undefined,
        chosen: false,
        color: {
            border: '#2B7CE9',
            background: '#2B7CE9',
            highlight: {
                border: '#2B7CE9',
                background: '#2B7CE9'
            },
            hover: {
                border: '#2B7CE9',
                background: '#2B7CE9'
            }
        }
    }
};
var network = new vis.Network(container, data, options);

var selected_node = null;
var selected_edge = null;

function updateNodeDetails() {
    if (selected_node == null) {
        return;
    }
    var node = nodes.get(selected_node);
    var node_id = node.id;
    current_node_id = node_id;
    var node_label = node.label;

    console.log(operators_cache);
    var operator = operators_cache[node_id];
    document.getElementById("node_id").textContent = node_id;
    document.getElementById("node_name").textContent = operator.name;
    document.getElementById("node_pid").textContent = operator.pid;
    document.getElementById("node_arity").textContent = `${operator.in}:${operator.out}`;

    if (operator.hasOwnProperty('state')) {
        editor.doc.setValue(operator.state);
    }
    else {
        editor.doc.setValue("n/a");

    }
    editor2.doc.setValue(operator.arg);

    document.getElementById("in").innerHTML = '';
    document.getElementById("out").innerHTML = '';

    if (emissions.hasOwnProperty(node_id)) {
        emissions[node_id].forEach(emission => {
            addEmissionOut(emission);
        })
    }

    if (receives.hasOwnProperty(node_id)) {
        receives[node_id].forEach(emission => {
            addEmissionIn(emission);
        })
    }



    document.getElementById("node_data").style.display = "flex";
    document.getElementById("node_data2").style.display = "flex";
    document.getElementById("history").style.display = "flex";
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
    document.getElementById("node_data2").style.display = "none";
    document.getElementById("edge_data").style.display = "none";
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

function completeNode(pid) {
    for (const stream_id in stream_cache) {
        var stream = stream_cache[stream_id];

        for (var i = 0; i < stream.length; i++) {
            var edge = stream[i];
            if (edge.from.pid == pid) {
                edge.from.status = "complete";
            }
            if (edge.to.pid == pid) {
                edge.to.status = "complete";
            }
        }
    }

    // rerender details..
    if (selected_node == pid) {
        updateNodeDetails();
    }
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


function rebuildOpratorCache() {
    if (current_stream_id == null) {
        operators_cache = {};
    }
    else {
        var streamid = current_stream_id;
        var stream = stream_cache[streamid];

        operators_cache = {};
        nodes.clear();
        edges.clear();

        stream.forEach(edge => {
            var from = { id: edge.from.pid, label: edge.from.name }
            var to = { id: edge.to.pid, label: edge.to.name }
            var edg = { from: from.id, to: to.id, label: "" }
            operators_cache[edge.from.pid] = edge.from;
            operators_cache[edge.to.pid] = edge.to;

            if (edge.from.hasOwnProperty("status")) {
                console.log("completed found!")
                if (edge.from.status === "complete") {
                    console.log("completed node!")
                    from.color = {
                        border: 'green',
                        background: 'green',
                        highlight: {
                            border: 'green',
                            background: 'green'
                        }
                    };
                }
            }

            if (edge.to.hasOwnProperty("status")) {
                console.log("completed found!")
                if (edge.to.status === "complete") {
                    console.log("completed node!")
                    to.color = {
                        border: 'green',
                        background: 'green',
                        highlight: {
                            border: 'green',
                            background: 'green'
                        }
                    };
                }
            }
            nodes.update(from);
            nodes.update(to);
            edges.update(edg);
        });
    }
}
function streamClick(event) {
    var streamid = event.target.innerHTML.substring(7);
    // var stream = stream_cache[streamid];
    current_stream_id = streamid;
    rebuildOpratorCache();
    network.setOptions(options);

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

function addEmissionOut(value) {
    var btn = document.createElement("li");
    btn.innerHTML = `${value.value}`;
    document.getElementById('out').appendChild(btn);
}
function addEmissionIn(value) {
    var btn = document.createElement("li");
    var valstr = "" + value.value;
    btn.innerHTML = `${value.time.toLocaleTimeString()} :: ${valstr.padEnd(8, "&nbsp; ")}&nbsp;->&nbsp;`;
    document.getElementById('in').appendChild(btn);
}
let socket = new WebSocket("ws://localhost:4000/ws");

// Define an event handler function
const handler = (e) => {

    console.log(current_node_id)
    if(current_node_id != null) {
        var m = {"message": "update_arg", "arg": editor.getValue(), "for": current_node_id};
        console.log(editor.getValue())
        socket.send(JSON.stringify(m));
    }
};


socket.onopen = function (e) {
    socketOn();
};

socket.onmessage = function (event) {
    socketOn();
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

function nodeForPid(pid) {
    if (current_stream_id == null) {
        return null;
    }

    var current_stream = stream_cache[current_stream_id];
    var found = null;
    for (let i = 0; i < current_stream.length; i++) {
        var edge = current_stream[i]
        if (edge.from.pid == pid) {
            found = edge.from;
            return found;
        }
        if (edge.to.pid == pid) {
            found = edge.to;
            return found;
        }
    }
    return null;
}

function outgoingEdges(pid) {
    var outEdges = [];
    edges.forEach(edge => {
        if (edge.from == pid) {
            outEdges.push(edge);
        }
    });
    return outEdges;
}

function updateNodeState(pid, state) {
    for (const stream_id in stream_cache) {
        var stream = stream_cache[stream_id];

        for (var i = 0; i < stream.length; i++) {
            var edge = stream[i];
            if (edge.from.pid == pid) {
                edge.from.state = state;
            }
            if (edge.to.pid == pid) {
                edge.to.state = state;
            }
        }
    }

    // rerender details..
    if (selected_node == pid) {
        updateNodeDetails();
    }


}
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


    if (event.message == "outgoing") {
        updateNodeState(event.pid, event.state);
        var node = nodeForPid(event.pid);

        if (emissions.hasOwnProperty(event.pid)) {
            emissions[event.pid].push({ 'value': event.value, 'time': new Date() });
        }
        else {
            emissions[event.pid] = [{ 'value': event.value, 'time': new Date() }];
        }


        updateNodeDetails();

        if (node != null) {
            var outEdges = outgoingEdges(event.pid);
            outEdges.forEach(edge => {
                setLabelEdge(edge.id, event.value);
            });

        }
        else {
            console.log("Node not part of current stream.")
        }

        // nodeEmitted(found.pid, event.value);
    }


    if (event.message == "incoming") {
        // updateNodeState(event.pid, event.state);
        if (receives.hasOwnProperty(event.pid)) {
            receives[event.pid].push({ 'value': event.value, 'time': new Date() });
        }
        else {
            receives[event.pid] = [{ 'value': event.value, 'time': new Date() }];
        }

        updateNodeDetails();
    }


    if (event.message == "update") {
        console.log(event);
        updateNodeState(event.pid, event.state);
        updateNodeDetails();
    }


    if (event.message == "complete") {
        console.log(event);
        completeNode(event.pid);
        rebuildOpratorCache();
        updateNodeDetails();
    }
}