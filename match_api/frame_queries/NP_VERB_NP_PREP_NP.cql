MATCH (verb:Node {uuid: 'VERB_UUID'})
MATCH (verb)-[rel_subj:REL]->(subj:Node)
MATCH (verb)-[rel_obj:REL]->(obj:Node)
MATCH (verb)-[rel_np3:REL]->(np3:Node)
MATCH (np3)-[rel_prep:REL]->(prep:Node)
WHERE rel_subj.label = "nsubj"
AND rel_obj.label = "dobj"
AND rel_np3.label =~ 'nmod.*'
AND rel_prep.label = "case"
RETURN subj, verb, obj, prep, np3;
