extern crate graph_match;
extern crate hyper;
extern crate rustc_serialize;

mod core_nlp;
mod graph_parser;

fn main() {
    let text = "the man ran home.".to_string();
    let string_graphs = match core_nlp::graphs_for_text(&text) {
        Ok(graphs) => graphs,
        Err(message) => panic!("There was an error in building the graph string representation ({})", message),
    };

    let query_string = "type:node identifier:subj pos:NN\n\
                        type:node identifier:verb pos:VBD\n\
                        type:node identifier:obj pos:NN\n\
                        type:edge identifier:edge0 source:1 target:0 label:nsubj\n\
                        type:edge identifier:edge1 source:1 target:2 label:dobj";
    let query = graph_parser::parse(&query_string.to_string()).unwrap();

    for g in string_graphs {
        println!("{}", g);
        let graph = match graph_parser::parse(&g) {
            Ok(g) => g,
            Err(message) => {
                println!("The following graph: {}, failed with the following message: {}", g, message);
                continue;
            }
        };
        println!("{:?}", graph_match::match_graph(&query, 1, &graph));
    }
}
