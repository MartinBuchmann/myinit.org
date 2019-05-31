;;;; init.el
;; Time-stamp: <2019-05-31 21:28:08 Martin>
;;
;; Inspiriert von:
;;
;; https://yiufung.net/post/pure-emacs-lisp-init-skeleton/
;;
;;----------------------------------------------------------------------------
;; Ich habe versucht alles hier zu konfigurieren, d.h. soweit wie möglich auf
;; das custom-Interface zu verzichten, um alles in einer Datei zu haben.
;; ---------------------------------------------------------------------------
;;; Speed up startup
(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6)
(add-hook 'after-init-hook
          `(lambda ()
             (setq gc-cons-threshold 800000
                   gc-cons-percentage 0.1)
             (garbage-collect)) t)
;;----------------------------------------------------------------------------
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))

(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)

(package-initialize)

;;----------------------------------------------------------------------------
;; Bootstrap `use-package`
(setq-default use-package-always-ensure t ; Auto-download package if not exists
              use-package-always-defer t  ; Always defer load package to speed up startup
              use-package-verbose nil     ; Don't report loading details
              use-package-expand-minimally t      ; Make the expanded code as minimal as possible
              use-package-enable-imenu-support t) ; Let imenu finds use-package definitions
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))

;;----------------------------------------------------------------------------
(message "Dies ist Martins init.el")
;;----------------------------------------------------------------------------
;;; Gleich zu Beginn unnötige Anzeigen abstellen.
(when window-system
  (menu-bar-mode 1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (tooltip-mode -1))

;; Immer neuere Dateien laden
(setq load-prefer-newer t)

;;; Benchmark-init
;; https://github.com/dholm/benchmark-init-el.git
(add-to-list 'load-path "~/.emacs.d/elisp/benchmark-init-el")
(require 'benchmark-init-loaddefs)
(benchmark-init/activate)

;;; For some simple debugging
(require 'cl)
(defvar mb/section-counter 0
  "A counter for the Section of my config, for debugging mostly")

(defun mb/sections ()
  "A simple message function for chekcing the loading of my config."
  (message "Section %d loaded" mb/section-counter)
  (incf mb/section-counter))

;; Output of the current section number to the *Message* buffer 
(mb/sections)

;; I have to define this variable here already to make sure it is changed
;; correctly. Not sure if it is a bug or just a interference with org-babel...
(defvar outline-minor-mode-prefix "\M-#")

(mb/sections)

;; Nachdem Update auf Emacs 26 hatte ich vereinzelt Probleme mit veralteten
;; Pakete. Diese Funktion gibt einen spezifischen Fehler aus, der hilft den
;; Übeltäter zu identifizieren.
;; https://emacs.stackexchange.com/questions/42343/package-html2text-is-obsolete

(defun debug-on-load-obsolete (filename)
  (when (equal (car (last (split-string filename "[/\\]") 2))
               "obsolete")
    (debug)))
;; (add-to-list 'after-load-functions #'debug-on-load-obsolete)

;;----------------------------------------------------------------------------
;;; Outshine
(use-package outshine
  :diminish 'outshine-mode
  :init
  (defvar outline-minor-mode-prefix "\M-#")
  :config
  (setq outshine-use-speed-commands t)
  :hook
  ((emacs-lisp-mode lisp-mode) . outshine-mode))

;;----------------------------------------------------------------------------
;;; Mein eigener Pfad für Erweiterungen
(setq load-path
      (mapcar 'expand-file-name
              (append '("~/.emacs.d/elisp"
                        "~/.emacs.d/elisp/slime-repl-ansi-color"
                        "~/.emacs.d/elisp/commoji.el"
                        "~/.emacs.d/elisp/move-lines"
                        "~/.emacs.d/elisp/prettify-utils.el")
                      load-path)))

(setenv "INFOPATH"
        (concat (getenv "INFOPATH") ":"
                (expand-file-name "/opt/local/share/info/")))

;;----------------------------------------------------------------------------
;;; Sicherheit
(setq epa-file-cache-passphrase-for-symmetric-encryption t)
(setq auth-sources
            '((:source "~/.emacs.d/secrets/.authinfo.gpg")))

;;----------------------------------------------------------------------------
;;; Das Customize-Interface
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)
(mb/sections)

;;----------------------------------------------------------------------------
;;; Grundlegende Einstellungen
;;
;; Wie der Name schon sagt, Grundlegendes, das zu Beginn und global geregelt werden soll.
(setq-default inhibit-startup-message t
              initial-scratch-message nil)

(fset 'yes-or-no-p 'y-or-n-p)

;; Hebt Klammern paarweise hervor
(show-paren-mode t)
(setq show-paren-delay 0.0)
(setq-default indicate-empty-lines t)

(setq visible-bell t)
(setq ring-bell-function 'ignore)

(setq-default fill-column 80)

;; auto revert mode
(global-auto-revert-mode 1)

;; auto refresh dired when file changes
(add-hook 'dired-mode-hook 'auto-revert-mode)
(mb/sections)

(setq initial-major-mode 'emacs-lisp-mode)     ; *scratch* shows up in emacs-lisp-mode

(setq cursor-type (quote (box)))        ; box cursor
(put 'downcase-region 'disabled nil)    ; Erlaubt up/downcase Befehle
(put 'upcase-region 'disabled nil)
(put 'scroll-left 'disabled nil)        ; Erlaubt horizontales Scrollen
(put 'narrow-to-region 'disabled nil)   ; Erlaubt narrow/wide

;;----------------------------------------------------------------------------
;;; Abkürzungen einschalten
(setq-default abbrev-mode t)
(diminish 'abbrev-mode)
(setq save-abbrevs t)
(setq abbrev-file-name "~/.emacs.d/abbrev_defs")
;; Datei mit Abkürzungen laden
(read-abbrev-file "~/.emacs.d/abbrev_defs")

;;----------------------------------------------------------------------------
;;; Automatische Korrekur von regelmäßigen Tippfehlern
;;
;; http://endlessparentheses.com/ispell-and-abbrev-the-perfect-auto-correct.html
;;
(defun endless/simple-get-word ()
  (car-safe (save-excursion (ispell-get-word nil))))

(defun endless/ispell-word-then-abbrev (p)
  "Call `ispell-word', then create an abbrev for it.
With prefix P, create local abbrev. Otherwise it will
be global.
If there's nothing wrong with the word at point, keep
looking for a typo until the beginning of buffer. You can
skip typos you don't want to fix with `SPC', and you can
abort completely with `C-g'."
  (interactive "P")
  (let (bef aft)
    (save-excursion
      (while (if (setq bef (endless/simple-get-word))
                 ;; Word was corrected or used quit.
                 (if (ispell-word nil 'quiet)
                     nil ; End the loop.
                   ;; Also end if we reach `bob'.
                   (not (bobp)))
               ;; If there's no word at point, keep looking
               ;; until `bob'.
               (not (bobp)))
        (backward-word)
        (backward-char))
      (setq aft (endless/simple-get-word)))
    (if (and aft bef (not (equal aft bef)))
        (let ((aft (downcase aft))
              (bef (downcase bef)))
          (define-abbrev
            (if p local-abbrev-table global-abbrev-table)
            bef aft)
          (message "\"%s\" now expands to \"%s\" %sally"
                   bef aft (if p "loc" "glob")))
      (user-error "No typo at or before point"))))

;;----------------------------------------------------------------------------
;;; Wo sollen Backup-Dateien gespeichert werden?
;;
(defconst use-backup-dir t)             ; use backup directory
(setq make-backup-files t)
(setq backup-directory-alist (quote ((".*" . "~/.emacs.d/backups"))))
(mb/sections)

;;----------------------------------------------------------------------------
;;; Umgebungsvariablen, Mac-Spezifika, etc.
;;
(when window-system
  ;; Startet einen Server, um sich mit emacsclient verbinden zu können.
  (server-start) 

  ;; exchanging clipboard content with other applications
  (setq select-enable-clipboard t))

;; https://github.com/purcell/exec-path-from-shell
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize)

  (setq ns-command-modifier 'meta         ; Apple/Command key is Meta
        ns-alternate-modifier nil         ; Option is the Mac Option key
        ns-use-mac-modifier-symbols  nil) ; display standard Emacs modifier symbols

  (setq locate-command "mdfind") ; Use Mac OS X's Spotlight
  (global-set-key (kbd "C-c f l") 'locate)

  ;; https://github.com/chrisbarrett/osx-bbdb
  (when (equal system-type 'darwin)
    (require 'osx-bbdb)))

(setq delete-by-moving-to-trash t
      trash-directory "~/.Trash/emacs")

(setq shell-file-name           "bash")
(setq sh-shell-file             "/bin/bash")
(setq tex-shell-file-name       "bash")

(setq user-full-name "Martin Buchmann")
(setq user-login-name "Martin")
(setq user-mail-address "Martin.Buchmann@gmail.com")
(setq smtpmail-smtp-user "Martin.Buchmann")

(setq calendar-latitude 50.9271)
(setq calendar-longitude 11.5892)
(setq calendar-location-name "Jena, Germany")

(setq calendar-time-zone +60)
(setq calendar-standard-time-zone-name "CET")
(setq calendar-daylight-time-zone-name "CEST")

(setq bookmark-default-file (expand-file-name "~/.emacs.d/emacs.bmk"))

(mb/sections)
;;----------------------------------------------------------------------------
;;; Grundlegennde Paktete
;;
(use-package f)

(use-package dash)

;; (use-package diminish)

;;;; Beginnend
(use-package beginend
  :config
  (beginend-global-mode))

;;;; Move where I mean
(use-package mwim
  :bind
  ("C-a" . mwim-beginning-of-code-or-line)
  ("C-e" . 'mwim-end-of-code-or-line)
  ("<home>" . 'mwim-beginning-of-line-or-code)
  ("<end>" . 'mwim-end-of-line-or-code))

;;;; Alert
(use-package alert
  :config
  (setq alert-default-style 'osx-notifier))

;;;; Which-key?
(use-package which-key
  :diminish which-key-mode
  :config
  (which-key-mode))

;;;; Expand region
(use-package expand-region
  :bind
  ("C-*" . er/expand-region))

;;; Shift numbers
(use-package shift-number
  :bind
  ("M-+" . shift-number-up)
  ("M--" . shift-number-down))

;;;; Undo tree
(use-package undo-tree
  :diminish undo-tree-mode
  :init
  (global-undo-tree-mode)
  :config
  (with-eval-after-load 'undo-tree
    (define-key undo-tree-map (kbd "<S-wheel-down>") 'undo-tree-redo)
    (define-key undo-tree-map (kbd "<S-wheel-up>") 'undo-tree-undo)))

;;;; Autovervollständigung
(use-package auto-complete
  :diminish auto-complete-mode
  :config
  (ac-config-default)
  (global-auto-complete-mode t)
  (setq ac-auto-start 4)
  (setq ac-auto-show-menu 0.8)
  (setq ac-use-menu-map t))

(use-package ac-emoji
  :config
  (add-hook 'markdown-mode-hook 'ac-emoji-setup)
  (add-hook 'git-commit-mode-hook 'ac-emoji-setup)
  (set-fontset-font
   t 'symbol
   (font-spec :family "Apple Color Emoji") nil 'prepend))

;;;; Die zuletzt verwendeten Dateien
(use-package recentf
  :init
  (setq recentf-max-menu-items 25
        recentf-auto-cleanup 'never
        recentf-keep '(file-remote-p file-readable-p))
  (recentf-mode 1)
  :config
  (add-to-list 'recentf-exclude (format "%s/\\.emacs\\.d/elpa/.*" (getenv "HOME")))
  (add-to-list 'recentf-exclude "/var/.*")
  :bind ("C-c f f" . recentf-open-files))

;;; Dired
(setq insert-directory-program "/opt/local/bin/gls")
(setq dired-listing-switches "-aBhl --group-directories-first")
(setq dired-dwim-target t)

(setq diredp-hide-details-initially-flag nil)
(require 'dired+)
(toggle-diredp-find-file-reuse-dir 1)

;;;; Dired quick sort 
(use-package dired-quick-sort
  :config
  (dired-quick-sort-setup))

;;;; Dired narrow
(use-package dired-narrow
  :config
  (bind-key "C-c C-n" #'dired-narrow)
  (bind-key "C-x C-N" #'dired-narrow-regexp))
  (bind-key "C-c C-f" #'dired-narrow-fuzzy)

;;;; Dired subtree
(use-package dired-subtree
  :after dired
  :config
  (bind-key "<tab>" #'dired-subtree-toggle dired-mode-map)
  (bind-key "<backtab>" #'dired-subtree-cycle dired-mode-map))

;;;; Dired sidebar
(use-package dired-sidebar
  :bind ("C-x C-n" . dired-sidebar-toggle-sidebar)
  :commands (dired-sidebar-toggle-sidebar)
  :init
  (add-hook 'dired-sidebar-mode-hook
            (lambda ()
              (unless (file-remote-p default-directory)
                (auto-revert-mode))))
  :config
  (push 'toggle-window-split dired-sidebar-toggle-hidden-commands)
  (push 'rotate-windows dired-sidebar-toggle-hidden-commands)

  (setq dired-sidebar-subtree-line-prefix "__")
  (setq dired-sidebar-theme 'icons)
  (setq dired-sidebar-use-term-integration t)
  (setq dired-sidebar-use-custom-font t))

;;;; Dired rysnc
(use-package dired-rsync
  :custom
  (dired-rsync-command "/opt/local/bin/rsync")
  :config
  (bind-key "C-c C-r" 'dired-rsync dired-mode-map))

;;; PDF tools
(use-package pdf-tools
  :init
  (pdf-tools-install))

;;; Define word
(use-package define-word)

;; https://github.com/abo-abo/define-word/issues/16
;; TODO: Umlaute komplett dekodieren
(defun de-escape (string)
  "Replaces html encoded umlauts with their proper character."
  (let ((replacements '(("&Auml;" "Ä")
                        ("&auml;" "ä")
                        ("&Eacute;" "É")
                        ("&eacute;" "é")
                        ("&Ouml;" "Ö")
                        ("&ouml;" "ö")
                        ("&Uuml;" "Ü")
                        ("&uuml;" "ü")
                        ("&szlig;" "ß")
                        ("\303\244" "ä")
                        ("\342\200\236" "„")
                        ("\342\200\234" "“")
                        ("\303\237" "ß")
                        ("\303\274" "ü")
                        ("\303\266" "ö")))
        (case-fold-search nil))
    (with-temp-buffer
      (insert string)
      (dolist (replacement replacements)
        (cl-destructuring-bind (old new) replacement
          (goto-char (point-min))
          (while (search-forward old nil t)
            (replace-match new))))
      (buffer-string))))

(defun define-word--parse-openthesaurus ()
  "Parse output from openthesaurus site and return formatted list"
  (save-match-data
    (let (results part beg)
      (goto-char (point-min))
      (nxml-mode)
      (while (re-search-forward "<sup>" nil t)
        (goto-char (match-beginning 0))
        (setq beg (point))
        (nxml-forward-element)
        (delete-region beg (point)))
      (goto-char (point-min))
      (while (re-search-forward
              "<span class='wiktionaryItem'> [0-9]+.</span>\\([^<]+\\)<" nil t)
        (setq part (match-string 1))
        (backward-char)
        (push (string-trim part) results))
      (setq results (nreverse results))
      (if (= 0 (length results))
          (message "0 definitions found")
        (when (> (length results) define-word-limit)
          (setq results (cl-subseq results 0 define-word-limit)))
        (mapconcat #'de-escape results "\n")))))

;;; Multiple cursors
(use-package multiple-cursors
  :bind
  ("C->" . mc/mark-next-like-this)
  ("C-<" . mc/mark-previous-like-this)
  ("C-c C-<" . mc/mark-all-like-this)
  :init
  (defhydra multiple-cursors-hydra (:hint nil)
    "
       ^Up^            ^Down^        ^Other^
  ----------------------------------------------
  [_p_]   Previous    [_n_]   Next    [_l_] Edit lines
  [_P_]   Skip        [_N_]   Skip    [_a_] Mark all
  [_M-p_] Unmark      [_M-n_] Unmark  [_r_] Mark by regexp
  ^ ^                 ^ ^             [_q_] Quit
  "
    ("l" mc/edit-lines :exit t)
    ("a" mc/mark-all-like-this :exit t)
    ("n" mc/mark-next-like-this)
    ("N" mc/skip-to-next-like-this)
    ("M-n" mc/unmark-next-like-this)
    ("p" mc/mark-previous-like-this)
    ("P" mc/skip-to-previous-like-this)
    ("M-p" mc/unmark-previous-like-this)
    ("r" mc/mark-all-in-region-regexp :exit t)
    ("q" nil)

    ("<mouse-1>" mc/add-cursor-on-click)
    ("<down-mouse-1>" ignore)
    ("<drag-mouse-1>" ignore)))

(use-package ace-mc
  :bind
  (("C-ß" . ace-mc-add-multiple-cursors)
   ("C-M-ß" . ace-mc-add-single-cursor)))

(mb/sections)
;;----------------------------------------------------------------------------
;;; Counsel
(use-package counsel
  :bind
  (("M-x" . counsel-M-x)
   ("M-y" . counsel-yank-pop)
   ("C-x C-f" . counsel-find-file)
   ("C-x r b" . counsel-bookmark)
   ("M-i" . counsel-imenu)
   ("C-c g" . counsel-git)
   ("C-c j" . counsel-git-grep)
   ("C-c k" . counsel-rg)
   ("C-c K" . counsel-ag)
   ("C-x l" . counsel-locate)
   :map ivy-minibuffer-map
   ("M-y" . ivy-next-line))
  :config
  (setq counsel-git-cmd "rg --files")
  (setq counsel-rg-base-command
        "rg -i -M 120 --no-heading --line-number --color never %s ."))

;;; Swiper
(use-package swiper)

;;; Ivy
(use-package ivy
  :diminish ivy-mode
  :bind
  (("C-c C-r" . ivy-resume)
   ("C-s" . swiper-isearch)
   ("C-r" . swiper)
   ("C-x b" . ivy-switch-buffer))
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-use-selectable-prompt t)
  (define-key read-expression-map (kbd "C-r") 'counsel-expression-history))

(use-package ivy-rich
  :demand t
  :config
  (ivy-rich-mode 1)
  (setq ivy-format-function #'ivy-format-function-line))

(use-package ivy-prescient
  :demand t
  :config
  (ivy-prescient-mode t)
  (prescient-persist-mode t)
  (setq ivy-re-builders-alist
        '((swiper . ivy--regex)
          (counsel-ag . ivy--regex-plus)
          (counsel-rg . ivy--regex-plus)
          (t      . ivy-prescient-re-builder))))

(use-package ivy-hydra
  :init 
  (global-set-key
   (kbd "C-x t")
   (defhydra toggle (:color blue)
     "toggle"
     ("a" abbrev-mode "abbrev")
     ("s" flyspell-mode "flyspell")
     ("d" toggle-debug-on-error "debug")
     ("f" auto-fill-mode "fill")
     ("t" toggle-truncate-lines "truncate")
     ("v" visual-line-mode "visual line")
     ("w" whitespace-mode "whitespace")
     ("q" nil "cancel")))
  (global-set-key
   (kbd "C-x j")
   (defhydra gotoline 
     ( :pre (linum-mode 1)
            :post (linum-mode -1))
     "goto"
     ("t" (lambda () (interactive)(move-to-window-line-top-bottom 0)) "top")
     ("b" (lambda () (interactive)(move-to-window-line-top-bottom -1)) "bottom")
     ("m" (lambda () (interactive)(move-to-window-line-top-bottom)) "middle")
     ("e" (lambda () (interactive)(end-of-buffer)) "end")
     ("c" recenter-top-bottom "recenter")
     ("n" next-line "down")
     ("p" (lambda () (interactive) (forward-line -1))  "up")
     ("g" goto-line "goto-line")
     )))

(mb/sections)

;;; Avy
(use-package avy
  :config
  (avy-setup-default)
  :bind
  (("C-:" . avy-goto-char)
   ("M-g w" . avy-goto-word-1)
   ("M-g f" . avy-goto-line)
   ("M-g h" . avy-org-goto-heading-timer)))

;;; Ace window
(use-package ace-window
  :bind
  ("M-o" . ace-window))

;;; Ace jump zap
(use-package ace-jump-zap
  :bind
  ("M-Z" . ace-jump-zap-to-char)
  ("M-z" . ace-jump-zap-up-to-char))

;;; Readline completion
(use-package readline-complete
  :config
  (progn
   (setq explicit-shell-file-name "bash")
   (setq explicit-bash-args '("-c" "export EMACS=; stty echo; bash"))
   (setq comint-process-echoes t)
   (add-to-list 'ac-modes 'shell-mode)
   (add-hook 'shell-mode-hook 'ac-rlc-setup-sources)))

;;----------------------------------------------------------------------------
;;; Org mode
;;;; Allgemeine Tastenbelegung
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)

(setq org-use-speed-commands t)

;;;; Allgemeine Einstellungen
(setq org-directory "~/Dropbox/orgfiles")
(setq org-default-notes-file (concat org-directory "/Notes.org"))

(setq org-agenda-files (list "~/Dropbox/orgfiles/Martin.org"
                             "~/Dropbox/orgfiles/Notes.org"
                             "~/Dropbox/orgfiles/beorg.org"
                             "~/Dropbox/orgfiles/binnova.org"))
;; Zusätzlich inspiriert durch
;; http://lists.gnu.org/archive/html/emacs-orgmode/2010-11/msg01351.html
(setq org-refile-targets '((nil :maxlevel . 2)
                                ; all top-level headlines in the
                                ; current buffer are used (first) as a
                                ; refile target
                           (org-agenda-files :maxlevel . 2)))
(setq org-refile-allow-creating-parent-nodes 'confirm)
(setq org-refile-use-outline-path 'file)
(setq org-outline-path-complete-in-steps nil)
;; refile only within the current buffer
(defun my/org-refile-within-current-buffer ()
  "Move the entry at point to another heading in the current buffer."
  (interactive)
  (let ((org-refile-targets '((nil :maxlevel . 5))))
    (org-refile)))

(setq org-export-html-postamble nil)

(add-hook 'org-mode-hook 'turn-on-org-cdlatex)
(setq org-highlight-latex-and-related '(latex))

(setq org-display-inline-images t)
(setq org-redisplay-inline-images t)
(setq org-startup-with-inline-images "inlineimages")

(setq org-startup-folded (quote overview))
(setq org-startup-indented t)
(setq org-src-tab-acts-natively t)
(setq org-src-window-setup 'current-window)

(require 'org-tempo)
(add-to-list 'org-structure-template-alist
             '("el" . "src emacs-lisp"))

;;;; Eisenhower-Matrix
;; https://www.tompurl.com/2015-12-29-emacs-eisenhower-matrix.html

(setq org-tag-alist '(("@Arbeit" . ?a) ("@Zuhause" . ?z)
                      ("Hobby" . ?h) ("Reichardtstieg" . ?r) ("Anrufe" . ?A)
                      ("Wichtig" . ?w) ("Dringend" . ?d)))


;;;; Meine eigenen Agenda-Ansichten
(setq org-agenda-custom-commands
        '(("h" "Was liegt heute an?"
           ((tags-todo "Dringend"
                       ((org-agenda-overriding-header "Dringende Aufgaben")
                        (org-agenda-files
                         '("~/Dropbox/orgfiles/Martin.org" "~/Dropbox/orgfiles/Notes.org"
                           "~/Dropbox/orgfiles/beorg.org" "~/Dropbox/orgfiles/binnova.org"))))
            (tags-todo "Anrufe"
                       ((org-agenda-overriding-header "Anrufe")
                        (org-agenda-files
                         '("~/Dropbox/orgfiles/Martin.org" "~/Dropbox/orgfiles/Notes.org"
                           "~/Dropbox/orgfiles/beorg.org" "~/Dropbox/orgfiles/binnova.org"))))
            (agenda  ""
                       ((org-agenda-overriding-header "Heute")
                        (org-agenda-files
                         '("~/Dropbox/orgfiles/Martin.org" "~/Dropbox/orgfiles/Notes.org"
                           "~/Dropbox/orgfiles/beorg.org" "~/Dropbox/orgfiles/binnova.org"))
                         (org-agenda-span 'day)
                         (org-agenda-sorting-stragety '(time-up priority-down))))))
          ("c" "Einfache Agenda"
           ((agenda "")
            (alltodo "")))
          ("1" "Q1" tags-todo "+Wichtig+Dringend")
          ("2" "Q2" tags-todo "+Wichtig-Dringend")
          ("3" "Q3" tags-todo "-Wichtig+Dringend")
          ("4" "Q4" tags-todo "-Wichtig-Dringend")))

(setq org-show-notification-handler 'alert)

;; http://orgmode.org/worg/org-faq.html
(defun diary-limited-cyclic (recurrences interval m d y)
  "For use in emacs diary. Cyclic item with limited number of recurrences.
Occurs every INTERVAL days, starting on YYYY-MM-DD, for a total of
RECURRENCES occasions."
  (let ((startdate (calendar-absolute-from-gregorian (list m d y)))
        (today (calendar-absolute-from-gregorian date)))
    (and (not (minusp (- today startdate)))
         (zerop (% (- today startdate) interval))
         (< (floor (- today startdate) interval) recurrences))))

(with-eval-after-load "ox-latex"
  (add-to-list 'org-latex-classes
               '("koma-article" "\\documentclass{scrartcl}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

(use-package htmlize)

(setq org-todo-keywords
      '((sequence "TODO(t@/!)" "Nächstes(n)" "Warten(w@/!)" "Projekt(p)" "Irgendwann(i)"
                  "|" "DONE(d@/!)" "Gestoppt(g/!)")))

(setq org-enforce-todo-dependencies t)
(setq org-enforce-checkbox-dependencies t)
(setq org-track-ordered-property-with-tag t)

(setq org-log-into-drawer t)  
(setq org-log-reschedule 'time)
(setq org-log-redeadline 'note)
(setq org-log-note-clock-out t)
(setq org-archive-location    "~/Dropbox/orgfiles/archive.org::* From %s")

(add-hook 'org-log-buffer-setup-hook
      (lambda ()
        (let (dict)
          (other-window 1 nil)
          (setq dict ispell-local-dictionary)
          (other-window 1 nil)
          (ispell-change-dictionary dict))))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((lisp . t)
   (emacs-lisp . t)))

;;;; Org bullets
(use-package org-bullets
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

;;;; Prettify symbols
;; https://github.com/Ilazki/prettify-utils.el/blob/b4c9b50d4812f7c48d4a34a2280fdded2122bfbd/prettify-utils.el
(load "prettify-utils.elc")
(add-hook 'org-mode-hook (lambda ()
   "Beautify Org Checkbox Symbol"
   (setq prettify-symbols-alist
         (prettify-utils-generate
          ("[ ]" "☐")
          ("[X]" "☑")
          ("[-]" "❍")))
   (prettify-symbols-mode)))
 
(defface org-checkbox-done-text
  '((t (:foreground "#71696A" :strike-through t)))
  "Face for the text part of a checked org-mode checkbox.")
 
(font-lock-add-keywords
'org-mode
`(("^[ \t]*\\(?:[-+*]\\|[0-9]+[).]\\)[ \t]+\\(\\(?:\\[@\\(?:start:\\)?[0-9]+\\][ \t]*\\)?\\[\\(?:X\\|\\([0-9]+\\)/\\2\\)\\][^\n]*\n\\)"
    1 'org-checkbox-done-text prepend))
'append)

;;;; Org autocomplete
(use-package org-ac
  :init 
  (org-ac/config-default))

;;;; Meine Capture templates 
(setq org-capture-templates
      '(("l" "Link" entry (file+headline "~/Dropbox/orgfiles/Links.org" "Links")
         "* %? %^L %^g \n%T" :prepend t)
        ("a" "Aufgabe" entry (file+headline "~/Dropbox/orgfiles/Martin.org" "Aufgaben")
         "* TODO %?\n%u" :prepend t)
        ("u" "Aufgabe mit Deadline" entry (file+headline "~/Dropbox/orgfiles/Martin.org" "Aufgaben")
          "* TODO [#A] %?\nSCHEDULED: %(org-insert-time-stamp (org-read-date nil t \"+0d\"))\n%a\n" :prepend t)
        ("e" "Emacs-Aufgabe" entry (file+headline "~/Dropbox/orgfiles/Martin.org" "Emacs")
         "* TODO %?\n%u" :prepend t)
        ("c" "Common Lisp" entry (file+headline "~/Dropbox/orgfiles/Martin.org"
                                                "Common Lisp-Projekte")
         "* TODO %?\n%u" :prepend t)
        ("m" "Mail To Do" entry (file+headline "~/Dropbox/orgfiles/Martin.org" "To Do")
         "* TODO %a\n %?" :prepend t)
        ("n" "Notiz" entry (file+headline "~/Dropbox/orgfiles/Notes.org" "Notizen")
         "* %?\n%u" :prepend t)
        ("T" "Termin" entry (file+headline  "~/Dropbox/orgfiles/Martin.org" "Termine")
         "* %?\n\n%^T\n\n:PROPERTIES:\n\n:END:\n\n")
        ("t" "Tagebucheintrag" entry (file+datetree "~/Dropbox/orgfiles/Journal.org.gpg")
         "* %?\nEntered on %U\n  %i\n  %a")
	("b" "Buch" entry (file+headline "~/Dropbox/orgfiles/books.org" "Bücher")
	 "** Irgendwann %^{Autor} -- %^{Titel}\n:PROPERTIES:\n:SEITEN: %^{Seiten}\n:GENRE: %^{Genre}\n:Rating:\n:END:\n - Empfohlen von: %^{Empfohlen von:} \n:LOGBOOK:\n - Added: %U\n:END:\n"
	 :prepend t)
	("f" "Film" entry (file+headline "~/Dropbox/orgfiles/Filme.org" "Filme")
	 "** Irgendwann %^{Titel}\n:PROPERTIES:\n:GENRE: %^{Genre}\n:END:\n- Empfohlen von: %^{Empfohlen von:}\n:LOGBOOK:\n - Added: %U\n:END:\n")))

;;;; Capture außerhalb von Emacs 
;; http://cestlaz.github.io/posts/using-emacs-24-capture-2/#.WJzewBiX-V4
(defadvice org-capture-finalize
    (after delete-capture-frame activate)
  "Advise capture-finalize to close the frame"
  (if (equal "capture" (frame-parameter nil 'name))
      (delete-frame)))

(defadvice org-capture-destroy
    (after delete-capture-frame activate)
  "Advise capture-destroy to close the frame"
  (if (equal "capture" (frame-parameter nil 'name))
      (delete-frame)))

(use-package noflet)

(defun make-capture-frame ()
  "Create a new frame and run org-capture."
  (interactive)
  (make-frame '((name . "capture")))
  (select-frame-by-name "capture")
  (delete-other-windows)
  (noflet ((switch-to-buffer-other-window (buf) (switch-to-buffer buf)))
    (org-capture)))

;;----------------------------------------------------------------------------
;;; Magit
(use-package magit
  :config
  (global-magit-file-mode t)
  (setq magit-log-arguments (quote ("--graph" "--color" "--decorate" "-n256")))
  :bind
  ("C-x g" . magit-status))

;;;; Gist
(use-package gist)

;;;; Git gutter
(use-package git-gutter
  :diminish git-gutter-mode
  :config
  (global-git-gutter-mode 1)
  (custom-set-variables
   '(git-gutter:window-width 2)
   '(git-gutter:modified-sign "☁")
   '(git-gutter:added-sign "☀")
   '(git-gutter:deleted-sign "☂")
   '(git-gutter:lighter " GG")
   '(git-gutter:update-interval 2)
   '(git-gutter:visual-line t))
  (defhydra hydra-git-gutter (:body-pre (git-gutter-mode 1)
                                        :hint nil)
  "
Git gutter:
  _j_: next hunk        _s_tage hunk     _q_uit
  _k_: previous hunk    _r_evert hunk    _Q_uit and deactivate git-gutter
  ^ ^                   _p_opup hunk
  _h_: first hunk
  _l_: last hunk        set start _R_evision
"
  ("j" git-gutter:next-hunk)
  ("k" git-gutter:previous-hunk)
  ("h" (progn (goto-char (point-min))
              (git-gutter:next-hunk 1)))
  ("l" (progn (goto-char (point-min))
              (git-gutter:previous-hunk 1)))
  ("s" git-gutter:stage-hunk)
  ("r" git-gutter:revert-hunk)
  ("p" git-gutter:popup-hunk)
  ("R" git-gutter:set-start-revision)
  ("q" nil :color blue)
  ("Q" (progn (git-gutter-mode -1)
              ;; git-gutter-fringe doesn't seem to
              ;; clear the markup right away
              (sit-for 0.1)
              (git-gutter:clear))
       :color blue))
  :bind
  (("C-x v =" . 'git-gutter:popup-hunk)
   ("C-x p" . 'git-gutter:previous-hunk)
   ("C-x n" . 'git-gutter:next-hunk)
   ("C-x v s" . 'git-gutter:stage-hunk)
   ("C-x v r" . 'git-gutter:revert-hunk)
   ("C-x v SPC" . #'git-gutter:mark-hunk)
   ("M-g M-g" . #'hydra-git-gutter/body)))

;;;; Magit todos
(use-package magit-todos
  :config
  (magit-todos-mode 1))

;;;; Magithub
(use-package magithub
  :after magit
  :config
  (magithub-feature-autoinject t)
  (setq magithub-clone-default-directory "~/Documents/src/github"))

(require 'commoji)

;;----------------------------------------------------------------------------
;;; Projectile
(use-package projectile
  :init
  (projectile-mode)
  :diminish projectile-mode
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

(use-package counsel-projectile
  :init
  (counsel-projectile-mode t))

(use-package org-projectile
  :bind (("C-c n p" . org-projectile-project-todo-completing-read)
         ("C-c c" . org-capture))
  :config
  (setq org-projectile-projects-file
        "~/Documents/src/lisp/Project Euler/ToDo.org")
  (setq org-agenda-files (append org-agenda-files (org-projectile-todo-files)))
  (push (org-projectile-project-todo-entry) org-capture-templates))

(mb/sections)
;;----------------------------------------------------------------------------
;;; Erscheinung
;;;; Windows und Frames
(when window-system
  (set-frame-size (selected-frame) 220 70)
  (set-frame-position (selected-frame) 165 35)
  ;; (set-default-font                    
  ;;  "-*-Source Code Pro-normal-normal-normal-*-12-*-*-*-m-0-iso10646-1")
  ;; https://github.com/tonsky/FiraCode/wiki/Emacs-instructions
  (set-default-font                    
   "-*-Fira Code-normal-normal-normal-*-12-*-*-*-m-0-iso10646-1")
  (load "~/.emacs.d/elisp/fira-code-mode.el")
  (add-hook 'prog-mode-hook #'fira-code-mode)
  (setq auto-window-vscroll nil)

  ;; Fancy titlebar for MacOS
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark))
  (setq ns-use-proxy-icon  t)
  (setq frame-title-format t)
  (setq ns-pop-up-frames nil)

  (global-hl-line-mode t)
  (delete-selection-mode t)
  (global-font-lock-mode t)

  (winner-mode)

  (setq pop-up-frame-function (lambda () (split-window-right)))
  (setq split-height-threshold 1400)
  (setq split-width-treshold 1500)

;;;; Teilen von Fenstern  
;; https://github.com/daedreth/UncleDavesEmacs/blob/master/config.org
  (defun split-and-follow-horizontally ()
    (interactive)
    (split-window-below)
    (balance-windows)
    (other-window 1))
  (global-set-key (kbd "C-x 2") 'split-and-follow-horizontally)

  (defun split-and-follow-vertically ()
    (interactive)
    (split-window-right)
    (balance-windows)
    (other-window 1))
  (global-set-key (kbd "C-x 3") 'split-and-follow-vertically))

;;;; In anderen Fenstern scrollen
(defun vl/window-half-height (&optional window)
  (max 1 (/ (1- (window-height window)) 2)))

(defun vl/scroll-down-half-other-window ()
  (interactive)
  (scroll-other-window
   (vl/window-half-height (other-window-for-scrolling))))

(defun vl/scroll-up-half-other-window ()
  (interactive)
  (scroll-other-window-down
   (vl/window-half-height (other-window-for-scrolling))))

(defhydra vl/hydra-scroll-other-window
  (:base-map (make-sparse-keymap))
  "Scroll the *other* window."
  ("d" vl/scroll-down-half-other-window "down")
  ("v" vl/scroll-down-half-other-window "down")
  ("u" vl/scroll-up-half-other-window "up")
  ("V" vl/scroll-up-half-other-window "up"))

(defun vl/smart-scroll-down-other-window ()
  "Scroll down the other window and activate a hydra menu."
  (interactive)
  (vl/scroll-down-half-other-window)
  (vl/hydra-scroll-other-window/body))

(defun vl/smart-scroll-up-other-window ()
  "Scroll up the other window and activate a hydra menu."
  (interactive)
  (vl/scroll-up-half-other-window)
  (vl/hydra-scroll-other-window/body))

(global-set-key (kbd "C-M-v")   #'vl/smart-scroll-down-other-window)
(global-set-key (kbd "C-M-S-v") #'vl/smart-scroll-up-other-window)

;;;; All the icons
(use-package all-the-icons)

(use-package all-the-icons-ivy
  :demand t
  :after (all-the-icons ivy)
  :custom (all-the-icons-ivy-buffer-commands '(ivy-switch-buffer-other-window ivy-switch-buffer))
  :config
  (add-to-list 'all-the-icons-ivy-file-commands 'counsel-dired-jump)
  (add-to-list 'all-the-icons-ivy-file-commands 'counsel-find-library)
  (all-the-icons-ivy-setup))

(use-package all-the-icons-dired
  :diminish
  :hook
  (dired-mode . all-the-icons-dired-mode))

;;;; Mein Lieblingstheme
(load-theme 'zenburn nil nil)
;; use variable-pitch fonts for some headings and titles
(setq zenburn-use-variable-pitch t)

;; scale headings in org-mode
(setq zenburn-scale-org-headlines t)

;; scale headings in outline-mode
(setq zenburn-scale-outline-headlines t)

;;;; Mode icons
(use-package mode-icons
  :demand t
  :config
  (mode-icons-mode t))

;;;; Powerline
(use-package powerline
  :demand t
  :config
  (powerline-default-theme))

(setq line-number-mode t)
(setq column-number-mode t)

;;;; Beacon
(use-package beacon
  :config
  (beacon-mode 1)
  (setq beacon-push-mark 35
        beacon-color "#666600"))

;;;; List buffers
(defalias 'list-buffers 'ibuffer-other-window)

(setq ibuffer-saved-filter-groups
      (quote (("default"
               ("dired" (mode . dired-mode))
               ("org" (name . "^.*org$"))
               ("shell" (or (mode . eshell-mode) (mode . shell-mode)))
               ("mu4e" (name . "\*mu4e\*"))
               ("lisp" (or
                        (mode . lisp-mode)
                        (mode . emacs-lisp)
                        (mode . REPL)))
               ("emacs" (or
                         (name . "^\\*scratch\\*$")
                         (name . "^\\*Messages\\*$")))
               ))))

(add-hook 'ibuffer-mode-hook
          (lambda ()
            (ibuffer-auto-mode 1)
            (ibuffer-switch-to-saved-filter-groups "default")))

;; Don't show filter groups if there are no buffers in that group
(setq ibuffer-show-empty-filter-groups nil)

;; Don't ask for confirmation to delete marked buffers
(setq ibuffer-expert t)

;;;; Vertauschen von Zeilen
(require 'move-lines)
(move-lines-binding)

;;;; Ich arbeite in einer deutschen Umgebung
(set-language-environment       'German)

;; UTF-8
(set-buffer-file-coding-system  'utf-8-unix)
(prefer-coding-system           'utf-8-unix)
(set-default buffer-file-coding-system  'utf-8-unix)
(set-terminal-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)

(setq-default indent-tabs-mode nil)
;;;; Enabeling flyspell
(dolist (hook '(text-mode-hook org-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))
(dolist (hook '(lisp-mode-hook emacs-lisp-mode-hook))
  (add-hook hook (lambda () (flyspell-prog-mode))))
(diminish 'flyspell-mode)

;; Making flyspell work with my trackpad
(eval-after-load "flyspell"
  '(progn
     (define-key flyspell-mouse-map [down-mouse-3] #'flyspell-correct-word)
     (define-key flyspell-mouse-map [mouse-3] #'undefined)))
;; Using a english dictionary as standard.
(setq ispell-dictionary "de_DE")

(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'text-mode-hook (lambda () (visual-line-mode 1)))
(add-hook 'org-mode-hook (lambda () (visual-line-mode 1)))

;;;; Vervollständigung von Wörtern
(use-package ac-ispell
  
  :config
  (custom-set-variables
   '(ac-ispell-requires 4)
   '(ac-ispell-fuzzy-limit 4))

  (eval-after-load "auto-complete"
    '(progn
       (ac-ispell-setup)))

  (add-hook 'git-commit-mode-hook 'ac-ispell-ac-setup)
  (add-hook 'mail-mode-hook 'ac-ispell-ac-setup))

(add-hook 'before-save-hook 'time-stamp) ; Aktiviert die Time-stamp-Funktion

;; http://pragmaticemacs.com/emacs/adaptive-cursor-width/
(setq x-stretch-cursor t)

;;;; Setup pandoc
(setq markdown-programm "/opt/local/bin/pandoc")
(setq markdown-command "/opt/local/bin/pandoc")

;;; Bemerkungen
(use-package annotate)

;;; Dashboard
(use-package dashboard
  :demand t
  :config
  (dashboard-setup-startup-hook)
  ;; Set the title
  (setq dashboard-banner-logo-title "Welcome to Martin's Emacs")
  ;; Set the banner
  (setq dashboard-startup-banner 'official)
  ;; Value can be
  ;; 'official which displays the official emacs logo
  ;; 'logo which displays an alternative emacs logo
  ;; 1, 2 or 3 which displays one of the text banners
  ;; "path/to/your/image.png which displays whatever image you would prefer
  (setq dashboard-items '((recents  . 10)
                          (bookmarks . 10)
                          (projects . 5)
                          (agenda . 5)
                          ; (registers . 5)
                          )))

(mb/sections)

;;----------------------------------------------------------------------------
;;; Eigene Funktionen
;; https://www.emacswiki.org/emacs/InsertFileName
(defun my-insert-file-name (filename &optional args)
    "Insert name of file FILENAME into buffer after point.

  Prefixed with \\[universal-argument], expand the file name to
  its fully canocalized path.  See `expand-file-name'.

  Prefixed with \\[negative-argument], use relative path to file
  name from current directory, `default-directory'.  See
  `file-relative-name'.

  The default with no prefix is to insert the file name exactly as
  it appears in the minibuffer prompt."
    ;; Based on insert-file in Emacs -- ashawley 20080926
    (interactive "*fInsert file name: \nP")
    (cond ((eq '- args)
           (insert (file-relative-name filename)))
          ((not (null args))
           (insert (expand-file-name filename)))
          (t
           (insert filename))))

(defun config-visit ()
  (interactive)
  (find-file "~/.emacs.d/init.el"))

(defun config-reload ()
  (interactive)
  (load-file (expand-file-name "~/.emacs.d/init.el")))

(mb/sections)

;;----------------------------------------------------------------------------
;;; Spezielle Modi
;;;; Yasnippet
(use-package yasnippet
  :diminish yas-minor-mode
  :config
  (yas-global-mode 1)
  (unless (boundp 'warning-suppress-types)
    (setq warning-suppress-types nil))
  (add-to-list 'warning-suppress-types '(yasnippet backquote-change)))

(use-package yasnippet-snippets)

;;;; Gnuplot
(use-package gnuplot
  :config
  (autoload 'gnuplot-mode "gnuplot" "gnuplot major mode" t)
  (autoload 'gnuplot-make-buffer "gnuplot" "open a buffer in gnuplot-mode" t)
  (setq auto-mode-alist (append '(("\\.gp$" . gnuplot-mode))
                                auto-mode-alist))
  :bind
  ([f9] . gnuplot-make-buffer))

;;;; Meine Lisp-Umgebung
;;;;; Slime
(load (expand-file-name "~/quicklisp/slime-helper.el"))

(setq inferior-lisp-program "/opt/local/bin/sbcl --no-inform --no-linedit")
(setq slime-lisp-implementations
      '((sbcl  ("/opt/local/bin/sbcl" "--no-inform --no-linedit"))
        (clisp ("/opt/local/bin/clisp"))
        (ccl   ("/opt/local/bin/ccl64") :coding-system utf-8-unix)))
(setq slime-net-coding-system 'utf-8-unix)
(slime-setup
 '(slime-repl-ansi-color slime-fancy slime-banner slime-indentation slime-asdf slime-tramp slime-fuzzy))
(slime-require 'swank-listener-hooks)
;; Hyperspec within Emacs
(setq browse-url-browser-function
      '((".*lispworks.*" . w3m-goto-url-new-session) ("." . browse-url-default-browser)))
;; slime-annot
(load (expand-file-name
       "~/quicklisp/dists/quicklisp/software/cl-annot-20150608-git/misc/slime-annot.el"))
(require 'slime-annot)

(define-key slime-mode-map (kbd "C-c s") 'slime-selector)
(define-key slime-repl-mode-map (kbd "C-c s") 'slime-selector)

;;;;; ac-slime
(use-package ac-slime
  :config
  (add-hook 'slime-mode-hook 'set-up-slime-ac)
  (add-hook 'slime-repl-mode-hook 'set-up-slime-ac)
  (eval-after-load "auto-complete"
    '(add-to-list 'ac-modes 'slime-repl-mode)))

;;;;; paredit
(use-package paredit
  :demand t
  :diminish paredit-mode
  :config
  (add-hook 'lisp-mode-hook #'enable-paredit-mode)
  (add-hook 'slime-repl-mode-hook #'enable-paredit-mode)
  (add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode))

;;;;; Sonstiges
(use-package rainbow-delimiters
  :config
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

;; The global-prettify-symbols-mode causes a bug with log4slime!
(add-hook 'prog-mode-hook #'prettify-symbols-mode)

;;;;; log4cl
(defvar log4slime-mode t) ; Simple work-around?!
(load "~/quicklisp/log4slime-setup.el")
(global-log4slime-mode 1)

;;;; AUCTeX
(use-package tex
  :ensure auctex
  :config
  (setq TeX-auto-save t
        TeX-parse-self t
        TeX-save-query nil)
  (setq-default TeX-master nil)
  :hook
  (LaTeX-mode . flyspell-mode)
  (LaTeX-mode . flyspell-buffer)
  (LaTeX-mode . tex-fold-mode)
  (LaTeX-mode . turn-on-reftex))

(use-package auto-complete-auctex)

(use-package lorem-ipsum)

;;;; Web mode
(use-package web-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (setq web-mode-ac-sources-alist
        '(("css" . (ac-source-css-property))
          ("html" . (ac-source-words-in-buffer ac-source-abbrev))))
  (setq web-mode-enable-auto-closing t)
  (setq web-mode-enable-auto-quoting t)
  (setq web-mode-enable-css-colorization t))

;;;;; Rainbow mode
(use-package rainbow-mode
  :init
  (rainbow-mode 1)
  :diminish rainbow-mode)

;;;;; lass mode
;; Der Pfad muss angepasst werden, bei einem Update von lass
(add-to-list 'load-path "~/quicklisp/dists/quicklisp/software/lass-20170830-git")
(require 'lass)

;;----------------------------------------------------------------------------
;;; Meine Tastenbelegung
(global-set-key [f5] 'revert-buffer)

(global-set-key (kbd "C-x k") 'kill-this-buffer)

(global-set-key (kbd "\C-c i") 'my-insert-file-name)

;; zap-up-up-char
(autoload 'zap-up-to-char "misc"
  "Kill up to, but not including ARGth occurrence of CHAR.

    \(fn arg char)"
  'interactive)

;;;; Meine eigene Keymap
;; Inspiriert von Mike https://github.com/zamansky/using-emacs/blob/master/myinit.org
(define-prefix-command 'mb-map)
(global-set-key (kbd "C-z") 'mb-map)
(define-key mb-map (kbd "c") 'multiple-cursors-hydra/body)
(define-key mb-map (kbd "s") 'flyspell-correct-word-before-point)
(define-key  mb-map "\C-i" #'endless/ispell-word-then-abbrev)
(define-key mb-map "n" #'narrow-or-widen-dwim)

(defun my-org ()
  "A short-cut function to open my main org file."
  (interactive)
  (find-file "~/Dropbox/orgfiles/Martin.org"))

(define-key mb-map (kbd "i") 'my-org)
(define-key mb-map (kbd "e") 'config-visit)
(define-key mb-map (kbd "r") 'config-reload)
(define-key mb-map (kbd "w") 'define-word-at-point)
(define-key mb-map (kbd "f") 'find-file-at-point)

(mb/sections)

;;----------------------------------------------------------------------------
;;; Meine Makros
(fset 'new-problem
   (lambda (&optional arg) "Keyboard macro." (interactive "p") (kmacro-exec-ring-item (quote ([134217837 67108896 5 134217847 return 25 2 2 backspace backspace] 0 "%d")) arg)))

(fset 'dkb-import
   [?\C-  ?\C-n ?\C-n ?\C-n ?\C-n ?\C-n ?\C-n ?\C-w ?\M-% ?\; return tab return ?! ?\M-< ?\M-% ?\" return return ?!])

(alert "Emacs ist gestartet..." :title "Emacs says:" :severity 'highest :persistent t)
(mb/sections)

;;----------------------------------------------------------------------------
;;; Ende
(message "Martins init.el wurde gelesen")
(message "Have a nice day!")
