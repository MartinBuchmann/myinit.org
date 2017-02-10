;;; init.el 
;;--------------------------------------------------------------------
;; Time-stamp: <2017-02-10 20:55:38 Martin>
;;
;; Ich habe versucht alles hier zu konfigurieren,
;; d.h. soweit wie möglich auf das custom-Interface zu verzichten, um
;; alles in einer Datei zu haben.
;;--------------------------------------------------------------------
;;
(message "Dies ist Martins init.el")

;; Wir wollen alle Informationen
(setq debug-on-error t)
;; Keine Startmeldung
(setq inhibit-startup-message t)

;;----------------------------------------
;; Der Paket-Manager
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/"))

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
 '(ansi-color-names-vector
   ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#e090d7" "#8cc4ff" "#eeeeec"])
 '(custom-enabled-themes (quote (tsdh-dark)))
 '(package-selected-packages
   (quote
    (noflet w3m yasnippet which-key use-package undo-tree try powerline paredit org-bullets mode-icons markdown-mode magit ivy-hydra expand-region exec-path-from-shell elisp-slime-nav counsel command-log-mode bm beacon avy ac-slime)))
 '(safe-local-variable-values
   (quote
    ((buffer-local-dictionary . "de")
     (buffer-local-dictionary . "en")
     (ispell-dictionary . "en")
     (ispell-dictionary . en)
     (spell-dictionary . en))))
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
