#!/usr/bin/env hy
;; Tests for the paper summarizer in Hy

(import os)
(import unittest)
(import os.path)
(import tempfile)

(setv exists os.path.exists)
(setv join os.path.join)
(setv dirname os.path.dirname)
(setv NamedTemporaryFile tempfile.NamedTemporaryFile)

(defn test-paths []
  "Test that the expected file paths can be found"
  ;; Check if the Hy source exists
  (setv src-path (join (dirname (dirname (dirname __file__))) "src" "paper_summarizer.hy"))
  (assert (exists src-path) "paper_summarizer.hy should exist")
  
  ;; Check if prompt template exists
  (setv prompt-path (join (dirname (dirname (dirname __file__))) "prompts" "summarize-paper.md"))
  (assert (exists prompt-path) "summarize-paper.md should exist")
  
  ;; Check if papers directory exists (PDF fixtures are not checked into git)
  (setv papers-dir (join (dirname (dirname (dirname __file__))) "papers"))
  (assert (exists papers-dir) "papers directory should exist")

  (print "All path tests passed!"))

(defn main []
  (test-paths)
  (print "All tests passed!"))

(when (= __name__ "__main__")
  (main))