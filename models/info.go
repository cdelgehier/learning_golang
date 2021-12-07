package models

import "time"

// This structure may contain more info in the future
type Ping struct {
	Pong time.Time `json:"pong" example:"2021-10-31 16:13:58.292387 +0000 UTC"`
}
