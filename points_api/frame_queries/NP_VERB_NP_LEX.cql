//NP VERB NP LEX
//in conj 2nd np the first nn is selected (since it relates to the 2nd via conj:and or other)

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_nsubj:REL]->(nsubj:Node)
MATCH (verb)-[rel_dobj:REL]->(dobj:Node)
MATCH (verb)-[rel_lex:REL]->(lex:Node)
WHERE rel_nsubj.label = "nsubj"
AND rel_dobj.label = "dobj"
AND rel_lex.label = "advmod"
RETURN nsubj, verb, dobj, lex
ORDER BY dobj.index;
