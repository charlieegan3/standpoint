//PREP NP VERB NP

MATCH (verb:Node {uuid: 'VERB_UUID'})
MATCH (verb)-[rel_nmod:REL]->(nmod:Node)
MATCH (nmod)-[rel_prep:REL]->(prep:Node)
MATCH (verb)-[rel_obj:REL]->(obj:Node)
WHERE rel_nmod.label =~ 'nmod:.*'
AND rel_obj.label = "dobj"
AND rel_prep.label = "case"
RETURN prep, nmod, verb, obj;
