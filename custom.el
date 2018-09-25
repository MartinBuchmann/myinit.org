(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ac-ispell-fuzzy-limit 4)
 '(ac-ispell-requires 4)
 '(ansi-color-names-vector
   ["#3F3F3F" "#CC9393" "#7F9F7F" "#F0DFAF" "#8CD0D3" "#DC8CC3" "#93E0E3" "#DCDCCC"])
 '(custom-enabled-themes (quote (zenburn)))
 '(custom-safe-themes
   (quote
    ("fd825ffbcec8199cd08266a50441df9c68db831a4bdb9cb5d85dfbb2c59c96ae" "0c32e4f0789f567a560be625f239ee9ec651e524e46a4708eb4aba3b9cdc89c5" "89dd0329d536d389753111378f2425bd4e4652f892ae8a170841c3396f5ba2dd" "3f44e2d33b9deb2da947523e2169031d3707eec0426e78c7b8a646ef773a2077" "190a9882bef28d7e944aa610aa68fe1ee34ecea6127239178c7ac848754992df" "e11569fd7e31321a33358ee4b232c2d3cf05caccd90f896e1df6cab228191109" "599f1561d84229e02807c952919cd9b0fbaa97ace123851df84806b067666332" "f36b0a4ecb6151c0ec4d51d5cafc94de326b4659aaa7ac64a663e38ebc6d71dc" "2022c5a92bbc261e045ec053aa466705999863f14b84c012a43f55a95bf9feb8" "5e52ce58f51827619d27131be3e3936593c9c7f9f9f9d6b33227be6331bf9881" "2a739405edf418b8581dcd176aaf695d319f99e3488224a3c495cb0f9fd814e3" "cdfc5c44f19211cfff5994221078d7d5549eeb9feda4f595a2fd8ca40467776c" "67e998c3c23fe24ed0fb92b9de75011b92f35d3e89344157ae0d544d50a63a72" "a0dc0c1805398db495ecda1994c744ad1a91a9455f2a17b59b716f72d3585dde" "093b2a26030dcd576cad4e59b5d804bc0496e56f4e2659e8900b4814279c3402" "4a51697271e3fd202d3da73bad80d0ec5cab7e0bb1db30f79fd1d6dd6a7812dc" "7f968c172d6ec46766773a8304c7570bdff45f1220d3700008a437d9529ca3e4" "f5512c02e0a6887e987a816918b7a684d558716262ac7ee2dd0437ab913eaec6" "bb749a38c5cb7d13b60fa7fc40db7eced3d00aa93654d150b9627cabd2d9b361" "2997ecd20f07b99259bddba648555335ffb7a7d908d8d3e6660ecbec415f6b95" default)))
 '(define-word-default-service (quote Openthesarus))
 '(define-word-services
    (quote
     ((wordnik "http://wordnik.com/words/%s" define-word--parse-wordnik nil)
      (Openthesarus "https://www.openthesaurus.de/synonyme/%s" define-word--parse-openthesaurus nil))))
 '(fci-rule-color "#383838")
 '(git-gutter:added-sign "☀")
 '(git-gutter:deleted-sign "☂")
 '(git-gutter:lighter " GG")
 '(git-gutter:modified-sign "☁")
 '(git-gutter:update-interval 2)
 '(git-gutter:visual-line t)
 '(git-gutter:window-width 2)
 '(nrepl-message-colors
   (quote
    ("#CC9393" "#DFAF8F" "#F0DFAF" "#7F9F7F" "#BFEBBF" "#93E0E3" "#94BFF3" "#DC8CC3")))
 '(org-agenda-files
   (quote
    ("~/Dropbox/orgfiles/Martin.org" "~/Dropbox/orgfiles/Notes.org" "~/Dropbox/orgfiles/beorg.org" "~/Dropbox/orgfiles/binnova.org")))
 '(org-modules
   (quote
    (org-bbdb org-bibtex org-docview org-gnus org-habit org-info org-irc org-mhe org-rmail org-w3m)))
 '(osxb-import-with-timer nil)
 '(package-selected-packages
   (quote
    (blimp magit-todos ace-jump-zap mu4e-conversation ivy-prescient auto-complete-auctex yasnippet-snippets yasnippet ac-slime ac-ispell ace-link mic-paren define-word helpful emms-state emms-mode-line-cycle emms ac-emoji cdlatex poporg shift-number org-projectile dashboard linum-relative diminish git-gutter ace-window celestial-mode-line ace-mc gnuplot dired-details multiple-cursors pdf-tools wc-mode beginend finder+ wgrep f git-timemachine rainbow-mode rainbow-delimiters nord-theme dired-quick-sort gist web-mode osx-dictionary osx-org-clock-menubar mu4e-maildirs-extension mu4e mu4e-alert lorem-ipsum auctex smart-comment org-beautify-theme ac-math org-wunderlist osx-bbdb osx-lib alert readline-complete htmlize org-ac counsel-projectile counsel-osx-app bbdb-handy bbdb org-gcal noflet w3m which-key use-package undo-tree try powerline paredit org-bullets mode-icons markdown-mode magit ivy-hydra expand-region exec-path-from-shell counsel command-log-mode bm beacon avy)))
 '(pdf-view-midnight-colors (quote ("#DCDCCC" . "#383838")))
 '(recentf-exclude
   (quote
    ("/\\(\\(\\(COMMIT\\|NOTES\\|PULLREQ\\|TAG\\)_EDIT\\|MERGE_\\|\\)MSG\\|\\(BRANCH\\|EDIT\\)_DESCRIPTION\\)\\'" "/\\(autoloads\\|loaddefs\\)\\'")))
 '(safe-local-variable-values
   (quote
    ((eval flyspell-mode-off)
     (ispell-local-dictionary . de)
     (Syntax . Common-Lisp)
     (TeX-master . t)
     (buffer-local-dictionary . "de")
     (buffer-local-dictionary . "en")
     (ispell-dictionary . "en")
     (ispell-dictionary . en)
     (spell-dictionary . en))))
 '(send-mail-function (quote smtpmail-send-it))
 '(show-paren-mode t)
 '(tool-bar-mode nil)
 '(vc-annotate-background "#2B2B2B")
 '(vc-annotate-color-map
   (quote
    ((20 . "#BC8383")
     (40 . "#CC9393")
     (60 . "#DFAF8F")
     (80 . "#D0BF8F")
     (100 . "#E0CF9F")
     (120 . "#F0DFAF")
     (140 . "#5F7F5F")
     (160 . "#7F9F7F")
     (180 . "#8FB28F")
     (200 . "#9FC59F")
     (220 . "#AFD8AF")
     (240 . "#BFEBBF")
     (260 . "#93E0E3")
     (280 . "#6CA0A3")
     (300 . "#7CB8BB")
     (320 . "#8CD0D3")
     (340 . "#94BFF3")
     (360 . "#DC8CC3"))))
 '(vc-annotate-very-old-color "#DC8CC3"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
