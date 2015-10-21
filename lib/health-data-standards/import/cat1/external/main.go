package main

import (
	"github.com/moovweb/gokogiri/xml"
	"github.com/moovweb/gokogiri/xpath"
	"github.com/pebbe/util"
	"io/ioutil"
	"strconv"
	"time"
	"C"
	"fmt"
	"encoding/json"
)

var patientXPath = xpath.Compile("/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient")
var encounterXPath = xpath.Compile("//cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.23']")
var timeLowXPath = xpath.Compile("cda:effectiveTime/cda:low/@value")
var timeHighXPath = xpath.Compile("cda:effectiveTime/cda:high/@value")
var lastNameXPath = xpath.Compile("cda:name/cda:family")
var firstNameXPath = xpath.Compile("cda:name/cda:given")
var birthTimeXPath = xpath.Compile("cda:birthTime/@value")
var genderXPath = xpath.Compile("cda:administrativeGenderCode/@code")
var raceXPath = xpath.Compile("cda:raceCode/@code")
var raceCodeSetXPath = xpath.Compile("cda:raceCode/@codeSystemName")
var ethnicityXPath = xpath.Compile("cda:ethnicGroupCode/@code")
var ethnicityCodeSetXPath = xpath.Compile("cda:ethnicGroupCode/@codeSystemName")
var codeXPath = xpath.Compile("cda:code/@code")

func main() {}

type Coded interface {
	Codes() map[string][]string
	SetCodes(codes map[string][]string)
}

type Header struct {
	Authenticator Authenticator
}

type Authenticator struct {
}

type Entity struct {
	Ids       []ID
	Addresses []Address
	Telecoms  []Telecom
}

type Person struct {
	Entity
	First     string `json:"first"`
	Last      string `json:"last"`
	Gender    string `json:"gender"`
	Birthdate int64  `json:"birthdate"`
	Race			Race   `json:"race"`
	Ethnicity Ethnicity `json:"ethnicity"`
}

type Race struct {
	Code string `json:"code"`
	CodeSet string `json:"code_set"`
}

type Ethnicity struct {
	Code string `json:"code"`
	CodeSet string `json:"code_set"`
}

type Organization struct {
	Entity
}

type Address struct {
}

type Telecom struct {
}

type ID struct {
	Root      string
	Extension string
}

type Record struct {
	Person
	MedicalRecordNumber string      `json:"MedicalRecordNumber"`
	Encounters          []Encounter `bson:"encounters"`
}

type ResultValue struct {
	Scalar string              "scalar"
	Units  string              "units"
	codes  map[string][]string "codes"
}

func (rv *ResultValue) Codes() map[string][]string {
	return rv.codes
}

func (rv *ResultValue) SetCodes(codes map[string][]string) {
	rv.codes = codes
}

func NewResultValue() *ResultValue {
	rv := new(ResultValue)
	rv.codes = make(map[string][]string)
	return rv
}

type Entry struct {
	StartTime   int64               "start_time"
	EndTime     int64               "end_time"
	Time        int64               "time"
	Oid         string              "oid"
	codes       map[string][]string "codes"
	NegationInd bool                "negationInd"
	Values      []ResultValue       `bson:"values"`
	StatusCode  map[string][]string "status_code"
}

func NewEntry() *Entry {
	entry := new(Entry)
	entry.codes = make(map[string][]string)
	return entry
}

func (entry *Entry) AddResultValue(rv *ResultValue) {
	entry.Values = append(entry.Values, *rv)
}

func (entry *Entry) Codes() map[string][]string {
	return entry.codes
}

func (entry *Entry) SetCodes(codes map[string][]string) {
	entry.codes = codes
}

var oidMap = map[string]string{
	"2.16.840.1.113883.6.12":  "CPT",
	"2.16.840.1.113883.6.1":   "LOINC",
	"2.16.840.1.113883.6.96":  "SNOMED-CT",
	"2.16.840.1.113883.6.88":  "RxNorm",
	"2.16.840.1.113883.6.103": "ICD-9-CM",
	"2.16.840.1.113883.6.104": "ICD-9-PCS",
	"2.16.840.1.113883.6.4":   "ICD-10-PCS",
	"2.16.840.1.113883.6.90":  "ICD-10-CM",
}

func CodeSystemFor(oid string) string {
	return oidMap[oid]
}

func AddCode(coded Coded, code, codeSystem string) {
	codeSystemName := CodeSystemFor(codeSystem)
	coded.Codes()[codeSystemName] = append(coded.Codes()[codeSystemName], code)
}

type Encounter struct {
	Entry     `bson:",inline"`
	AdmitTime int64 "admitTime"
}

//export read_patient
func read_patient(rawPath *C.char) string {

	path := C.GoString(rawPath)
	data, err := ioutil.ReadFile(path)
	util.CheckErr(err)

	doc, err := xml.Parse(data, nil, nil, 0, xml.DefaultEncodingBytes)
	util.CheckErr(err)
	defer doc.Free()

	xp := doc.DocXPathCtx()
	xp.RegisterNamespace("cda", "urn:hl7-org:v3")

	// fmt.Println("\nPatient Name:\n")

	patientElements, err := doc.Root().Search(patientXPath)
	util.CheckErr(err)
	patientElement := patientElements[0]
	patient := &Record{}
	patient.First = FirstElementContent(firstNameXPath, patientElement)
	patient.Last = FirstElementContent(lastNameXPath, patientElement)
	patient.Gender = FirstElementContent(genderXPath, patientElement)
	patient.Birthdate = GetTimestamp(birthTimeXPath, patientElement)
	patient.Race.Code = FirstElementContent(raceXPath, patientElement)
	patient.Race.CodeSet = FirstElementContent(raceCodeSetXPath, patientElement)
	patient.Ethnicity.Code = FirstElementContent(ethnicityXPath, patientElement)
	patient.Ethnicity.CodeSet = FirstElementContent(ethnicityCodeSetXPath, patientElement)

	patientJSON, err := json.Marshal(patient)
	if err != nil {
		fmt.Println(err)
	}

	return string(patientJSON)

}

func ExtractEncounters(record *Record, xmlNode xml.Node) {
	encounterElements, err := xmlNode.Search(encounterXPath)
	util.CheckErr(err)
	encounters := make([]Encounter, len(encounterElements))
	for i, encounterElement := range encounterElements {
		startTime := GetTimestamp(timeLowXPath, encounterElement)
		endTime := GetTimestamp(timeHighXPath, encounterElement)
		code := FirstElementContent(codeXPath, encounterElement)
		oid := "2.16.840.1.113883.3.560.1.79"
		encounter := Encounter{Entry{StartTime: startTime, EndTime: endTime, Oid: oid}, 0}
		codes := map[string][]string{
			"CPT": []string{code},
		}
		encounter.SetCodes(codes)
		encounters[i] = encounter
	}
	record.Encounters = encounters
}

func FirstElementContent(xpath *xpath.Expression, xmlNode xml.Node) string {
	resultNodes, err := xmlNode.Search(xpath)
	util.CheckErr(err)
	firstNode := resultNodes[0]
	return firstNode.Content()
}

func GetTimestamp(xpath *xpath.Expression, xmlNode xml.Node) int64 {
	attrValue := FirstElementContent(xpath, xmlNode)
	return TimestampToSeconds(attrValue)
}

func TimestampToSeconds(timestamp string) int64 {
	year, _ := strconv.ParseInt(timestamp[0:4], 10, 32)
	month, _ := strconv.ParseInt(timestamp[4:6], 10, 32)
	day, _ := strconv.ParseInt(timestamp[6:8], 10, 32)
	desiredDate := time.Date(int(year), time.Month(month), int(day), 0, 0, 0, 0, time.UTC)
	return desiredDate.Unix()
}
