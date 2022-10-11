package render

import (
	"bytes"
	"fmt"
	"log"
	"net/http"
	"path/filepath"
	"text/template"

	"github.com/manikparashar/bookings/pkg/config"
	"github.com/manikparashar/bookings/pkg/models"
)

//var functions = template.FuncMap{}

var app *config.AppConfig

// New Template sets the config for the template package
func NewTemplates(a *config.AppConfig) {
	app = a
}

func AddDefaultData(td *models.TemplateData) *models.TemplateData {
	return td
}

// RenderTemplate using html/template
func RenderTemplate(w http.ResponseWriter, tmpl string, td *models.TemplateData) error {
	var tc map[string]*template.Template
	// in dev mode render the template on every request else render
	// via a template cache
	if app.UseCache {
		// get the template cache from the app config
		tc = app.TemplateCache
	} else {
		fmt.Println("Creating template cache")
		tc, _ = CreateTemplateCache()
	}

	/*
		Deprecated
		tc, err := CreateTemplateCache()
		if err != nil {
			log.Fatal(err)
		}
	*/

	// get requested template from cache
	t, ok := tc[tmpl]
	if !ok {
		log.Fatal("could not get template from template cache")
	}

	buf := new(bytes.Buffer)

	td = AddDefaultData(td)

	err := t.Execute(buf, td)
	if err != nil {
		fmt.Println(err)
		return err
	}
	// render the template
	_, err = buf.WriteTo(w)
	if err != nil {
		log.Println(err)
		return err
	}
	return nil
}

func CreateTemplateCache() (map[string]*template.Template, error) {
	log.Println("Inside CreateTemplateCache function")
	myCache := map[string]*template.Template{}
	// get all the files named *.page.tmpl from ./templates directory
	pages, err := filepath.Glob("./templates/*.page.tmpl")
	if err != nil {
		fmt.Println("Error:", err)
		return myCache, err
	}
	// range through all files ending with *.page.tmpl
	for _, page := range pages {
		name := filepath.Base(page)
		ts, err := template.New(name).ParseFiles(page)
		if err != nil {
			return myCache, err
		}
		matches, err := filepath.Glob("./templates/*.layout.tmpl")
		if err != nil {
			return myCache, err
		}

		if len(matches) > 0 {
			ts, err = ts.ParseGlob("./templates/*.layout.tmpl")
			if err != nil {
				return myCache, err
			}
		}
		myCache[name] = ts
	}
	return myCache, nil
}

/*
						Approch 1 for rendering templates
						==================================

// declaring package level variable to hold the template cache
var tc = make(map[string]*template.Template)

func RenderTemplate(w http.ResponseWriter, t string) error {
	var tmpl *template.Template
	var err error

	// check to see if we already have a template in our cache
	_, inMap := tc[t]
	if !inMap {
		// need to create the template
		fmt.Println("Creating template and adding to the cache")
		err = createTemplateCache(t)
		if err != nil {
			return err
		}
	} else {
		// we have the template in the cache
		log.Println("Using cached template")
	}
	tmpl = tc[t]

	err = tmpl.Execute(w, nil)
	if err != nil {
		return err
	}
	return nil
}

func createTemplateCache(t string) error {
	templates := []string{
		fmt.Sprintf("./templates/%s", t),
		"./templates/base.layout.tmpl",
	}
	// parse the template
	tmpl, err := template.ParseFiles(templates...)
	if err != nil {
		return err
	}
	// add template to cache
	tc[t] = tmpl
	return nil
}
*/
