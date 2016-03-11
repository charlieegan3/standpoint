package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"strings"
)

type RawPoint struct {
	String             string
	Pattern            string
	Stance             string
	OriginalStanceText string
	OriginalTopic      string
	Post               string
	Content            string
}

type Point struct {
	String             string
	Verb               string
	Stance             string
	OriginalStanceText string
	OriginalTopic      string
	Post               string
	Content            string `json:"-"`
	Components         []string
	Words              []string
	Relations          []string
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

func removeDuplicates(elements []int) []int {
	encountered := map[int]bool{}
	result := []int{}

	for v := range elements {
		if encountered[elements[v]] == true {
		} else {
			encountered[elements[v]] = true
			result = append(result, elements[v])
		}
	}
	return result
}

func pairs(arr []int) [][]int {
	var pairs [][]int
	for i := 0; i < len(arr); i++ {
		for j := i + 1; j < len(arr); j++ {
			pairs = append(pairs, []int{arr[i], arr[j]})
		}
	}
	return pairs
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
		String:             p.String,
		Stance:             p.Stance,
		OriginalStanceText: p.OriginalStanceText,
		OriginalTopic:      p.OriginalTopic,
		Post:               p.Post,
		Content:            p.Content,
		Verb:               verb,
		Components:         components,
		Relations:          relations,
		Words:              words,
	}
}

type ByLen [][]Point

func (a ByLen) Len() int           { return len(a) }
func (a ByLen) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a ByLen) Less(i, j int) bool { return len(a[i]) > len(a[j]) }

func main() {
	b, err := ioutil.ReadFile(os.Args[1])
	if err != nil {
		panic(err)
	}

	points := []Point{}
	contents := strings.Split(string(b), "\n")
	for i, v := range contents {
		if i == 0 || len(v) < 4 {
			continue
		}
		var rawPoint = RawPoint{}
		json.Unmarshal([]byte(v[0:len(v)-1]), &rawPoint)
		points = append(points, upgradePoint(rawPoint))
	}

	bannedList := strings.Split("it.nsubj that.nsubj this.nsubj which.nsubj what.nsubj", " ")
	bannedPersonList := strings.Split("object continue come go sit open close begin end believe happen leave understand realize debate speak show stand call refer believe lose change care hear write disagree read tell start talk explain come live take support guess feel follow make go get move agree find fail feel ask argue try", " ")
	for i, v := range bannedPersonList {
		bannedPersonList[i] = fmt.Sprintf("%v.verb", v)
	}
	bannedComponentList := []string{
		"PERSON.nsubj be.verb correct.dobj",
		"PERSON.nsubj be.verb able.dobj",
		"PERSON.nsubj be.verb good.dobj",
		"PERSON.nsubj be.verb likely.dobj",
		"PERSON.nsubj be.verb sorry.dobj",
		"PERSON.nsubj be.verb say.dobj",
		"PERSON.nsubj be.verb aware.dobj",
		"PERSON.nsubj be.verb one.dobj",
		"PERSON.nsubj be.verb sure.dobj",
		"PERSON.nsubj be.verb wrong.dobj",
		"PERSON.nsubj be.verb glad.dobj",
		"PERSON.nsubj be.verb here.dobj",
		"PERSON.nsubj be.verb willing.dobj",
		"PERSON.nsubj be.verb right.dobj",
		"PERSON.nsubj be.verb true.dobj",
		"PERSON.nsubj be.verb false.dobj",
		"PERSON.nsubj be.verb favor.dobj",
		"PERSON.nsubj be.verb interested.dobj",
		"PERSON.nsubj want.verb have.xcomp",
		"PERSON.nsubj want.verb what.dobj",
		"PERSON.nsubj want.verb what.dobj do.xcomp",
		"PERSON.nsubj say.verb what.dobj",
		"PERSON.nsubj mean.verb what.dobj",
		"PERSON.nsubj know.verb what.dobj",
		"PERSON.nsubj believe.verb what.dobj",
		"PERSON.nsubj see.verb what.dobj",
		"PERSON.nsubj see.verb argument.dobj",
		"PERSON.nsubj have.verb problem.dobj",
		"PERSON.nsubj tell.verb they.dobj",
		"PERSON.nsubj think.verb what.dobj",
		"PERSON.nsubj argue.verb in.prep fact.dobj",
		"PERSON.nsubj argue.verb with.prep you.dobj",
		"debate.nsubj be.verb about.dobj",
		"question.nsubj be.verb",
		"make.verb claim.dobj",
		"ask.verb yourself.dobj",
		"thing.nsubj happen.verb",
		"something.nsubj happen.verb",
	}
	personList := strings.Split("who.nsubj we.nsubj I.nsubj you.nsubj they.nsubj he.nsubj she.nsubj person.nsubj people.nsubj", " ")

	originalSize := len(points)

	for i := 0; i < len(points); i++ {
		point := points[i]
		if containsStr(personList, point.Components[0]) {
			point.Components[0] = "PERSON.nsubj"
		}
		if containsStr(bannedList, point.Components[0]) {
			points = append(points[:i], points[i+1:]...)
			i--
		} else if len(point.Components) == 2 && point.Components[0] == "PERSON.nsubj" && containsStr(bannedPersonList, point.Components[1]) {
			points = append(points[:i], points[i+1:]...)
			i--
		} else if containsStr(bannedComponentList, strings.Join(point.Components, " ")) {
			points = append(points[:i], points[i+1:]...)
			i--
		} else if len(point.String) < 10 {
			points = append(points[:i], points[i+1:]...)
			i--
		}
	}
	fmt.Printf("%v of %v points disqualified\n", originalSize-len(points), originalSize)

	for _, v := range points {
		b, err := json.Marshal(v)
		if err != nil {
			return
		}
		fmt.Println(string(b))
	}
}
