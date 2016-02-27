//NP VERB NP NP

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_nsubj:REL]->(nsubj:Node)
MATCH (verb)-[rel_dobj:REL]->(dobj:Node)
MATCH (verb)-[rel_xcomp:REL]->(xcomp:Node)
WHERE rel_nsubj.label = "nsubj"
AND rel_dobj.label = "dobj"
AND rel_xcomp.label = "xcomp"
RETURN nsubj, verb, dobj, xcomp;
