//VERB
//attempts to match the tree for all verbs

MATCH (verb:Node {uuid: 'VERB_UUID'})
OPTIONAL MATCH (verb)-[nsubj_rel:REL]->(nsubj:Node) WHERE nsubj_rel.label = "nsubj"
OPTIONAL MATCH (verb)-[nsubjpass_rel:REL]->(nsubjpass:Node) WHERE nsubjpass_rel.label = "nsubjpass"
OPTIONAL MATCH p=(verb)<--(dobjcop:Node)-->(nsubjcop:Node) WHERE ALL (r IN relationships(p) WHERE r.label = "nsubj" OR r.label = "cop")
OPTIONAL MATCH (verb)-[xcomp_rel:REL]->(xcomp:Node) WHERE xcomp_rel.label = "xcomp"
OPTIONAL MATCH (verb)-[ccomp_rel:REL]->(ccomp:Node) WHERE ccomp_rel.label = "ccomp"
OPTIONAL MATCH (verb)-[dobj_rel:REL]->(dobj:Node) WHERE ANY (l IN ['dobj', 'nmod.*'] WHERE dobj_rel.label =~ l)
RETURN nsubj, nsubjpass, nsubjcop, verb, dobj, dobjcop, xcomp, ccomp;
