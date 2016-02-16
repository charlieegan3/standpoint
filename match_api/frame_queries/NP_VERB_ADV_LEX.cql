//NP VERB ADV LEX

MATCH (verb:Node {uuid: 'VERB_UUID'})
MATCH (verb)-[rel_subj:REL]->(subj:Node)
MATCH (verb)-[rel_obj:REL]->(obj:Node)
MATCH (verb)-[rel_adv:REL]->(adv:Node)
MATCH (verb)-[rel_lex:REL]->(lex:Node)

WHERE rel_subj.label = "nsubj"
AND rel_obj.label = "dobj"
AND rel_adv.label = "advmod"
AND rel_lex.label = "advmod"
AND adv.index < lex.index
RETURN subj, verb, obj, lex

ORDER BY subj.index;
