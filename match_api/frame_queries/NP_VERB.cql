MATCH (verb:Node {uuid: 'VERB_UUID'})
MATCH (verb)-[rel_subj:REL]->(subj:Node)
WHERE rel_subj.label = "nsubj"
RETURN subj, verb;
