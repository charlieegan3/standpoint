//NP VERB NP LEX NP

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_subj:REL]->(subj:Node)
MATCH (verb)-[rel_obj:REL]->(obj:Node)
MATCH (verb)-[rel_np2:REL]->(np2:Node)
MATCH (np2)-[rel_lex:REL]->(lex:Node)

WHERE rel_subj.label = "nsubj"
AND rel_obj.label = "dobj"
AND rel_np2.label = "advcl"
AND rel_lex.label = "mark"
RETURN subj, verb, obj, lex, np2;
