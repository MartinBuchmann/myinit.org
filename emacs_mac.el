;; Martins Makros
;; -*- mode: Emacs-Lisp; coding: mac-roman; -*-
;; Time-stamp: <Freitag, 2006-04-28 14:50:51 by Martin>
(fset 'uncomment-line
   (lambda (&optional arg) "Keyboard macro." (interactive "p") (kmacro-exec-ring-item (quote ([1 67108896 5 134217848 117 110 99 111 109 109 101 110 116 45 114 101 103 105 111 110 return 14 1] 0 "%d")) arg)))

(fset 'comment-line
   (lambda (&optional arg) "Keyboard macro." (interactive "p") (kmacro-exec-ring-item (quote ([1 67108896 5 134217848 99 111 109 109 101 110 116 45 114 101 103 105 111 110 return 14 1] 0 "%d")) arg)))

(global-set-key "\C-x\C-kc" 'comment-line)
(global-set-key "\C-x\C-ku" 'uncomment-line)

