#!/usr/bin/env hy
;; Tests for the livestream transcriber in Hy

(import os)
(import sys)
(import unittest)
(import os.path)
(import tempfile)

(setv project-root (os.path.dirname (os.path.dirname (os.path.dirname (os.path.abspath __file__)))))
(when (not (in project-root sys.path))
  (sys.path.insert 0 project-root))

;; google.genai is a heavy optional dep; skip the import-dependent test if missing
(setv livestream-mod None)
(try
  (import src.livestream_transcriber :as livestream-mod)
  (except [ImportError]
    (print "NOTE: src.livestream_transcriber import skipped (missing dep)")))

(setv exists os.path.exists)
(setv join os.path.join)
(setv dirname os.path.dirname)

(defn test-paths []
  "Test that the expected file paths can be found"
  (setv src-path (join (dirname (dirname (dirname __file__))) "src" "livestream_transcriber.hy"))
  (assert (exists src-path) "livestream_transcriber.hy should exist")
  (print "All path tests passed!"))

(defn test-argparse []
  "Test argument parsing (requires google.genai)"
  (when (is livestream-mod None)
    (print "Argument parser test skipped (livestream module not importable)")
    (return))
  (setv parser (livestream-mod.setup-argparse))
  (assert parser "Argument parser should be created")
  (print "Argument parser test passed!"))

(defn main []
  (test-paths)
  (test-argparse)
  (print "All tests passed!"))

(when (= __name__ "__main__")
  (main))