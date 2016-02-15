//NP VERB NP
MATCH (verb:Node {uuid: 'VERB_UUID'})
MATCH (verb)-[rel_subj:REL]->(subj:Node)
MATCH (verb)-[rel_obj:REL]->(obj:Node)
WHERE rel_subj.label = "nsubj"
AND rel_obj.label = "dobj"
RETURN subj, verb, obj;
