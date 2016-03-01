package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"regexp"
	"sort"
	"strings"
)

type RawPoint struct {
	String  string
	Pattern string
}

type Point struct {
	String     string
	Verb       string
	Components []string
	Words      []string
	Relations  []string
}

func (p *Point) print() {
	fmt.Printf("(%v) : %v\n", strings.Join(p.Components, " "), p.String)
}

func (p *Point) componentString() string {
	return strings.Join(p.Components, " ")
}

func (p *Point) matches(p2 Point) bool {
	if p.Verb != p2.Verb {
		return false
	}
	return p.matchesWords(p2) || p.componentString() == p2.componentString()
}

func (p *Point) matchesWords(p2 Point) bool {
	return compare(p.Words, p2.Words) && compare(p2.Words, p.Words)
}

func compare(X, Y []string) bool {
	m := make(map[string]int)

	for _, y := range Y {
		m[y]++
	}

	var ret []string
	for _, x := range X {
		if m[x] > 0 {
			m[x]--
			continue
		}
		ret = append(ret, x)
	}

	return len(ret) == 0
}

func containsStr(s []string, e string) bool {
	for _, a := range s {
		if a == e {
			return true
		}
	}
	return false
}
func containsInt(s []int, e int) bool {
	for _, a := range s {
		if a == e {
			return true
		}
	}
	return false
}

func upgradePoint(p RawPoint) Point {
	pattern := regexp.MustCompile("cop|pass").ReplaceAllString(p.Pattern, "")
	components := strings.Split(pattern, " ")
	var verb string
	var words []string
	var relations []string
	for _, v := range components {
		parts := strings.Split(v, ".")
		if parts[1] == "verb" {
			verb = parts[0]
		}
		words = append(words, parts[0])
		relations = append(relations, parts[1])
	}
	return Point{
		String:     p.String,
		Verb:       verb,
		Components: components,
		Relations:  relations,
		Words:      words,
	}
}

type ByLen [][]Point

func (a ByLen) Len() int           { return len(a) }
func (a ByLen) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a ByLen) Less(i, j int) bool { return len(a[i]) < len(a[j]) }

func main() {
	b, err := ioutil.ReadFile("points7")
	if err != nil {
		panic(err)
	}
	contents := strings.Split(string(b), "\n")
	contents = contents[:5000]

	points := []Point{}
	for i, v := range contents {
		if i == 0 || v == "" {
			continue
		}
		line := strings.Split(v, " ")
		jsonStr := strings.Join(line[1:len(line)], " ")
		rawPoint := RawPoint{}
		json.Unmarshal([]byte(jsonStr), &rawPoint)
		points = append(points, upgradePoint(rawPoint))
	}

	bannedList := strings.Split("it.nsubj that.nsubj this.nsubj which.nsubj what.nsubj", " ")
	bannedPersonList := strings.Split("object talk explain come live take support guess feel make go get agree find fail feel ask argue try", " ")
	for i, v := range bannedPersonList {
		bannedPersonList[i] = fmt.Sprintf("%v.verb", v)
	}
	bannedPersonComponentList := []string{
		"PERSON.nsubj be.verb correct.dobj",
		"PERSON.nsubj be.verb sure.dobj",
		"PERSON.nsubj be.verb wrong.dobj",
		"PERSON.nsubj want.verb what.dobj",
		"PERSON.nsubj be.verb glad.dobj",
		"PERSON.nsubj be.verb willing.dobj",
		"debate.nsubj be.verb about.dobj",
	}
	personList := strings.Split("we.nsubj I.nsubj you.nsubj they.nsubj he.nsubj she.nsubj", " ")

	for i, point := range points {
		if containsStr(bannedList, point.Components[0]) {
			points = append(points[:i], points[i+1:]...)
		} else if containsStr(personList, point.Components[0]) {
			point.Components[0] = "PERSON.nsubj"
		}
		if len(point.Components) == 2 && point.Components[0] == "PERSON.nsubj" && containsStr(bannedPersonList, point.Components[1]) {
			points = append(points[:i], points[i+1:]...)
		} else if containsStr(bannedPersonComponentList, strings.Join(point.Components, " ")) {
			points = append(points[:i], points[i+1:]...)
		}
	}

	var matched []int
	var groups [][]Point
	size := len(points)
	for i, outer := range points {
		fmt.Printf("%v\n", float32(i)/float32(size))
		if containsInt(matched, i) {
			continue
		}
		matched = append(matched, i)
		var group []Point
		for j, inner := range points {
			if containsInt(matched, j) {
				continue
			}
			if outer.matches(inner) {
				group = append(group, inner)
				matched = append(matched, j)
			}
		}
		if len(group) < 5 {
			continue
		}
		groups = append(groups, group)
	}
	sort.Sort(ByLen(groups))

	for _, group := range groups {
		fmt.Printf("%v : %v\n", len(group), group[0].Components)
		for _, point := range group {
			fmt.Printf("    %v\n", point.String)
		}
	}
}
