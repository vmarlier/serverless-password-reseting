package static

import (
	"html/template"
	"io/ioutil"
	"net/http"

	"website/internal/app/tools"
)

const (
	templatesPath = "../web/template/"
	datasPath     = "../web/data/"
)

// Page struct is the default structure of a webpage
type Page struct {
	Title string
	Body  []byte
}

// Save takes as its receiver p, a pointer to Page. It takes no parameters, and returns a value of type error.
// This function will write the page body to a text file. We will use the page title as the filename
func (p *Page) Save() error {
	filename := p.Title + ".txt"
	return ioutil.WriteFile(filename, p.Body, 0600)
}

// LoadPage will constructs the file name from the title parameter, reads the file contents into a new variable body,
// and return the constructed title and body as a Page struct.
func LoadPage(title string) *Page {
	filename := title + ".txt"
	body, err := ioutil.ReadFile(datasPath + filename)
	tools.HandlerErr(1, "loadPage()", err)
	return &Page{Title: title, Body: body}
}

// RenderTemplate will take a specified html template and execute it.
func RenderTemplate(w http.ResponseWriter, tmpl string, p *Page) {
	t, err := template.ParseFiles(templatesPath + tmpl + ".html")
	tools.HandlerErr(4, "", err)
	t.Execute(w, p)
}
