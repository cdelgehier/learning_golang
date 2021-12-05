package main

import (
	// Import net/http. This is required for example if using constants such as http.StatusOK.
	"net/http"

	"github.com/gin-gonic/gin"

	_ "github.com/cdelgehier/learning_golang/docs" // This line is necessary for go-swagger
	"github.com/cdelgehier/learning_golang/models"
)

// articles slice to seed article data.
var articles = []models.Article{
	{ID: "1", Brand: "Ferrero", Name: "Kinder Bueno", Price: 3.56},
	{ID: "2", Brand: "Mars, Incorporated", Name: "M&M's", Price: 2.43},
	{ID: "3", Brand: "Haribo", Name: "Rotella", Price: 13.90},
}

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
		articles := v1.Group("/articles")
		{
			// articles.GET(":id", ShowArticle)
			articles.GET("", ListArticles)
		}
	}

	router.Run(":8080")
}

// ListArticles godoc
// @Summary      List articles
// @Description  Get a list of all articles known
// @Tags         articles
// @Accept       json
// @Produce      json
// @Success      200  {array}   models.Article
// @Router       /api/v1/articles [get]
func ListArticles(c *gin.Context) {
	c.IndentedJSON(http.StatusOK, articles)
}
