//NP VERB NP PREP NP

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_nsubj:REL]->(nsubj:Node)
MATCH (verb)-[rel_dobj:REL]->(dobj:Node)
MATCH (verb)-[rel_np3:REL]->(np3:Node)
MATCH (np3)-[rel_prep:REL]->(prep:Node)
WHERE rel_nsubj.label = "nsubj"
AND rel_dobj.label = "dobj"
AND rel_np3.label =~ 'nmod.*'
AND rel_prep.label = "case"
RETURN nsubj, verb, dobj, prep, np3;
