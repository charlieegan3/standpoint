package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"regexp"
	"strings"
)

func coreNlpPost(host string, endpoint string, params url.Values, body string) ([]byte, error) {
	client := &http.Client{}
	req, err := http.NewRequest("POST", host+"/"+endpoint+"?"+params.Encode(), strings.NewReader(body))
	if err != nil {
		return []byte{}, err
	}
	resp, err := client.Do(req)
	if err != nil {
		return []byte{}, err
	}
	respBody, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return []byte{}, err
	}
	return respBody, nil
}

func wordsForSentence(sentence string) ([]string, error) {
	params := url.Values{}
	params.Set("properties", `{"annotators": "tokenize,ssplit"}`)
	response, err := coreNlpPost("http://192.168.99.100:9000", "", params, sentence)
	if err != nil {
		return []string{}, err
	}

	type Container struct {
		Sentences []struct {
			Tokens []struct {
				Index int    `json:"index"`
				Word  string `json:"word"`
			} `json:"tokens"`
		} `json:"sentences"`
	}
	var cont Container
	if err := json.Unmarshal(response, &cont); err != nil {
		return []string{}, err
	}
	var words []string
	for _, token := range cont.Sentences[0].Tokens {
		words = append(words, token.Word)
	}
	return words, nil
}

func formatResponse(response string) string {
	re := regexp.MustCompile(`\A(.*\n){3}`)
	response = re.ReplaceAllString(response, "[\n")
	re = regexp.MustCompile(`(\n.*){3}\z`)
	response = re.ReplaceAllString(response, "\n]")
	re = regexp.MustCompile(`,\s+"length":.*\n`)
	response = re.ReplaceAllString(response, "\n")
	re = regexp.MustCompile(`"\d*":`)
	response = re.ReplaceAllString(response, "")
	return response
}

type Point struct {
	text   string
	tags   []string
	source string
}

func pointForTopic(topic string, sentence string) (Point, error) {
	patterns := []string{
		"{}=verb >nsubj {}=subj >dobj {}=obj",
		"{}=verb >/nmod.*/ {}=subj >dobj {}=obj",
		"{}=verb >nsubj {}=subj >/nmod.*/ {}=obj",
		"{}=obj >nsubj {}=subj >cop {}=verb",
		"{}=verb >nsubj {}=subj >ccomp {}=verb2",
		"{}=subj >advcl {}=verb",
	}

	params := url.Values{}
	for _, v := range patterns {
		params.Set("pattern", v)
		resp, _ := coreNlpPost("http://192.168.99.100:9000", "semgrex", params, sentence)
		fmt.Println(v)
		fmt.Println(formatResponse(string(resp)))
		fmt.Println("-------------------------------------\n")
	}

	//type Relation struct {
	//Sentences []struct {
	//Token struct {
	//Text string `json:"text"`
	//End  int    `json:"end"`
	//} `json:"0"`
	//} `json:"sentences"`
	//}
	//var governorsRel Relation
	//if err := json.Unmarshal(governorsResp, &governorsRel); err != nil {
	//return Point{}, err
	//}
	//var dependentsRel Relation
	//if err := json.Unmarshal(dependentsResp, &dependentsRel); err != nil {
	//return Point{}, err
	//}
	//
	//fmt.Println(string(governorsResp))
	//fmt.Println(string(dependentsResp))
	//
	//words, _ := wordsForSentence(sentence)
	//var topicIndex int
	//for i, word := range words {
	//if word == topic {
	//topicIndex = i + 1
	//break
	//}
	//}
	//
	//indexes := []int{
	//dependentsRel.Sentences[0].Token.End - 1,
	//governorsRel.Sentences[0].Token.End - 1,
	//topicIndex,
	//}
	//sort.Ints(indexes)
	//span := words[indexes[0]:indexes[len(indexes)-1]]
	//point := Point{
	//text:   strings.Join(span, " "),
	//tags:   words,
	//source: sentence,
	//}

	return Point{}, nil
}

func main() {
	body := `i stand by opening statement, that evolution is a lie`
	topic := "british"

	fmt.Println(pointForTopic(topic, body))
}
