#!/usr/bin/env hy

(import os)
(import requests)
(import json)

(defn test-ollama []
  "Test Ollama API with a Scheme interpreter request"
  (setv url (or (os.environ.get "OLLAMA_URL")
                "http://192.168.86.22:11434/api/chat"))
  (setv payload 
    {"model" "llama3.2:latest"
     "messages" [
       {"role" "system" "content" "You are a Scheme interpreter that evaluates Scheme expressions."}
       {"role" "user" "content" "As a scheme interpreter, evaluate: (map inc '(1 2 (+ 1 1 2)))"}
     ]
     "stream" False})
  
  (try
    (setv response (requests.post url :json payload))
    (if (= response.status-code 200)
      (do
        (print "Success!")
        (print "Response content:")
        (print (. response text)))
      (do
        (print f"Error: {response.status-code}")
        (print (. response text))))
    (except [e Exception]
      (print f"Exception: {e}"))))

(when (= __name__ "__main__")
  (test-ollama))