# NOTES

## Init Module

Create a module in which you can manage dependencies.
Run the go mod init command, giving it the path of the module your code will be in.

```
$ go mod init cdelgehier/learning_golang
go: creating new go.mod: module cdelgehier/learning_golang

$ cat go.mod
module cdelgehier/learning_golang

go 1.17
```
## Get dependencies for code in the current directory

```golang
package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// product represents data about an product.
type product struct {
	ID    string  `json:"id"`
	Brand string  `json:"brand"`
	Name  string  `json:"name"`
	Price float64 `json:"price"`
}

// products slice to seed product data.
var products = []product{
	{ID: "1", Brand: "Ferrero", Name: "Kinder Bueno", Price: 3.56},
	{ID: "2", Brand: "Mars, Incorporated", Name: "M&M's", Price: 2.43},
	{ID: "3", Brand: "Haribo", Name: "Rotella", Price: 13.90},
}

// getProducts responds with the list of all products as JSON.
func getProducts(c *gin.Context) {
	c.IndentedJSON(http.StatusOK, products)
}

func main() {
	router := gin.Default()
	router.GET("/products", getProducts)

	router.Run("localhost:8080")
}
```

```console
# go get .
go: downloading github.com/gin-gonic/gin v1.7.7
go: downloading github.com/gin-contrib/sse v0.1.0
go: downloading github.com/mattn/go-isatty v0.0.12
go: downloading github.com/json-iterator/go v1.1.9
go: downloading github.com/ugorji/go/codec v1.1.7
go: downloading github.com/golang/protobuf v1.3.3
go: downloading gopkg.in/yaml.v2 v2.2.8
go: downloading github.com/go-playground/validator/v10 v10.4.1
go: downloading golang.org/x/sys v0.0.0-20200116001909-b77594299b42
go: downloading github.com/modern-go/concurrent v0.0.0-20180228061459-e0a39a4cb421
go: downloading github.com/modern-go/reflect2 v0.0.0-20180701023420-4b7aa43c6742
go: downloading github.com/ugorji/go v1.1.7
go: downloading github.com/go-playground/universal-translator v0.17.0
go: downloading github.com/leodido/go-urn v1.2.0
go: downloading golang.org/x/crypto v0.0.0-20200622213623-75b288015ac9
go: downloading github.com/go-playground/locales v0.13.0
go get: added github.com/gin-contrib/sse v0.1.0
go get: added github.com/gin-gonic/gin v1.7.7
go get: added github.com/go-playground/locales v0.13.0
go get: added github.com/go-playground/universal-translator v0.17.0
go get: added github.com/go-playground/validator/v10 v10.4.1
go get: added github.com/golang/protobuf v1.3.3
go get: added github.com/json-iterator/go v1.1.9
go get: added github.com/leodido/go-urn v1.2.0
go get: added github.com/mattn/go-isatty v0.0.12
go get: added github.com/modern-go/concurrent v0.0.0-20180228061459-e0a39a4cb421
go get: added github.com/modern-go/reflect2 v0.0.0-20180701023420-4b7aa43c6742
go get: added github.com/ugorji/go/codec v1.1.7
go get: added golang.org/x/crypto v0.0.0-20200622213623-75b288015ac9
go get: added golang.org/x/sys v0.0.0-20200116001909-b77594299b42
go get: added gopkg.in/yaml.v2 v2.2.8
```

```console
cat go.mod
module cdelgehier/learning_golang

go 1.17

require github.com/gin-gonic/gin v1.7.7

require (
        github.com/gin-contrib/sse v0.1.0 // indirect
        github.com/go-playground/locales v0.13.0 // indirect
        github.com/go-playground/universal-translator v0.17.0 // indirect
        github.com/go-playground/validator/v10 v10.4.1 // indirect
        github.com/golang/protobuf v1.3.3 // indirect
        github.com/json-iterator/go v1.1.9 // indirect
        github.com/leodido/go-urn v1.2.0 // indirect
        github.com/mattn/go-isatty v0.0.12 // indirect
        github.com/modern-go/concurrent v0.0.0-20180228061459-e0a39a4cb421 // indirect
        github.com/modern-go/reflect2 v0.0.0-20180701023420-4b7aa43c6742 // indirect
        github.com/ugorji/go/codec v1.1.7 // indirect
        golang.org/x/crypto v0.0.0-20200622213623-75b288015ac9 // indirect
        golang.org/x/sys v0.0.0-20200116001909-b77594299b42 // indirect
        gopkg.in/yaml.v2 v2.2.8 // indirect
)
```

## Generate API specs using GO / gin-swagger

refs:
  * https://githubhelp.com/swaggo/gin-swagger
  * https://golangrepo.com/repo/swaggo-swag-go-development-tools


Get more modules to generate docs
```shell
go get -u github.com/swaggo/swag/cmd/swag
go get -u github.com/swaggo/gin-swagger
go get -u github.com/swaggo/files
```

```console
# swag init
2021/12/05 00:25:05 Generate swagger docs....
2021/12/05 00:25:05 Generate general API Info, search dir:./
2021/12/05 00:25:05 Generating models.Product
2021/12/05 00:25:05 create docs.go at docs/docs.go
2021/12/05 00:25:05 create swagger.json at docs/swagger.json
2021/12/05 00:25:05 create swagger.yaml at docs/swagger.yaml
```

## Glang env Variables

Ref:
* https://dev.to/maelvls/why-is-go111module-everywhere-and-everything-about-go-modules-24k



