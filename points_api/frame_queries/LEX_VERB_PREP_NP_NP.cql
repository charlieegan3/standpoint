//LEX VERB PREP NP NP

MATCH (verb:Node)
WHERE ANY (uuid IN ["UUIDS"] WHERE uuid = verb.uuid)
MATCH (verb)-[rel_lex:REL]->(lex:Node)
MATCH (verb)-[rel_nmod:REL]->(nmod:Node)
MATCH (nmod)-[rel_prep:REL]->(prep:Node)
MATCH (nmod)-[rel_dep:REL]->(dep:Node)
WHERE rel_lex.label = "expl"
AND rel_nmod.label =~ 'nmod:.*'
AND rel_prep.label = "case"
AND rel_dep.label = "dep"
RETURN lex, verb, prep, nmod, dep;
