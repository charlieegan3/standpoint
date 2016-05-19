extern crate graph_match;
mod graph_parser;

fn main() {
    let string_graph =
        "type:node identifier:node0 pos:noun word:charlie\n\
         type:node identifier:node1 pos:verb word:went\n\
         type:node identifier:node2 pos:noun word:home\n\
         type:node identifier:node3 pos:det word:the\n\
         type:edge identifier:subj source:1 target:0 key:value\n\
         type:edge identifier:obj source:1 target:2 key:value\n\
         type:edge identifier:det source:0 target:3 key:value";
    let mut graph: graph_match::graph::Graph;
    match graph_parser::parse(string_graph.to_string()) {
        Ok(g) => graph = g,
        Err(message) => panic!(message),
    }

    let query_string =
        "type:node identifier:node0 pos:noun\n\
         type:node identifier:node1 pos:verb\n\
         type:node identifier:node2 pos:noun\n\
         type:edge identifier:subj source:1 target:0\n\
         type:edge identifier:obj source:1 target:2";
    let query = graph_parser::parse(query_string.to_string());

    for component in graph_match::match_graph(&query.unwrap(), 1, &graph).list {
        match graph.nodes[component.node].attributes {
            Some(ref attrs) => println!("{:?}", attrs),
            None => println!("There were no attrs"),
        }
    }
    println!("---");
    for index in graph_match::expand_subgraph(&graph, 1, &vec![]) {
        match graph.nodes[index].attributes {
            Some(ref attrs) => println!("{:?}", attrs),
            None => println!("There were no attrs"),
        }
    }
}
