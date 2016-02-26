//NP VERB LEX
//why can't there JUST be an nsubj to the head of the NP?

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH path=(subj:Node)-[REL*1..3]->(verb)
MATCH (np2)-[rel_lex:REL]->(lex:Node)

WHERE rel_lex.label = "advmod"
AND "acl" IN EXTRACT(r in relationships(path) | r.label)
RETURN subj, verb, lex
ORDER BY subj.index;
