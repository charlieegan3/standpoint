use std::collections::HashMap;
use graph_match::graph::Graph;
use graph_parser;

pub fn frame_index() -> HashMap<String, (usize, Graph)> {
    let mut index: HashMap<String, (usize, Graph)> = HashMap::new();
    let frames = vec![
        np_v_np()
    ];

    for frame in frames {
        index.insert(frame.0, (frame.1, frame.2));
    }
    return index;
}

fn np_v_np() -> (String, usize, Graph) {
    let query_string = "type:node identifier:subj\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:obj\n\
                        type:edge identifier:subj source:1 target:0 label:nsubj\n\
                        type:edge identifier:obj source:1 target:2 label:dobj";
    return (String::from("NP VERB NP"), 1, graph_parser::parse(&query_string.to_string()).unwrap());
}
