//NP VERB LEX

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH path=(nsubj:Node)-[REL*1..3]->(verb)
MATCH (np2)-[rel_lex:REL]->(lex:Node)

WHERE rel_lex.label = "advmod"
AND "acl" IN EXTRACT(r in relationships(path) | r.label)
RETURN nsubj, verb, lex
ORDER BY nsubj.index;
