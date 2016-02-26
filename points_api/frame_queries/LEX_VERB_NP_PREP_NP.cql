//LEX VERB NP PREP NP

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_lex:REL]->(lex:Node)
MATCH (verb)-[rel_obj:REL]->(obj:Node)
MATCH (verb)-[rel_nmod:REL]->(nmod:Node)
MATCH (nmod)-[rel_prep:REL]->(prep:Node)
WHERE rel_lex.label = "expl"
AND rel_obj.label = "dobj"
AND rel_nmod.label =~ 'nmod:.*'
AND rel_prep.label = "case"
RETURN lex, verb, obj, prep, nmod;
