//NP VERB NP LEX
//in conj 2nd np the first nn is selected (since it relates to the 2nd via conj:and or other)

MATCH (verb:Node {uuid: 'VERB_UUID'})
MATCH (verb)-[rel_subj:REL]->(subj:Node)
MATCH (verb)-[rel_obj:REL]->(obj:Node)
MATCH (verb)-[rel_lex:REL]->(lex:Node)
WHERE rel_subj.label = "nsubj"
AND rel_obj.label = "dobj"
AND rel_lex.label = "advmod"
RETURN subj, verb, obj, lex
ORDER BY obj.index;
