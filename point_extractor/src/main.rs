extern crate graph_match;
extern crate hyper;
extern crate rustc_serialize;

mod core_nlp;

fn main() {
    let text = "This is a sentence".to_string();
    match core_nlp::graphs_for_text(&text) {
        Ok(graphs) => {
            for g in graphs {
                println!("{}", g);
            }
        },
        Err(message) => println!("There was an error in building the graph string representation ({})", message),
    }
}
