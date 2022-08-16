package handlers

import (
	"fmt"
	"net/http"

	"github.com/manik/bookings/pkg/config"
	"github.com/manik/bookings/pkg/models"
	"github.com/manik/bookings/pkg/render"
)

// Repository is the repository type
type Repository struct {
	App *config.AppConfig
}

// Repo the repository used by the handlers
var Repo *Repository

// New Repo creates a repository
func NewRepo(a *config.AppConfig) *Repository {
	return &Repository{
		App: a,
	}
}

// NewHandlers sets the Repository for the handler
func NewHandlers(r *Repository) {
	Repo = r
}

func checkErr(err error) {
	if err != nil {
		fmt.Println("Error -->", err)
		return
	}
}

// Home is the Home page handler
func (repo *Repository) Home(w http.ResponseWriter, r *http.Request) {
	// recording the IP address of the user visiting the page
	remoteIP := r.RemoteAddr
	// assigning the remote IP in session
	repo.App.Session.Put(r.Context(), "remote_ip", remoteIP)
	err := render.RenderTemplate(w, "home.page.tmpl", &models.TemplateData{})
	checkErr(err)
}

// About is the about page handler
func (repo *Repository) About(w http.ResponseWriter, r *http.Request) {
	// perform some logic
	stringMap := make(map[string]string)
	stringMap["test"] = "Hello Again"

	// getting the remote IP stored in the session
	remoteIP := repo.App.Session.GetString(r.Context(), "remote_ip")
	// storing the remote IP in the stringMap
	stringMap["remote_ip"] = remoteIP
	err := render.RenderTemplate(w, "about.page.tmpl", &models.TemplateData{
		StringMap: stringMap,
	})
	checkErr(err)
}
