extern crate graph_match;
extern crate hyper;
extern crate rustc_serialize;

#[macro_use]
mod macros;
mod core_nlp;
mod graph_parser;
mod points;
mod frames;
mod verbs;

use graph_match::matching::EqualityRequirement;

fn main() {
    let frames = frames::frame_index();
    let verbs = verbs::verb_index();
    let banned_edges: Vec<String> = vec![String::from("advcl"), String::from("csubj"), String::from("ccomp"), String::from("dep"), String::from("parataxis")];

    let text = "The man ran home, he eat his food. He climbed the stairs.".to_string();
    let string_graphs = match core_nlp::graphs_for_text(&text) {
        Ok(graphs) => graphs,
        Err(message) => panic!("There was an error in building the graph string ({})", message),
    };

    for g in string_graphs {
        let graph = match graph_parser::parse(&g) {
            Ok(g) => g,
            Err(message) => {
                println!("The following graph:\n\n{}\n\nfailed with the following message: {}", g, message);
                continue;
            }
        };

        let verb_indices = match points::find_verbs(&graph) {
            Some(indices) => indices,
            None => {
                println!("There were no verbs.");
                continue;
            }
        };

        let queries = match points::build_queries(&verb_indices, &graph, &verbs, &frames) {
            Some(queries) => queries,
            None => {
                println!("No queries could be generated.");
                continue;
            }
        };

        for query in queries {
            match frames.get(&query.1) {
                Some(frame) => {
                    println!("Pattern: {}", query.1);
                    for matched_components in graph_match::match_graph(&frame.1, frame.0, &graph, Some(query.0), &EqualityRequirement::Contains) {
                        println!("{:?}", points::matched_components_to_pattern(&matched_components, &graph));
                        let root_node_index = matched_components.list[0].node;
                        let node_indexes = graph_match::expand_subgraph(&graph, root_node_index, &banned_edges);
                        println!("{:?}", points::subgraph_nodes_to_extract_string(&node_indexes, &graph));
                    }
                },
                None => println!("Previously matched frame now missing."),
            }
        }
        print!("\n");
    }
}
