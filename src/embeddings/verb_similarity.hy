#!/usr/bin/env hy
;;; French verb embedding similarity matrix
;;; Analyzes semantic relationships between 20 common French verbs

;; Standard imports
(import os sys json pickle csv)
(import tqdm)
(import dotenv)
(import math)
(import numpy :as np)
(import matplotlib.pyplot :as plt)

;; Load environment variables
(dotenv.load_dotenv)
(setv GOOGLE-API-KEY (os.getenv "GOOGLE_API_KEY"))

(when (not GOOGLE-API-KEY)
  (print "❌ Error: GOOGLE_API_KEY not found in environment!")
  (print "  Create a .env file with GOOGLE_API_KEY=your_api_key")
  (sys.exit 1))

;; Import Google GenAI
(try
  (import google.genai)
  (except [e ImportError]
    (print "❌ Error: google-genai package not installed!")
    (print "  Try: pip install google-genai==1.7.0")
    (sys.exit 1)))

(defn load-verbs [verbs-path]
  "Load verbs from a text file"
  (with [f (open verbs-path "r" :encoding "utf-8")]
    (lfor line (.readlines f)
          :if (and line (.strip line))
          (.strip line))))

(defn get-embedding-models [client]
  "Get available embedding models"
  (setv embedding-models [])
  (for [model (.list client.models)]
    (when (in "embedContent" model.supported-actions)
      (.append embedding-models model.name)))
  embedding-models)

(defn generate-verb-embeddings [client model-name verbs]
  "Generate embeddings for a list of verbs"
  (print f"Generating embeddings for {(len verbs)} verbs using {model-name}...")
  
  (setv embeddings {})
  (setv embed-method (getattr client.models "embed_content"))
  
  (for [verb (tqdm.tqdm verbs :desc "Processing verbs")]
    (try
      (setv response (embed-method 
                       :model model-name 
                       :contents [{"text" verb}]))
      (setv embedding-obj (get response.embeddings 0))
      (setv embedding-values (list embedding-obj.values))
      (setv (get embeddings verb) embedding-values)
      (except [e Exception]
        (print f"Error generating embedding for '{verb}': {e}")
        ;; Use a placeholder if embedding fails
        (setv (get embeddings verb) (list (repeat 0.0 768))))))
  
  embeddings)

(defn dot-product [a b]
  "Calculate dot product of two vectors"
  (setv result 0)
  (for [i (range (len a))]
    (+= result (* (get a i) (get b i))))
  result)

(defn magnitude [v]
  "Calculate vector magnitude"
  (math.sqrt (sum (map (fn [x] (* x x)) v))))

(defn cosine-similarity [a b]
  "Calculate cosine similarity between two vectors"
  (if (and (> (len a) 0) (> (len b) 0))
      (/ (dot-product a b) 
         (* (magnitude a) (magnitude b)))
      0.0))

(defn generate-similarity-matrix [embeddings]
  "Generate similarity matrix for all verb pairs"
  (setv verbs (list (.keys embeddings)))
  (setv n (len verbs))
  (setv matrix (np.zeros [n n]))
  
  (print "Calculating similarity matrix...")
  (for [i (range n)]
    (for [j (range n)]
      (setv verb1 (get verbs i))
      (setv verb2 (get verbs j))
      (setv emb1 (get embeddings verb1))
      (setv emb2 (get embeddings verb2))
      (setv similarity (cosine-similarity emb1 emb2))
      (setv (get matrix [i j]) similarity)))
  
  {"matrix" matrix "verbs" verbs})

(defn save-similarity-matrix [matrix verbs output-path]
  "Save the similarity matrix to a CSV file"
  (with [f (open output-path "w" :newline "" :encoding "utf-8")]
    (setv writer (csv.writer f))
    (.writerow writer [""] + verbs)  ;; Header row
    (for [i (range (len verbs))]
      (.writerow writer [(get verbs i)] + (list (get matrix [i]))))))

(defn plot-similarity-heatmap [matrix verbs output-path]
  "Plot similarity matrix as a heatmap"
  (plt.figure :figsize [10 8])
  (plt.imshow matrix :cmap "viridis")
  (plt.colorbar)
  
  ;; Label axes
  (plt.xticks (range (len verbs)) verbs :rotation 90)
  (plt.yticks (range (len verbs)) verbs)
  
  (plt.title "French Verb Semantic Similarity")
  (plt.tight-layout)
  (plt.savefig output-path)
  (plt.close))

(defn print-most-similar [matrix verbs]
  "Print the most similar verb pairs"
  (setv pairs [])
  (for [i (range (len verbs))]
    (for [j (range (+ i 1) (len verbs))]
      (setv verb1 (get verbs i))
      (setv verb2 (get verbs j))
      (setv similarity (get matrix [i j]))
      (.append pairs [verb1 verb2 similarity])))
  
  ;; Sort by similarity (descending)
  (setv sorted-pairs (sorted pairs :key (fn [x] (- (get x 2)))))
  
  (print "\n🔍 Most Similar Verb Pairs:")
  (for [pair (cut sorted-pairs 0 5)]
    (setv #(verb1 verb2 similarity) pair)
    (print f"• {verb1} — {verb2}: {(.format '{:.4f}' similarity)}")))

(defn print-least-similar [matrix verbs]
  "Print the least similar verb pairs"
  (setv pairs [])
  (for [i (range (len verbs))]
    (for [j (range (+ i 1) (len verbs))]
      (setv verb1 (get verbs i))
      (setv verb2 (get verbs j))
      (setv similarity (get matrix [i j]))
      (.append pairs [verb1 verb2 similarity])))
  
  ;; Sort by similarity (ascending)
  (setv sorted-pairs (sorted pairs :key (fn [x] (get x 2))))
  
  (print "\n🔍 Least Similar Verb Pairs:")
  (for [pair (cut sorted-pairs 0 5)]
    (setv #(verb1 verb2 similarity) pair)
    (print f"• {verb1} — {verb2}: {(.format '{:.4f}' similarity)}")))

(defn main []
  (print "🇫🇷 French Verb Embedding Analysis 🇫🇷")
  (print "====================================")
  
  ;; Set paths
  (setv repo-root (os.path.dirname (os.path.dirname (os.path.dirname __file__))))
  (setv verbs-path (os.path.join repo-root "resources" "verbs" "test_french_verbs.txt"))
  (setv output-dir (os.path.join repo-root "data" "embeddings"))
  (os.makedirs output-dir :exist_ok True)
  
  ;; Load verbs
  (setv verbs (load-verbs verbs-path))
  (print f"Loaded {(len verbs)} French verbs:")
  (print (.join ", " verbs))
  
  ;; Initialize Google GenAI client
  (setv client (google.genai.Client :api-key GOOGLE-API-KEY))
  
  ;; Get embedding models
  (setv embedding-models (get-embedding-models client))
  (if (not embedding-models)
      (do
        (print "❌ No embedding models available!")
        (sys.exit 1))
      (do
        (print "Available embedding models:")
        (for [model embedding-models]
          (print f"• {model}"))))
  
  ;; Use first available model
  (setv model-name (get embedding-models 0))
  (print f"Using model: {model-name}")
  
  ;; Generate embeddings
  (setv embeddings-json-path (os.path.join output-dir "french_verb_embeddings_full.json"))
  (setv embeddings-pkl-path (os.path.join output-dir "french_verb_embeddings_full.pkl"))
  
  ;; Check if we already have embeddings
  (if (and (os.path.exists embeddings-json-path)
           (os.path.exists embeddings-pkl-path))
      (do
        (print "Loading cached embeddings...")
        (with [f (open embeddings-pkl-path "rb")]
          (setv embeddings (pickle.load f))))
      (do
        ;; Generate new embeddings
        (setv embeddings (generate-verb-embeddings client model-name verbs))
        
        ;; Save embeddings
        (print "Saving embeddings...")
        (with [f (open embeddings-json-path "w" :encoding "utf-8")]
          (json.dump embeddings f :ensure_ascii False :indent 2))
        (with [f (open embeddings-pkl-path "wb")]
          (pickle.dump embeddings f))))
  
  ;; Generate similarity matrix
  (setv similarity-data (generate-similarity-matrix embeddings))
  (setv similarity-matrix (get similarity-data "matrix"))
  (setv matrix-verbs (get similarity-data "verbs"))
  
  ;; Save similarity matrix as CSV
  (setv csv-path (os.path.join output-dir "verb_similarity_matrix.csv"))
  (save-similarity-matrix similarity-matrix matrix-verbs csv-path)
  (print f"Similarity matrix saved to {csv-path}")
  
  ;; Visualize similarity matrix
  (setv plot-path (os.path.join output-dir "verb_similarity_heatmap.png"))
  (plot-similarity-heatmap similarity-matrix matrix-verbs plot-path)
  (print f"Similarity heatmap saved to {plot-path}")
  
  ;; Print most/least similar pairs
  (print-most-similar similarity-matrix matrix-verbs)
  (print-least-similar similarity-matrix matrix-verbs)
  
  (print "\n✅ French verb embedding analysis complete!")
  
  ;; Print location of output files
  (print "\nOutput files:")
  (print f"• Embeddings: {embeddings-json-path}")
  (print f"• Similarity matrix: {csv-path}")
  (print f"• Visualization: {plot-path}"))

(when (= __name__ "__main__")
  (main))