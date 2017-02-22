;;; init.el
;;--------------------------------------------------------------------
;; Time-stamp: <2017-02-22 18:04:50 Martin>
;;
;; Ich habe versucht alles hier zu konfigurieren,
;; d.h. soweit wie möglich auf das custom-Interface zu verzichten, um
;; alles in einer Datei zu haben.
;;--------------------------------------------------------------------
;;
(message "Dies ist Martins init.el")

;;----------------------------------------
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

;; Die eigentlichen Anpassungen erfolgen in myinit.org
(org-babel-load-file "/Users/Martin/.emacs.d/myinit.org")

(message "Martins init.el wurde gelesen")
(message "Have a nice day!")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ac-ispell-fuzzy-limit 4)
 '(ac-ispell-requires 4)
 '(ansi-color-names-vector
   ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#e090d7" "#8cc4ff" "#eeeeec"])
 '(custom-enabled-themes (quote (zenburn)))
 '(custom-safe-themes
   (quote
    ("bb749a38c5cb7d13b60fa7fc40db7eced3d00aa93654d150b9627cabd2d9b361" "2997ecd20f07b99259bddba648555335ffb7a7d908d8d3e6660ecbec415f6b95" default)))
 '(package-selected-packages
   (quote
    (smart-comment org-beautify-theme zenburn-theme ac-math ac-ispell org-wunderlist osx-bbdb osx-lib alert readline-complete mic-paren htmlize org-ac counsel-projectile counsel-osx-app bbdb-handy bbdb org-gcal noflet w3m yasnippet which-key use-package undo-tree try powerline paredit org-bullets mode-icons markdown-mode magit ivy-hydra expand-region exec-path-from-shell elisp-slime-nav counsel command-log-mode bm beacon avy ac-slime)))
 '(safe-local-variable-values
   (quote
    ((buffer-local-dictionary . "de")
     (buffer-local-dictionary . "en")
     (ispell-dictionary . "en")
     (ispell-dictionary . en)
     (spell-dictionary . en))))
 '(show-paren-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
