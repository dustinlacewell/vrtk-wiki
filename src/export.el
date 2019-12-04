;; Use this to bootstrap emacs for basic lisp editing
(progn 
  (require 'package)
  (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
  (setq package-list '(lispy))
  (package-initialize)
  (unless package-archive-contents
    (package-refresh-contents))
  (dolist (package package-list)
    (unless (package-installed-p package)
      (package-install package)))
  (show-paren-mode 1)
  (setq show-paren-delay 0))

;; Export org to html
(progn
  (defun get-string-from-file (filePath)
    "Return filePath's file content."
    (with-temp-buffer
      (insert-file-contents filePath)
      (buffer-string)))

  (let ((current-directory (file-name-directory (buffer-file-name)))
	(html-head (get-string-from-file "head.html")))
    (setq org-html-preamble "<h1><a href=\"/vrtk-wiki/\">VRTK Wiki</a></h1>")
    (setq org-publish-project-alist
	  `(("docs"
	     :base-directory ,current-directory
	     :publishing-directory ,(concat current-directory "../docs/")
	     :publishing-function org-html-publish-to-html
	     :html-head ,html-head
	     :with-todo-keywords nil
	     :section-numbers nil
	     )))
    (org-publish-project "docs" t)))


