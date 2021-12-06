package models

// product represents data about an product.
type Product struct {
	ID    string  `json:"id" example:"1"`
	Brand string  `json:"brand" example:"Haribo"`
	Name  string  `json:"name" example:"Rotella"`
	Price float64 `json:"price" example:"13.90"`
}
