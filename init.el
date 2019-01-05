;;; init.el
;;--------------------------------------------------------------------
;; Time-stamp: <2019-01-05 14:27:25 Martin>
;;
;; Ich habe versucht alles hier zu konfigurieren,
;; d.h. soweit wie möglich auf das custom-Interface zu verzichten, um
;; alles in einer Datei zu haben.
;;--------------------------------------------------------------------
;;
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

;; Bootstrap `use-package`
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

(message "Dies ist Martins init.el")
;;----------------------------------------
;; Neu strukturiert und ergänzt nach
;; https://github.com/durantschoon/.emacs.d/tree/boilerplate-sane-defaults_v1.0
;; Gleich zu Beginn unnötige Anzeigen abstellen.
(when window-system
  (menu-bar-mode 1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (tooltip-mode -1))

;; Immer neuere Dateien laden
(setq load-prefer-newer t)

;; Benchmark-init
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

(defun mb/find-outline-bug ()
  "Checking where outline-minor-mode-prefix is defined."
  (if (boundp 'outline-minor-mode-prefix)
      (message "outline-minor-mode-prefix is defined!")
    (message "outline-minor-mode-prefix is NOT defined!")))

(advice-add #'mb/sections :before #'mb/find-outline-bug)

;; Output of the current section number to the *Message* buffer 
(mb/sections)

(defvar outline-minor-mode-prefix "\M-#")

(mb/sections)
;; Die eigentlichen Anpassungen erfolgen in myinit.org
(org-babel-load-file (expand-file-name "~/.emacs.d/myinit.org"))

(message "Martins init.el wurde gelesen")
(message "Have a nice day!")
