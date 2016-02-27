//PREP NP VERB NP

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_nmod:REL]->(nmod:Node)
MATCH (nmod)-[rel_prep:REL]->(prep:Node)
MATCH (verb)-[rel_dobj:REL]->(dobj:Node)
WHERE rel_nmod.label =~ 'nmod:.*'
AND rel_dobj.label = "dobj"
AND rel_prep.label = "case"
RETURN prep, nmod, verb, dobj;
