//NP VERB PREP NP NP

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_nsubj:REL]->(nsubj:Node)
MATCH (verb)-[rel_nmod:REL]->(nmod:Node)
MATCH (nmod)-[rel_prep:REL]->(prep:Node)
MATCH (nmod)-[rel_dobj:REL]->(dobj:Node)

WHERE rel_nsubj.label = "nsubj"
AND rel_dobj.label = "appos"
AND rel_nmod.label =~ 'nmod.*'
AND rel_prep.label = "case"

RETURN nsubj, verb, prep, nmod, dobj;
