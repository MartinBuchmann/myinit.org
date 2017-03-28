;;; init.el
;;--------------------------------------------------------------------
;; Time-stamp: <2017-03-19 15:34:40 Martin>
;;
;; Ich habe versucht alles hier zu konfigurieren,
;; d.h. soweit wie möglich auf das custom-Interface zu verzichten, um
;; alles in einer Datei zu haben.
;;--------------------------------------------------------------------
;;
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

;; Der Paket-Manager
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("marmalade" . "https://marmalade-repo.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))

(package-initialize)
;; http://cestlaz.github.io/posts/using-emacs-1-setup/#.WJLnDRiX-V4
;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
	(package-refresh-contents)
	(package-install 'use-package))

;; Benchmark-init
;; https://github.com/dholm/benchmark-init-el.git
(add-to-list 'load-path "/Users/Martin/.emacs.d/elisp/benchmark-init-el")
(require 'benchmark-init-loaddefs)
(benchmark-init/activate)

;; Die eigentlichen Anpassungen erfolgen in myinit.org
(org-babel-load-file "/Users/Martin/.emacs.d/myinit.org")

(message "Martins init.el wurde gelesen")
(message "Have a nice day!")
