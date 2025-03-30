;; 5D-GAI Intensive Emacs Configuration
;; Support for Org-mode, Hy, IPython and Restclient

;; Package setup
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Ensure required packages are installed
(unless package-archive-contents
  (package-refresh-contents))

(dolist (pkg '(restclient ob-restclient hy-mode))
  (unless (package-installed-p pkg)
    (package-install pkg)))

;; Minimal Org-mode configuration for tangling
(require 'org)
(setq org-confirm-babel-evaluate nil)
(setq org-src-fontify-natively t)
(setq org-src-tab-acts-natively t)
(setq org-edit-src-content-indentation 0)
(setq org-src-preserve-indentation t)
(setq org-startup-folded 'content)

;; Org babel languages - extended set
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (shell . t)
   (emacs-lisp . t)
   (restclient . t)))

;; Add support for Hy language
(add-to-list 'org-src-lang-modes '("hy" . hy))

;; Restclient configuration
(require 'restclient)
(require 'ob-restclient)

;; Helper function to insert API key from environment
(defun restclient-insert-api-key ()
  "Insert the API key from environment variables"
  (interactive)
  (let ((api-key (getenv "AI_STUDIO_API_KEY")))
    (if api-key
        (insert api-key)
      (message "API key not found in environment"))))

;; Key binding for inserting API key
(define-key restclient-mode-map (kbd "C-c C-k") 'restclient-insert-api-key)

;; Load .env file and set environment variables
(defun load-dotenv-file ()
  "Load environment variables from .env file"
  (interactive)
  (let ((dotenv-file (expand-file-name ".env")))
    (when (file-exists-p dotenv-file)
      (with-temp-buffer
        (insert-file-contents dotenv-file)
        (goto-char (point-min))
        (while (re-search-forward "^\\([A-Za-z0-9_]+\\)=\\(.*\\)" nil t)
          (let ((key (match-string 1))
                (value (match-string 2)))
            (setenv key value)
            (message "Set %s=%s" key value)))))))

;; Load .env when opening the project
(add-hook 'after-init-hook 'load-dotenv-file)

;; IPython integration
(setq python-shell-interpreter "poetry"
      python-shell-interpreter-args "run ipython -i --simple-prompt")

;; Define a function to run Hy code through IPython
(defun org-babel-execute:hy (body params)
  "Execute a block of Hy code with IPython."
  (let ((org-babel-python-command "poetry run ipython -c 'import hy; hy.eval(\"\"\""))
    (org-babel-execute:python (concat body "\"\"\"')") params)))

;; Custom functions for org-based workflows
(defun org-tangle-files-in-dir (dir &optional exclude)
  "Tangle all org files in DIR, excluding any files matching EXCLUDE regex."
  (interactive "DDirectory: ")
  (let ((files (directory-files dir t "\\.org$")))
    (dolist (file files)
      (when (and (not (string-match-p (or exclude "") file))
                 (file-regular-p file))
        (org-babel-tangle-file file)))))

;; Auto-tangling on save
(defun org-babel-auto-tangle ()
  "Automatically tangle org files when saving."
  (when (eq major-mode 'org-mode)
    (let ((org-confirm-babel-evaluate nil))
      (when (member "tangle" (org-get-tags))
        (org-babel-tangle)))))

(add-hook 'after-save-hook 'org-babel-auto-tangle)

;; Keybindings
(global-set-key (kbd "C-c o t") 'org-babel-tangle)
(global-set-key (kbd "C-c o d") 'org-babel-detangle)
(global-set-key (kbd "C-c o e") 'org-export-dispatch)
(global-set-key (kbd "C-c o j") 'org-babel-execute-src-block)

;; Project-specific setup
(setq org-publish-project-alist
      '(("5dgai-intensive"
         :base-directory "."
         :publishing-directory "./public"
         :publishing-function org-html-publish-to-html
         :recursive t
         :with-toc t
         :section-numbers nil)))

(provide 'init)