MATCH (verb:Node {uuid: 'VERB_UUID'})
MATCH (verb)-[rel_subj:REL]->(subj:Node)
MATCH (verb)-[rel_obj:REL]->(obj:Node)
MATCH (verb)-[rel_xcomp:REL]->(xcomp:Node)
WHERE rel_subj.label = "nsubj"
AND rel_obj.label = "dobj"
AND rel_xcomp.label = "xcomp"
RETURN subj, verb, obj, xcomp;
