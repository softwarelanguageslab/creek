import './style.css';

// create an array with nodes
var nodes = new vis.DataSet([
    { id: 1, label: "Node 1" },
    { id: 2, label: "Node 2" },
]); 
 
// create an array with edges
var edges = new vis.DataSet([
    { from: 1, to: 2, label: "middle", font: { align: "middle" } },
]);

// create a network
var container = document.getElementById("mynetwork");
var data = {
    nodes: nodes,
    edges: edges,
};

var options = { physics: false };
var network = new vis.Network(container, data, options);

network.on("click", function (params) {
    var clicked_node_id = params.nodes[0];
    console.log(`Clicked on node ${clicked_node_id}`)
   
});

