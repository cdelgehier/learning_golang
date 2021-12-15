// Golang REST API server
package main

import (
	// Import net/http. This is required for example if using constants such as http.StatusOK.
	"net/http"
	"time"

	"github.com/gin-gonic/gin"

	_ "github.com/cdelgehier/learning_golang/docs" // This line is necessary for go-swagger
	"github.com/cdelgehier/learning_golang/models"
)

// products slice to seed product data.
var products = []models.Product{
	{ID: "1", Brand: "Ferrero", Name: "Kinder Bueno", Price: 3.56},
	{ID: "2", Brand: "Mars, Incorporated", Name: "M&M's", Price: 2.43},
	{ID: "3", Brand: "Haribo", Name: "Rotella", Price: 13.90},
}

const VERSION = "0.1"

// @title           MyApp API
// @version         1.0
// @description     This is the MyApp API server.
// @termsOfService  http://swagger.io/terms/

// @contact.name   DELGEHIER Cedric
// @contact.url    https://twitter.com/JackNemrod

// @license.name  Apache 2.0
// @license.url   http://www.apache.org/licenses/LICENSE-2.0.html

// @host      localhost:8080
// @BasePath  /api/v1

func main() {

	// Default With the Logger and Recovery middleware already attached
	router := gin.Default()

	// Group routes by version
	v1 := router.Group("/api/v1")
	{
		v1.GET("/ping", Ping)
		v1.GET("/version", Version)

		products := v1.Group("/product")
		{
			// products.GET(":id", ShowProduct)
			products.GET("", ListProducts)
		}
	}

	router.Run(":8080")
}

// ListProducts godoc
// @Summary      List products
// @Description  Get a list of all products known
// @Tags         products
// @Accept       json
// @Produce      json
// @Success      200  {array}   models.Product
// @Router       /api/v1/products [get]
func ListProducts(c *gin.Context) {
	c.IndentedJSON(http.StatusOK, products)
}

// Ping godoc
// @Summary      Ping
// @Description  Ping method for API Server
// @Accept       json
// @Produce      json
// @Success      200  {object} models.Ping "ping !"
// @Router       /api/v1/ping [get]
func Ping(c *gin.Context) {
	c.IndentedJSON(http.StatusOK, models.Ping{Pong: time.Now()})
}

// Version godoc
// @Summary      Version
// @Description  Version of API-server
// @Accept       json
// @Produce      json
// @Success      200  {string} Version "version"
// @Router       /api/v1/version [get]
func Version(c *gin.Context) {
	c.IndentedJSON(http.StatusOK, gin.H{"version": VERSION})
}
