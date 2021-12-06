package main

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func TestListProducts(t *testing.T) {
	// Switch to test mode
	gin.SetMode(gin.TestMode)

	// Setup your router, like  did in the main function
	router := gin.Default()
	v1 := router.Group("/api/v1")
	{
		products := v1.Group("/products")
		{
			products.GET("", ListProducts)
		}
	}

	// Test the route as defined in api-server.go
	req, err := http.NewRequest(http.MethodGet, "/api/v1/products", nil)
	if err != nil {
		t.Fatalf("Couldn't create request: %v\n", err)
	}

	// Create a response recorder to inspect the response
	rec := httptest.NewRecorder()

	// Perform the request
	router.ServeHTTP(rec, req)
	// fmt.Println(rec.Body)

	// Check to see if the response was what you expected
	if rec.Code == http.StatusOK {
		t.Logf("Expected to get status %d is same as %d\n", http.StatusOK, rec.Code)
	} else {
		t.Fatalf("Expected to get status %d but instead got %d\n", http.StatusOK, rec.Code)
	}
}
