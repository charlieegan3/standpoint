extern crate graph_match;
extern crate hyper;
extern crate rustc_serialize;

mod core_nlp;
mod graph_parser;

use graph_match::matching::EqualityRequirement;


fn main() {

    let text = "The man ran home, the man eat the food.".to_string();
    let string_graphs = match core_nlp::graphs_for_text(&text) {
        Ok(graphs) => graphs,
        Err(message) => panic!("There was an error in building the graph string representation ({})", message),
    };

    let query_string = "type:node identifier:subj pos:NN\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:obj pos:NN\n\
                        type:edge identifier:edge0 source:1 target:0 label:nsubj\n\
                        type:edge identifier:edge1 source:1 target:2 label:dobj";
    let query = graph_parser::parse(&query_string.to_string()).unwrap();

    for g in string_graphs {
        println!("Graph:\n{}", g);
        let graph = match graph_parser::parse(&g) {
            Ok(g) => g,
            Err(message) => {
                println!("The following graph: {}, failed with the following message: {}", g, message);
                continue;
            }
        };

        let banned_edges: Vec<String> = vec!["advcl".to_string(), "csubj".to_string(), "ccomp".to_string(), "dep".to_string(), "parataxis".to_string()];
        println!("Points");
        for matched_components in graph_match::match_graph(&query, 1, &graph, &EqualityRequirement::Contains) {
            println!("{:?}", matched_components.list);
            let root_node_index = matched_components.list[0].node;
            println!("{:?}", graph_match::expand_subgraph(&graph, root_node_index, &banned_edges));
        }
    }
}
