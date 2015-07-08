d3sparql.tree = function(json, config) {
  console.log(json);
  if (d3sparql.dtree) { console.log(json.name) };
  if (d3sparql.dtree) { console.log(config) };
  if (d3sparql.dtree) { var head = json.name; } //json.head.vars //Probably have to redo data getting for our FlareJSON
  if (d3sparql.dtree) { var data = json.children; } //json.results.bindings
  if (d3sparql.dtreeBefore) { var head = json.head.vars; }
	if (d3sparql.dtreeBefore) { var data = json.results.bindings; }
  console.log(head);
  console.log(data);
  //console.log('DATA:'+data);

  if (d3sparql.dtree) {
    //Gets name string into an array of just the spo
    head = head.replace(/\s+/g, ''); //Remove spaces from name property
    head = head.split(','); //Separates between commas into an array
    if (d3sparql.dtree) {  //Test case
      for(var val in head) {
        console.log(val+':'+head[val]);
      }
    }
  }

  var opts = {
    "root":   config.root   || head[0],
    "parent": config.parent || head[1],
    "child":  config.child  || head[2],
    "value":  config.value  || head[3] || "value",
  }
  console.log(opts);
  console.log(opts.root);
  console.log(typeof(data));
  console.log(typeof(opts.root));
  console.log(opts.parent);
  console.log(opts.child);
  console.log(opts.value);
  if (d3sparql.dtree) { console.log(data[0]) }
  if (d3sparql.dtree) { console.log(data[0].name) }

  //if (d3sparql.dtree) { console.log(data[0][opts.root].value); }
  //if (d3sparql.dtree) { console.log(data[0][opts.parent].value); }
  //if (d3sparql.dtree) { console.log(data[0][opts.child].value); }

  var pair = d3.map()
  var size = d3.map()
  var root = opts.root+', '+opts.parent+', '+opts.child;	//From here on trying to have query as root and all the rest as children	//data[0][opts.root].value
  console.log(root);
  var parent = child = children = true
  console.log(parent);
  console.log(opts.value);
  //console((data.length).toString())
  for (var i = 0; i < data.length; i++) {
    parent = data[i].name; //data[i][opts.parent].value
    child = data[i].children[0].name;  //data[i][opts.child].value
    console.log(parent+' ||| '+child)
    if (parent != child) {
      if (pair.has(parent)) {
        children = pair.get(parent)
        children.push(child)
        pair.set(parent, children)
        if (data[i][opts.value]) {
          //size.set(child, data[i][opts.value].value)
          size.set(child, 5);
        }
      } else {
        children = [child]
        pair.set(parent, children)
        if (data[i][opts.value]) {
          //size.set(child, data[i][opts.value].value)
          size.set(child, 5);
        }
      }
    }
  }
  console.log(pair[0]);
  var pa = [pair];//[0]];
  //pair.set(root, pa);//[0]);
    console.log("PAIR");
    console.log(pa[0]);
    //console.log(pa[0][0]);
    console.log(pair);
    console.log(pair[0]);
    console.log("SIZE");
    console.log(size);

  function traverse(node) {
    var list = pair.get(node)
    console.log(list);
    if (list) {
      var children = list.map(function(d) {return traverse(d)})
      // sum of values of children
      var subtotal = d3.sum(children, function(d) {return d.value})
      // add a value of parent if exists
      var total = d3.sum([subtotal, size.get(node)])
      return {"name": node, "children": children, "value": total}
    } else {
      return {"name": node, "value": size.get(node) || 1}
    }
  }
  console.log(root);
  var tree = traverse(root);

  //if (d3sparql.debug) { console.log(JSON.stringify(tree)) }
  if (d3sparql.dtree) { console.log(tree); }
  return tree
}
