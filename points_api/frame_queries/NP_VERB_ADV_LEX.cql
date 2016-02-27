//NP VERB ADV LEX

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_nsubj:REL]->(nsubj:Node)
MATCH (verb)-[rel_dobj:REL]->(dobj:Node)
MATCH (verb)-[rel_adv:REL]->(adv:Node)
MATCH (verb)-[rel_lex:REL]->(lex:Node)

WHERE rel_nsubj.label = "nsubj"
AND rel_dobj.label = "dobj"
AND rel_adv.label = "advmod"
AND rel_lex.label = "advmod"
AND adv.index < lex.index
RETURN nsubj, verb, dobj, lex

ORDER BY nsubj.index;
