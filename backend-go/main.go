package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
)

func enableCORS(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next(w, r)
	}
}

func main() {
	http.HandleFunc("/api/posts", enableCORS(postsHandler))
	http.HandleFunc("/health", enableCORS(healthHandler))

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func postsHandler(w http.ResponseWriter, r *http.Request) {
	posts := []map[string]interface{}{
		{"id": 1, "title": "First Post", "body": "Hello from Go API!"},
		{"id": 2, "title": "DevOps Project", "body": "Working on DevOps platform"},
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(posts)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	json.NewEncoder(w).Encode(map[string]string{"status": "healthy", "service": "backend-go"})
}
