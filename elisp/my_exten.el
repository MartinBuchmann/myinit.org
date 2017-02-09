;; -*- Mode: Emacs-Lisp; coding: mac-roman -*-
;; Martins Emacs Erweiterung
;; Anpassung für Aquamacs Emacs
;;
;; Letzte Änderung
;; Time-stamp: <2016-09-25 12:56:37 Martin>
;;
;; Das meiste habe ich von Bob Glickstein gelernt :-)
;; Seitenangaben beziehen sich immer auf folgendes Buch:
;;
;; Bob Glickstein
;; "Writing GNU Emacs Extensions"
;; O'Reilly 1997
;;
;; Ich definiere hier nur Funktionen. Zuweisung auf
;; bestimmte Tastenkombinatione erfolgt in meiner
;; Preference.el
;;
;; Funktion 'other-window-backward'
;; erlaubt des Wechseln in den vorige Fenster
;; Kapitel 2, Seite 20
;; (defun other-window-backward (&optional n)
;;   "Select Nth previous window."
;;   (interactive "P")
;;   (other-window (- (prefix-numeric-value n))))

;; ;; Weist neue Funktionen Tastenkombination zu.
;; (global-set-key "\C-x\C-n" 'other-window)
;; ;; \C-x\C-n ist normalerweise
;; ;; 'set-goal-column zugeordent

;; (global-set-key "\C-x\C-p" 'other-window-backward)
;; ;; \C-x\C-p ist normalerweise
;; ;; 'mark-page zugeordent


;; Aliasdefinitionen
;; mit deutlicheren Namen
;; Kapitel 2, Seite 22
(defalias 'scroll-ahead  'scroll-down)
(defalias 'scroll-behind 'scroll-up)

;; Neue Funktionen zum zeilenweisen Scrollen
;; eines Puffers
(defun scroll-n-lines-ahead (&optional n)
  "Scroll ahead N line (1 by default)."
  (interactive "P")
  (scroll-ahead (prefix-numeric-value n)))

(defun scroll-n-lines-behind (&optional n)
  "Scroll behind N line (1 by default)."
  (interactive "P")
  (scroll-behind (prefix-numeric-value n)))

;; Weitere Funktionen zum Bewegen
;; innerhalb von Text
(defun point-to-top ()
  "Put point on top line of window"
  (interactive)
  (move-to-window-line 0))

(defun point-to-bottom ()
  "Put point at beginning of last visible line"
  (interactive)
  (move-to-window-line -1))

(defun line-to-top ()
  "move current line to top of window"
  (interactive)
  (recenter 0))

;; Funktions advice, das verhindert, daß
;; zu neuen Puffern gewechselt wird
;; Kapitel 2, Seite 30
(defadvice switch-to-buffer (before existing-buffer
			     activate compile)
  "When interactive, switch to existing buffers only,
unless given a prefix argument."
  (interactive
   (list (read-buffer "Switch to buffer: "
		      (other-buffer)
		      (null current-prefix-arg)))))

;; I found this in comp.emacs
;; <%udh6.218473$f36.8855477@news20.bellglobal.com>
;;
(defun word-count (start end)
  "Count characters, words, and lines in region.
  Although implemented with primitives, this is just
  count-lines-region plus the word count"
  (interactive "r")
  (let ((chars 0)
    (words 0)
    (lines 0)
    (in-word nil))
  (while (< start end)
  (incf chars)
  (cond ((= (char-after start) ?\n)
  (setq in-word nil)
  (incf lines))
  ((= (char-syntax (char-after start)) ?\ )
  (setq in-word nil))
  ((not in-word)
  (incf words)
  (setq in-word t)))
  (incf start))
  (message "%d Characters %d Words %d Lines" chars words lines)
  (list chars words lines)))

(defun kill-all-empty-lines ()
  "Delete lines that are all whitespace."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (delete-matching-lines "^\\s-*$")))

;; gefunden bei http://www.gnu.franken.de/ke/emacs/templates.html
;; Einfügen des aktuellen Datums
(defun insert-date ()
  "Insert the current date (ISO format)."
  (interactive "*")
  (insert
   (format-time-string "%Y-%m-%d")))

(defun insert-datum ()
  "Insert the current date (traditional german)."
  (interactive "*")
  (insert
   (format-time-string "%d.%m.%Y")))

;; Aus comp.emacs
;; löscht alle Leerzeichen
(defun delete-duplicate-spaces-from-region (start end)
  (interactive "r")
  (save-excursion
    (goto-char start)
    (while (re-search-forward " \+" end t)
      (delete-region (match-beginning 0) (match-end 0))
      (insert " "))))

(defun forward-delete-duplicate-spaces ()
  (interactive)
  (when (looking-at " \+")
    (delete-region (match-beginning 0) (match-end 0))
    (insert " ")))

(defadvice zap-to-char (after my-zap-to-char-advice (arg char) activate)
    "Kill up to the ARG'th occurence of CHAR, and leave CHAR.
  The CHAR is replaced and the point is put before CHAR."
    (insert char)
    (forward-char -1))

;; Einfügen von labeln in ref-tex
;; aus comp.emacs
(defun ums-reftex-immediate-label (&optional environment no-insert)
  (interactive)
  (let ((reftex-insert-label-flags (list nil nil)))
    (call-interactively 'reftex-label environment no-insert)))

;; Suchen des Wortes unter dem Cursor
(defun search-word-under-cursor ()
  "Performs a nonincremental-search-forward. The word at or near point
is the word to search for."
  (interactive)
  (let ((word (current-word)))
    (nonincremental-search-forward word)))

;; Länge des Wortes unter dem Cursor
(defun length-word-under-cursor ()
  "Returns the length of the current word."
  (interactive)
  (let* ((word (current-word))
	 (laenge (length (string-to-list word))))
    (message "%s has %d characters" word laenge))
  )

(defun search-selected-text ()
  "Performs a nonincremental-search-forward. The text in the current
region is what search for."
  (interactive)
  (let* (
        (start (min (point) (mark)))
        (end (max (point) (mark)))
        (word (buffer-substring start end))
        )
    (nonincremental-search-forward word)))

;; Aus comp.emacs
;; Message-ID: <87ejqh106r.fsf@david-steuber.com>
;; Umdrehen aller Wörter/Zeichen in einer Zeile
(defun reverse-string (s)
  (mapconcat 'string (nreverse (mapcar 'identity s)) ""))

(defun reverse-string-words (str)
  (mapconcat #'identity (nreverse (split-string str)) " "))

(defun reverse-line ()
  (interactive)
  (let* ((start (line-beginning-position))
         (end   (line-end-position))
         (line  (buffer-substring start end)))
    (delete-region start end)
    (insert (reverse-string line))))

(defun reverse-line-words ()
  (interactive)
  (let* ((start (line-beginning-position))
         (end   (line-end-position))
         (line  (buffer-substring start end)))
    (delete-region start end)
    (insert (reverse-string-words line))))

;; Aus dem Wiki :-)
(defun mac-open-terminal ()
  (interactive)
  (let ((dir ""))
    (cond
     ((and (local-variable-p 'dired-directory) dired-directory)
      (setq dir dired-directory))
     ((stringp (buffer-file-name))
      (setq dir (file-name-directory (buffer-file-name))))
     )
    (do-applescript
     (format "
     tell application \"Terminal\"
       activate
       try
         do script with command \"cd %s\"
       on error
         beep
       end try
     end tell" dir))
    ))

; Von Dove Young aus dem EmacsWiki
(defun insert-buffer-name ()
  "Insert current buffer name at point"
  (interactive) 
  (insert-string (buffer-name (current-buffer)))
  )

(provide 'my_exten)

;; End of my_exten.el
