package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

type Dependancy struct {
	Dep            string
	Governor       int
	GovernorGloss  string
	Dependent      int
	DependentGloss string
}

type Token struct {
	Index                int
	Word                 string
	OriginalText         string
	characterOffsetBegin int
	characterOffsetEnd   int
	Pos                  string
}

type Sentence struct {
	Index                   int
	Parse                   string
	BasicDependancies       []Dependancy `json:"basic-dependencies"`
	CollapsedDependancies   []Dependancy `json:"collapsed-dependencies"`
	CollapsedDependanciesCC []Dependancy `json:"collapsed-ccprocessed-dependencies"`
	Tokens                  []Token
}

type Node struct {
	parent   *Node
	text     string
	index    int
	pos      string
	children []*Node
}

func (n *Node) addChild(c *Node) {
	c.parent = n
	n.children = append(n.children, c)
}

func (n *Node) printTree(indent string) {
	fmt.Println(indent + fmt.Sprintf("%v (%v)", n.text, n.index))
	for _, c := range n.children {
		c.printTree(indent + " ")
	}
}

func main() {
	body := strings.NewReader(`There was a man with a dog. It had big ears`)
	client := &http.Client{}
	req, err := http.NewRequest("POST", "http://local.docker:9000/?properties=%7B%22tokenize.whitespace%22:%20%22true%22,%20%22annotators%22:%20%22parse%22,%20%22outputFormat%22:%20%22json%22%7D", body)
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("Failure : ", err)
	}
	respBody, _ := ioutil.ReadAll(resp.Body)

	var parsedReponse struct {
		Sentences []Sentence
	}
	json.Unmarshal(respBody, &parsedReponse)
	fmt.Println(parsedReponse.Sentences[0].Parse)

	nodeMap := make(map[int]*Node)
	var root *Node
	for i, d := range parsedReponse.Sentences[0].BasicDependancies {
		nodeMap[d.Dependent] = &Node{text: d.DependentGloss, index: d.Dependent}
		if i == 0 {
			root = nodeMap[d.Dependent]
		}
	}
	for _, d := range parsedReponse.Sentences[0].BasicDependancies {
		if nodeMap[d.Governor] != nil && nodeMap[d.Dependent] != nil {
			nodeMap[d.Governor].addChild(nodeMap[d.Dependent])
		} else {
			fmt.Println(d)
		}
	}
	root.printTree("")
}
