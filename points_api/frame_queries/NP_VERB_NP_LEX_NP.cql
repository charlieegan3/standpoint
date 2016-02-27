//NP VERB NP LEX NP

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_nsubj:REL]->(nsubj:Node)
MATCH (verb)-[rel_dobj:REL]->(dobj:Node)
MATCH (verb)-[rel_np2:REL]->(np2:Node)
MATCH (np2)-[rel_lex:REL]->(lex:Node)

WHERE rel_nsubj.label = "nsubj"
AND rel_dobj.label = "dobj"
AND rel_np2.label = "advcl"
AND rel_lex.label = "mark"
RETURN nsubj, verb, dobj, lex, np2;
