MATCH (verb:Node {uuid: 'VERB_UUID'})
MATCH (verb)-[rel_subj:REL]->(subj:Node)
MATCH (verb)-[rel_nmod:REL]->(nmod:Node)
MATCH (nmod)-[rel_prep:REL]->(prep:Node)
MATCH (nmod)-[rel_obj:REL]->(obj:Node)

WHERE rel_subj.label = "nsubj"
AND rel_obj.label = "appos"
AND rel_nmod.label =~ 'nmod.*'
AND rel_prep.label = "case"

RETURN subj, verb, prep, nmod, obj;
