;; Use this to bootstrap emacs for basic lisp editing
(defun setup-for-lisp ()
  (interactive)
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

(defun property-name (prop) (car prop))

(defun property-value (prop) (cdr prop))

(defun is-property-named (name prop)
  (string-equal name (property-name prop)))

(defun attr-named (name node)
  (cdr (assq name node)))

(defun compound-name (compound)
  (let* ((name-nodes (xml-get-children compound 'name))
	 (first-name (car name-nodes)))
    (car (xml-node-children first-name))))

(defun compound-is-kind (kind compound)
  (let* ((compound-kind (attr-named 'kind compound)))
    (string-equal kind compound-kind)))

(defun compound-props (compound)
  (nth 0 compound))

(defun compound-prop (prop compound)
  (let* ((props (compound-props compound)))
    (cdr (assq prop props))))

(defun compound-kind (compound)
  (compound-prop 'kind compound))

(defun compound-refid (compound)
  (compound-prop 'refid compound))

(defun compound-name (compound)
  (car (last (split-string (nth 2 (nth 1 compound)) "::"))))

(defun compound-is-kind (kind compound)
  (let ((kind-name (compound-kind compound)))
    (string-equal kind kind-name)))

(defun record-for-compound (compound)
  (let ((kind (compound-kind compound))
	(refid (compound-refid compound))
	(name (compound-name compound)))
    (cons name (format "/%s.html" refid))))

(defun open-xml-file ()
  (require 'xml)
  (let* ((current-directory (file-name-directory (buffer-file-name)))
	 (xml-filename (concat current-directory "../src/zinnia-api-xml/index.xml"))
	 (root (xml-parse-file xml-filename))
	 (index (car root))
	 (compounds (seq-map (lambda (o) (list (nth 1 o) (nth 2 o))) (xml-get-children index 'compound)))
	 (valid-compounds (seq-filter (lambda (o) (or (compound-is-kind "class" o)
						      (compound-is-kind "interface" o))) compounds))
	 (records (seq-map 'record-for-compound valid-compounds)))
    records))

(setq records (open-xml-file))

(defun link-for-class (class-name)
  (cdr (assoc-string class-name records)))

;; Export org to html
(defun build-site ()
  (interactive)
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


