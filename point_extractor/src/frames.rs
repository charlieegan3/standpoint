use std::collections::HashMap;
use graph_match::graph::Graph;
use graph_parser;

pub fn frame_index() -> HashMap<String, (usize, Graph)> {
    let mut index: HashMap<String, (usize, Graph)> = HashMap::new();
    let frames = vec![
        np_v(),
        np_v_np(),
        np_v_np_prep_np(),
        np_v_np_np(),
        np_v_np_lex(),
        np_v_np_prep_np_prep_np(),
        np_v_np_lex_np(),
        np_v_prep_np(),
        np_v_prep_np_np(),
        np_v_prep_np_prep_np(),
        np_v_adv(),
        np_v_adv_lex(),
        np_v_adv_prep_np(),
        lex_v_np_prep_np(),
        lex_v_prep_np_np(),
        prep_np_v_np(),

        copula_np_v_adj(),
        copula_np_v_np(),

        generic_obj(),
        generic_xcomp(),
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

fn np_v_np_lex() -> (String, usize, Graph) {
    let query_string = "type:node identifier:subj\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:obj\n\
                        type:node identifier:lex\n\
                        type:edge identifier:subj source:1 target:0 label:nsubj\n\
                        type:edge identifier:obj source:1 target:2 label:dobj\n\
                        type:edge identifier:advmod source:1 target:3 label:advmod";
    return (String::from("NP VERB NP"), 1, graph_parser::parse(&query_string.to_string()).unwrap());
}

fn np_v() -> (String, usize, Graph) {
    let query_string = "type:node identifier:subj\n\
                        type:node identifier:verb pos:VB\n\
                        type:edge identifier:obj source:1 target:0 label:nsubj";
    return (String::from("NP VERB"), 1, graph_parser::parse(&query_string.to_string()).unwrap());
}

// not currently implementable, requires fuzzy list of edge matching
// fn np_v_lex() {
// }

fn np_v_adv() -> (String, usize, Graph) {
    let query_string = "type:node identifier:subj\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:adv\n\
                        type:edge identifier:subj source:1 target:0 label:nsubj\n\
                        type:edge identifier:advmod source:1 target:2 label:advmod";
    return (String::from("NP VERB ADV"), 1, graph_parser::parse(&query_string.to_string()).unwrap());
}

fn np_v_np_np() -> (String, usize, Graph) {
    let query_string = "type:node identifier:subj\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:dobj\n\
                        type:node identifier:xcomp\n\
                        type:edge identifier:subj source:1 target:0 label:nsubj\n\
                        type:edge identifier:obj source:1 target:2 label:nmod\n\
                        type:edge identifier:xcomp source:1 target:3 label:xcomp";
    return (String::from("NP VERB NP NP"), 1, graph_parser::parse(&query_string.to_string()).unwrap());
}

fn np_v_prep_np() -> (String, usize, Graph) {
    let query_string = "type:node identifier:subj\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:obj\n\
                        type:node identifier:prep\n\
                        type:edge identifier:subj source:1 target:0 label:nsubj\n\
                        type:edge identifier:obj source:1 target:2 label:nmod\n\
                        type:edge identifier:case source:2 target:3 label:case";
    return (String::from("NP VERB PREP NP"), 1, graph_parser::parse(&query_string.to_string()).unwrap());
}

fn np_v_prep_np_np() -> (String, usize, Graph) {
    let query_string = "type:node identifier:subj\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:obj\n\
                        type:node identifier:prep\n\
                        type:node identifier:nmod\n\
                        type:edge identifier:subj source:1 target:0 label:nsubj\n\
                        type:edge identifier:nmod source:1 target:4 label:nmod\n\
                        type:edge identifier:obj source:4 target:2 label:appos\n\
                        type:edge identifier:case source:4 target:3 label:case";
    return (String::from("NP VERB PREP NP NP"), 1, graph_parser::parse(&query_string.to_string()).unwrap());
}

fn np_v_np_prep_np() -> (String, usize, Graph) {
    let query_string = "type:node identifier:subj\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:obj\n\
                        type:node identifier:prep\n\
                        type:node identifier:np3\n\
                        type:edge identifier:subj source:1 target:0 label:nsubj\n\
                        type:edge identifier:obj source:1 target:2 label:dobj\n\
                        type:edge identifier:nmod source:1 target:4 label:nmod\n\
                        type:edge identifier:case source:4 target:3 label:case";
    return (String::from("NP VERB NP PREP NP"), 1, graph_parser::parse(&query_string.to_string()).unwrap());
}

fn np_v_np_prep_np_prep_np() -> (String, usize, Graph) {
    let query_string = "type:node identifier:subj\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:obj\n\
                        type:node identifier:nmod1\n\
                        type:node identifier:nmod2\n\
                        type:node identifier:prep1\n\
                        type:node identifier:prep2\n\
                        type:edge identifier:subj source:1 target:0 label:nsubj\n\
                        type:edge identifier:obj source:1 target:2 label:dobj\n\
                        type:edge identifier:nmod1 source:1 target:3 label:nmod\n\
                        type:edge identifier:nmod2 source:1 target:4 label:nmod\n\
                        type:edge identifier:case1 source:3 target:5 label:case\n\
                        type:edge identifier:case1 source:4 target:6 label:case";
    return (String::from("NP VERB NP PREP NP PREP NP"), 1, graph_parser::parse(&query_string.to_string()).unwrap());
}

// this used a blacklisted relation, advcl, that is not permitted in extract creation
fn np_v_np_lex_np() -> (String, usize, Graph) {
    let query_string = "type:node identifier:subj\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:obj\n\
                        type:node identifier:lex\n\
                        type:node identifier:np2\n\
                        type:edge identifier:subj source:1 target:0 label:nsubj\n\
                        type:edge identifier:obj source:1 target:2 label:dobj\n\
                        type:edge identifier:nmod source:1 target:4 label:advcl\n\
                        type:edge identifier:mark source:4 target:3 label:mark";
    return (String::from("NP VERB NP PREP NP"), 1, graph_parser::parse(&query_string.to_string()).unwrap());
}

// this requires a more fuzzy match on clausal relations that are assumed not to exist elsewhere
fn np_v_prep_np_prep_np() -> (String, usize, Graph) {
    let query_string = "type:node identifier:subj\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:nmod\n\
                        type:node identifier:prep\n\
                        type:node identifier:verb2 pos:VB\n\
                        type:node identifier:prep2\n\
                        type:edge identifier:subj source:1 target:0 label:nsubj\n\
                        type:edge identifier:nmod source:1 target:2 label:nmod\n\
                        type:edge identifier:case source:2 target:3 label:case\n\
                        type:edge identifier:advcl source:4 target:1 label:advcl\n\
                        type:edge identifier:case source:4 target:5 label:case";
    return (String::from("NP VERB PREP NP PREP NP"), 1, graph_parser::parse(&query_string.to_string()).unwrap());
}

fn np_v_adv_prep_np() -> (String, usize, Graph) {
    let query_string = "type:node identifier:subj\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:adv\n\
                        type:node identifier:nmod\n\
                        type:node identifier:prep\n\
                        type:edge identifier:subj source:1 target:0 label:nsubj\n\
                        type:edge identifier:advmod source:1 target:2 label:advmod\n\
                        type:edge identifier:nmod source:1 target:3 label:nmod\n\
                        type:edge identifier:case source:3 target:4 label:case";
    return (String::from("NP VERB ADV PREP NP"), 1, graph_parser::parse(&query_string.to_string()).unwrap());
}

// lex should be before adv
fn np_v_adv_lex() -> (String, usize, Graph) {
    let query_string = "type:node identifier:subj\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:dobj\n\
                        type:node identifier:adv\n\
                        type:node identifier:lex\n\
                        type:edge identifier:subj source:1 target:0 label:nsubj\n\
                        type:edge identifier:obj source:1 target:2 label:dobj\n\
                        type:edge identifier:adv source:1 target:3 label:advmod\n\
                        type:edge identifier:lex source:1 target:4 label:advmod";
    return (String::from("NP VERB ADV LEX"), 1, graph_parser::parse(&query_string.to_string()).unwrap());
}

fn prep_np_v_np() -> (String, usize, Graph) {
    let query_string = "type:node identifier:prep\n\
                        type:node identifier:subj\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:obj\n\
                        type:edge identifier:nmod source:2 target:1 label:nmod\n\
                        type:edge identifier:obj source:2 target:3 label:dobj\n\
                        type:edge identifier:case source:1 target:0 label:case";
    return (String::from("PREP NP VERB NP"), 2, graph_parser::parse(&query_string.to_string()).unwrap());
}

fn lex_v_np_prep_np() -> (String, usize, Graph) {
    let query_string = "type:node identifier:lex\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:obj\n\
                        type:node identifier:prep\n\
                        type:node identifier:nmod\n\
                        type:edge identifier:expl source:1 target:0 label:expl\n\
                        type:edge identifier:dobj source:1 target:2 label:dobj\n\
                        type:edge identifier:nmod source:1 target:3 label:nmod\n\
                        type:edge identifier:case source:3 target:4 label:case";
    return (String::from("LEX VERB NP PREP NP"), 1, graph_parser::parse(&query_string.to_string()).unwrap());
}

// uses generic dependency, this should not expand.
fn lex_v_prep_np_np() -> (String, usize, Graph) {
    let query_string = "type:node identifier:lex\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:nmod\n\
                        type:node identifier:prep\n\
                        type:node identifier:dep\n\
                        type:edge identifier:expl source:1 target:0 label:expl\n\
                        type:edge identifier:nmod source:1 target:2 label:nmod\n\
                        type:edge identifier:case source:2 target:3 label:case\n\
                        type:edge identifier:dep source:2 target:4 label:dep";
    return (String::from("LEX VERB PREP NP NP"), 1, graph_parser::parse(&query_string.to_string()).unwrap());
}

// copula frames
fn copula_np_v_adj() -> (String, usize, Graph) {
    let query_string = "type:node identifier:subj\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:adj pos:JJ\n\
                        type:edge identifier:cop source:2 target:1 label:cop\n\
                        type:edge identifier:subj source:2 target:0 label:nsubj";
    return (String::from("copula:NP VERB ADJ"), 2, graph_parser::parse(&query_string.to_string()).unwrap());
}

fn copula_np_v_np() -> (String, usize, Graph) {
    let query_string = "type:node identifier:subj\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:dobj pos:NN\n\
                        type:edge identifier:cop source:2 target:1 label:cop\n\
                        type:edge identifier:subj source:2 target:0 label:nsubj";
    return (String::from("copula:NP VERB NP"), 2, graph_parser::parse(&query_string.to_string()).unwrap());
}

fn generic_obj() -> (String, usize, Graph) {
    let query_string = "type:node identifier:subj\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:obj\n\
                        type:edge identifier:subj source:1 target:0 label:nsubj\n\
                        type:edge identifier:obj source:1 target:2 label:dobj";
    return (String::from("generic:OBJ"), 1, graph_parser::parse(&query_string.to_string()).unwrap());
}

fn generic_xcomp() -> (String, usize, Graph) {
    let query_string = "type:node identifier:subj\n\
                        type:node identifier:verb pos:VB\n\
                        type:node identifier:xcomp\n\
                        type:edge identifier:subj source:1 target:0 label:nsubj\n\
                        type:edge identifier:xcomp source:1 target:2 label:xcomp";
    return (String::from("generic:XCOMP"), 1, graph_parser::parse(&query_string.to_string()).unwrap());
}
