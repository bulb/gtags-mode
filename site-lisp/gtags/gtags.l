;; -*- Mode: Lisp; Package: EDITOR -*-
;; gtags.l --- gtags facility for xyzzy
;;
;; Copyright (c) 1997, 1998, 1999 Shigio Yamaguchi
;; Copyright (c) 1999, 2000 Tama Communications Corporation
;;
;; This file is part of GNU GLOBAL.
;;
;; GNU GLOBAL is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; GNU GLOBAL is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
;;

;; GLOBAL home page is at: http://www.gnu.org/software/global/
;; Author: Shigio Yamaguchi
;; Version: 2.0
;; Keywords: tools

;; Gtags-mode is implemented as a minor mode so that it can work with any
;; other major modes. Gtags-select mode is implemented as a major mode.
;;
;; Please copy this file into emacs lisp library directory or place it in
;; a directory (for example "~/lisp") and write $HOME/.emacs like this.
;;
;;	(setq load-path (cons "~/lisp" load-path))
;;
;; If you hope gtags-mode is on in c-mode then please add c-mode-hook to your
;; $HOME/.emacs like this.
;;
;;	(setq c-mode-hook
;;	    '(lambda ()
;;		(gtags-mode 1)
;;	))

;;; Code

(provide "gtags/gtags")

(in-package "editor")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "gtags/gtags-ext")
  )

(eval-when (:compile-toplevel :load-toplevel :execute)
  (export '(*gtags-mode-hook*
            *gtags-select-mode-hook*
            *gtags-current-buffer*
            *gtags-buffer-stack*
            *gtags-point-stack*
            *gtags-complete-list*
            *gtags-history-list*
            *gtags-symbol-regexp*
            *gtags-definition-regexp*
            *gtags-mode-map*
            *gtags-rootdir*
            )))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (export '(gtags-mode
            gtags-display-browser
            gtags-find-file
            gtags-find-pattern
            gtags-find-rtag
            gtags-find-symbol
            gtags-find-tag
            gtags-find-tag-by-event
            gtags-find-tag-from-here
            gtags-find-with-grep
            gtags-find-with-idutils
            gtags-make-complete-list
            gtags-parse-file
            gtags-pop-context
            gtags-pop-stack
            gtags-select-mode
            gtags-select-tag
            gtags-select-tag-by-event
            gtags-visit-rootdir
            )))


;(defvar gtags-mode t
;  "Non-nil if Gtags mode is enabled.")
;(make-variable-buffer-local 'gtags-mode)
(defvar-local gtags-mode nil)

(defvar *gtags-current-buffer* nil
  "Current buffer.")
(defvar *gtags-buffer-stack* nil
  "Stack for tag browsing.")
(defvar *gtags-point-stack* nil
  "Stack for tag browsing.")
(defvar *gtags-complete-list* nil
  "Gtags complete list.")
(defvar *gtags-history-list* nil
  "Gtags history list.")
(defconstant *gtags-symbol-regexp* "[A-Za-z_][A-Za-z_0-9]*"
  "Regexp matching tag name.")
(defconstant *gtags-definition-regexp* "#[ \t]*define[ \t]+\\|ENTRY(\\|ALTENTRY("
  "Regexp matching tag definition name.")
(defvar *gtags-read-only* nil
  "Gtags read only mode")
(defvar *gtags-mode-map* (make-sparse-keymap)
  "Keymap used in gtags mode.")
;(defvar gtags-running-xemacs (string-match "XEmacs\\|Lucid" emacs-version)
;  "Whether we are running XEmacs/Lucid Emacs")
(defvar *gtags-rootdir* nil
  "Root directory of source tree.")

(defvar *minor-mode-map-alist* nil)

(defvar *gtags-mode-hook* nil
  "gtags-mode: モードフック")

(defvar *gtags-select-mode-hook* nil
  "gtags-mode: セレクトモードフック")
;
; New key assignment to avoid conflicting with ordinary assignments.
;
;;;(define-key gtags-mode-map "\e*" 'gtags-pop-stack)
;;;(define-key gtags-mode-map "\e." 'gtags-find-tag)
;
; Old key assignment.
;
; If you hope old style key assignment. Please include following code
; to your $HOME/.emacs:
;
; (setq gtags-mode-hook
;   '(lambda ()
;         (define-key gtags-mode-map "\eh" 'gtags-display-browser)
;         (define-key gtags-mode-map "\ec" 'gtags-make-complete-list)
;         (define-key gtags-mode-map "\C-]" 'gtags-find-tag-from-here)
;         (define-key gtags-mode-map "\C-t" 'gtags-pop-stack)
;         (define-key gtags-mode-map "\el" 'gtags-find-file)
;         (define-key gtags-mode-map "\eg" 'gtags-find-with-grep)
;         (define-key gtags-mode-map "\eI" 'gtags-find-with-idutils)
;         (define-key gtags-mode-map "\es" 'gtags-find-symbol)
;         (define-key gtags-mode-map "\er" 'gtags-find-rtag)
;         (define-key gtags-mode-map "\et" 'gtags-find-tag)
; ))


;;;(if (not gtags-running-xemacs) nil
;;; (define-key *gtags-mode-map* 'button3 'gtags-pop-stack)
;;; (define-key *gtags-mode-map* 'button2 'gtags-find-tag-by-event))
;;;(if gtags-running-xemacs nil
;;; (define-key *gtags-mode-map* [mouse-3] 'gtags-pop-stack)
;;; (define-key *gtags-mode-map* [mouse-2] 'gtags-find-tag-by-event))



#|
(defvar *gtags-select-mode-map* (make-sparse-keymap)
  "Keymap used in gtags select mode.")
(define-key *gtags-select-mode-map* #\M-* 'gtags-pop-stack)
;;;(if (not gtags-running-xemacs) nil
;;; (define-key gtags-select-mode-map 'button3 'gtags-pop-stack)
;;; (define-key gtags-select-mode-map 'button2 'gtags-select-tag-by-event))
;;;(if gtags-running-xemacs nil
;;; (define-key gtags-select-mode-map [mouse-3] 'gtags-pop-stack)
;;; (define-key gtags-select-mode-map [mouse-2] 'gtags-select-tag-by-event))
;;;(define-key *gtags-select-mode-map* "\^?" 'scroll-down)
;;;(define-key *gtags-select-mode-map* " " 'scroll-up)
;(define-key *gtags-select-mode-map* #\C-b 'scroll-down)
;(define-key *gtags-select-mode-map* #\C-f 'scroll-up)
;;;(define-key *gtags-select-mode-map* "k" 'previous-line*)
;;;(define-key *gtags-select-mode-map* "j" 'next-line)
;;;(define-key *gtags-select-mode-map* "p" 'previous-line)
;;;(define-key *gtags-select-mode-map* "n" 'next-line)
;;;(define-key *gtags-select-mode-map* "q" 'gtags-pop-stack)
;;;(define-key *gtags-select-mode-map* u 'gtags-pop-stack)
(define-key *gtags-select-mode-map* #\C-t 'gtags-pop-stack)
(define-key *gtags-select-mode-map* #\C-m 'gtags-select-tag)
(define-key *gtags-select-mode-map* #\M-. 'gtags-select-tag)
|#


(defvar *gtags-select-mode-map* nil
  "gtags-mode: Local keymap")
(unless *gtags-select-mode-map*
  (setq *gtags-select-mode-map* (make-sparse-keymap))
  (define-key *gtags-select-mode-map* #\C-b 'fast-scroll-down)
  (define-key *gtags-select-mode-map* #\C-f 'fast-scroll-up)

  (define-key *gtags-select-mode-map* #\k 'previous-virtual-line)
  (define-key *gtags-select-mode-map* #\j 'next-virtual-line)
  (define-key *gtags-select-mode-map* #\p 'previous-virtual-line)
  (define-key *gtags-select-mode-map* #\n 'next-virtual-line)

  (define-key *gtags-select-mode-map* #\q 'gtags-pop-stack)
  (define-key *gtags-select-mode-map* #\u 'gtags-pop-stack)
  (define-key *gtags-select-mode-map* #\C-t 'gtags-pop-stack)

  (define-key *gtags-select-mode-map* #\C-m 'gtags-select-tag)
  (define-key *gtags-select-mode-map* #\M-. 'gtags-select-tag)
  )

;;
;; utility
;;
(defun gtags-match-string (n)
  (buffer-substring (match-beginning n) (match-end n)))

;; Return a default tag to search for, based on the text at point.
(defun gtags-current-token ()
  (cond
   ((looking-at "[0-9A-Za-z_]")
    (while (looking-at "[0-9A-Za-z_]")
      (forward-char -1))
    (forward-char 1))
   (t
    (while (looking-at "[ \t]")
      (forward-char 1))))
  (if (and (bolp) (looking-at *gtags-definition-regexp*))
      (goto-char (match-end 0)))
  (if (looking-at *gtags-symbol-regexp*)
      (gtags-match-string 0) nil))

;; push current context to stack
(defun gtags-push-context ()
  (setq *gtags-buffer-stack* (cons (selected-buffer) *gtags-buffer-stack*))
  (setq *gtags-point-stack* (cons (point) *gtags-point-stack*)))

;; pop context from stack
(defun gtags-pop-context ()
  (if (not *gtags-buffer-stack*) nil
    (let (buffer point)
      (setq buffer (car *gtags-buffer-stack*))
      (setq *gtags-buffer-stack* (cdr *gtags-buffer-stack*))
      (setq point (car *gtags-point-stack*))
      (setq *gtags-point-stack* (cdr *gtags-point-stack*))
      (list buffer point))))

;; if the buffer exist in the stack
(defun gtags-exist-in-stack (buffer)
  (member buffer *gtags-buffer-stack*))

;; is it a function?
(defun gtags-is-function ()
  (save-excursion
    (while (and (not (eolp)) (looking-at "[0-9A-Za-z_]"))
      (forward-char 1))
    (while (and (not (eolp)) (looking-at "[ \t]"))
      (forward-char 1))
    (if (looking-at "(") t nil)))

;; is it a definition?
(defun gtags-is-definition ()
  (save-excursion
    (if (and (string-match "\.java$" (ed::get-buffer-file-name))
             (looking-at "[^(]+([^)]*)[ \t]*{"))
        t
      (if (bolp)
          t
        (progn
          (forward-word -1)
          (cond
           ((looking-at "define")
            (forward-char -1)
            (while (and (not (bolp)) (looking-at "[ \t]"))
              (forward-char -1))
            (if (and (bolp) (looking-at "#"))
                t nil))
           ((looking-at "ENTRY\\|ALTENTRY")
            (if (bolp) t nil))))))))


;; Thanks to NANRI
(defun count-lines (beg end)
  (if (eql beg end)
      0
    (1+ (- (save-excursion
             (goto-char end)
             (when (eql (preceding-char) #\LFD) (backward-char))
             (current-line-number))
           (save-excursion
             (goto-char beg)
             (current-line-number))))))

(defun expand-file-name (file &optional (dir (default-directory)))
  (merge-pathnames file dir))

;;
;; interactive command
;;
(defun gtags-visit-rootdir ()
  "Tell tags commands the root directory of source tree."
  (interactive)
  (let (buffer input n)
    (if (equal *gtags-rootdir* nil)
        (save-excursion
          (setq buffer (create-new-buffer "*rootdir*"))
          (set-buffer buffer)
          (setq n (call-process (concat "global " "-pr")))
          (if (eq n 0)
              (setq *gtags-rootdir* (file-name-as-directory (buffer-substring (point-min) (1- (point-max)))))
            (setq *gtags-rootdir* (default-directory)))
          (kill-buffer buffer)))
    (setq input (read-file-name "Visit root directory: "
                                :default *gtags-rootdir*))
    (if (equal "" input) nil
      (when (not (file-directory-p input))
        (message "~s is not directory." input)
        (setq *gtags-rootdir* (expand-file-name input))
        (si::setenv "GTAGSROOT" *gtags-rootdir*)))))

(defun gtags-find-tag ()
  "Input tag name and move to the definition."
  (interactive)
  (let (tagname prompt input)
    (setq tagname (gtags-current-token))
    (if tagname
        (setq prompt (concat "Find tag: (default " tagname ") "))
      (setq prompt "Find tag: "))
    (setq input (completing-read prompt *gtags-complete-list*
                                 nil nil nil *gtags-history-list*))
    (if (not (equal "" input))
        (setq tagname input))
    (gtags-push-context)
    (gtags-goto-tag tagname "")))

(defun gtags-find-rtag ()
  "Input tag name and move to the referenced point."
  (interactive)
  (let (tagname prompt input)
    (setq tagname (gtags-current-token))
    (if tagname
        (setq prompt (concat "Find tag (reference): (default " tagname ") "))
      (setq prompt "Find tag (reference): "))
    (setq input (completing-read prompt *gtags-complete-list*
                                 nil nil nil *gtags-history-list*))
    (if (not (equal "" input))
        (setq tagname input))
    (gtags-push-context)
    (gtags-goto-tag tagname "r")))

(defun gtags-find-symbol ()
  "Input symbol and move to the locations."
  (interactive)
  (let (tagname prompt input)
    (setq tagname (gtags-current-token))
    (if tagname
        (setq prompt (concat "Find symbol: (default " tagname ") "))
      (setq prompt "Find symbol: "))
    (setq input (completing-read prompt *gtags-complete-list*
                                 nil nil nil *gtags-history-list*))
    (if (not (equal "" input)) (setq tagname input))
    (gtags-push-context)
    (gtags-goto-tag tagname "s")))

(defun gtags-find-pattern ()
  "Input pattern, search with grep(1) and move to the locations."
  (interactive)
  (gtags-find-with-grep))

(defun gtags-find-with-grep ()
  "Input pattern, search with grep(1) and move to the locations."
  (interactive)
  (gtags-find-with "g"))

(defun gtags-find-with-idutils ()
  "Input pattern, search with id-utils(1) and move to the locations."
  (interactive)
  (gtags-find-with "I"))

(defun gtags-find-file ()
  "Input pattern and move to the top of the file."
  (interactive)
  (let (tagname prompt input)
    (setq prompt "Find files: ")
    (setq input (read-string prompt))
    (if (not (equal "" input)) (setq tagname input))
    (gtags-push-context)
    (gtags-goto-tag tagname "P")))

(defun gtags-parse-file ()
  "Input file name, parse it and show object list."
  (interactive)
  (let (tagname prompt input)
    (setq input (read-file-name "Parse file: "
                                :title (ed::get-buffer-file-name)))
    ;nil nil t (file-name-nondirectory buffer-file-name)))
    (if (not (equal "" input)) (setq tagname input))
    (gtags-push-context)
    (gtags-goto-tag tagname "f")))

(defun gtags-find-tag-from-here ()
  "Get the expression as a tagname around here and move there."
  (interactive)
  (let (tagname flag)
    (setq tagname (gtags-current-token))
    (if (gtags-is-function)
        (if (gtags-is-definition) (setq flag "r") (setq flag ""))
      (setq flag "s"))
    (if (not tagname)
        nil
      (progn
        (gtags-push-context)
        (gtags-goto-tag tagname flag)))))

; This function doesn't work with mozilla.
; But I will support it in the near future.
(defun gtags-display-browser ()
  "Display current screen on hypertext browser."
  (interactive)
  (let (lno)
    (when (eq 0 (count-lines (point-min) (point-max))) nil
      (save-excursion
        (end-of-line)
        (if (equal (point-min) (point))
            (setq lno 1)
          (setq lno (count-lines (point-min) (point)))))
      (call-process "gozilla"  nil t nil (concat "+" (format nil "~A" lno)) #'editor::get-buffer-file-name))))

(defun gtags-find-tag-by-event (event)
  "Get the expression as a tagname around here and move there."
;;;  (interactive "e")
  (interactive)
  (let (tagname flag)
    (if (eq 0 (count-lines (point-min) (point-max)))
        (progn (setq tagname "main") (setq flag ""))
      (progn
        ;      (if gtags-running-xemacs (goto-char (event-point event))
        ;        (select-window (posn-window (event-end event)))
        ;        (set-buffer (window-buffer (posn-window (event-end event))))
        ;        (goto-char (posn-point (event-end event))))
        (setq tagname (gtags-current-token))
        (if (gtags-is-function)
            (if (gtags-is-definition) (setq flag "r") (setq flag ""))
          (setq flag "s"))))
    (when (not tagname)
        nil
      (gtags-push-context)
      (gtags-goto-tag tagname flag))))

(defun gtags-select-tag ()
  "Select a tag in [GTAGS SELECT MODE] and move there."
  (interactive)
  (gtags-push-context)
  (gtags-select-it nil))

(defun gtags-select-tag-by-event (event)
  "Select a tag in [GTAGS SELECT MODE] and move there."
;;;  (interactive "e")
    (interactive)
#|
  (if gtags-running-xemacs (goto-char (event-point event))
    (select-window (posn-window (event-end event)))
    (set-buffer (window-buffer (posn-window (event-end event))))
    (goto-char (posn-point (event-end event))))
|#
  (gtags-push-context)
  (gtags-select-it nil))

(defun gtags-pop-stack ()
  "Move to previous point on the stack."
  (interactive)
  (let (delete context buffer)
    (if (and (not (equalp *gtags-current-buffer* nil))
             (not (equalp *gtags-current-buffer* (selected-buffer))))
        (switch-to-buffer *gtags-current-buffer*)
      (progn
        (if (not (gtags-exist-in-stack (selected-buffer)))
            (setq delete t))
        (progn
          (setq context (gtags-pop-context))
          (if (not context)
              (message "The tags stack is empty.")
            (progn
              (if delete
                  (kill-buffer (selected-buffer)))
              (switch-to-buffer (nth 0 context))
              (setq *gtags-current-buffer* (selected-buffer))
              (goto-char (nth 1 context)))))))))

;;
;; common function
;;

;; find with grep or id-utils.
(defun gtags-find-with (flag)
  (let (tagname prompt input)
    (setq tagname (gtags-current-token))
    (if tagname
        (setq prompt (concat "Find pattern: (default " tagname ") "))
      (setq prompt "Find pattern: "))
    (setq input (completing-read prompt *gtags-complete-list*
                 nil nil nil *gtags-history-list*))
    (if (not (equal "" input)) (setq tagname input))
    (gtags-push-context)
    (gtags-goto-tag tagname flag)))

;; goto tag's point
(defun gtags-goto-tag (tagname flag)
  (let (save prefix buffer lines)
    (setq save (selected-buffer))
    (cond
     ((equal flag "P")
      (setq prefix "(P)"))
     ((equal flag "g")
      (setq prefix "(GREP)"))
     ((equal flag "I")
      (setq prefix "(IDUTILS)"))
     ((equal flag "s")
      (setq prefix "(S)"))
     ((equal flag "r")
      (setq prefix "(R)"))
     (t (setq prefix "(D)")))
    ;; load tag
    ;    (let ((gtags-buffer-name "*GTAGS SELECT*")) ;; NEW
    ;      (if (find-buffer gtags-buffer-name)        ;; NEW
    ;	  (kill-buffer gtags-buffer-name))      ;; NEW
    (setq buffer (create-new-buffer (concat "*GTAGS SELECT* " prefix " " tagname))) ;; OLD
    ;      (setq buffer (create-new-buffer gtags-buffer-name))) ;; NEW

    (set-buffer buffer)
    (message "Searching ~s ..." tagname)
    (setq command (concat "global -ax" flag " " tagname))

    (if (not (eq 0 (execute-shell-command command nil (selected-buffer))))
        (progn (message (buffer-substring (point-min) (1- (point-max))))
          (gtags-pop-context))
      (progn
        (goto-char (point-min))
        (setq lines (count-lines (point-min) (point-max)))
        (cond
         ((eq 0 lines)
          (cond
           ((equal flag "P")
            (message "~s: path not found" tagname))
           ((equal flag "g")
            (message "~s: pattern not found" tagname))
           ((equal flag "I")
            (message "~s: token not found" tagname))
           ((equal flag "s")
            (message "~s: symbol not found" tagname))
           (t
            (message "~s: tag not found" tagname)))
          (gtags-pop-context)
          (kill-buffer buffer)
          (set-buffer save))
         ((eq 1 lines)
          (message "Searching ~s ... Done" tagname)
          (gtags-select-it t)
          )
         (t
          (switch-to-buffer buffer)
          (gtags-select-mode)))
        )
      )))

;; select a tag line from lines
(defun gtags-select-it (delete)
  (let (line file)
    ;; get context from current tag line
    (beginning-of-line)
    (if (not (looking-at "[^ \t]+[ \t]+\\([0-9]+\\)[ \t]\\([^ \t]+\\)[ \t]"))
        (gtags-pop-context)
      (progn
        (setq line (parse-integer (match-string 1)))
        (setq file (gtags-match-string 2))
        (if delete (delete-buffer (selected-buffer)))

        ;; move to the context
        (if *gtags-read-only*
            (find-file-read-only file)
          (find-file file))
        (setq *gtags-current-buffer* (selected-buffer))
        (goto-line line)
        (gtags-mode 1)
        ))))

;; make complete list
(defun gtags-make-complete-list ()
  "Make tag name list for completion."
  (interactive)
  (save-excursion
    (message "Making completion list ...")
    (setq *gtags-complete-list* (make-vector 63 :fill-point 0))
    (set-buffer (create-new-buffer "*Completions*"))
    (execute-shell-command "global -c" nil (selected-buffer))
    (goto-char (point-min))
    (while (looking-at *gtags-symbol-regexp*)
      (intern (gtags-match-string 0) *gtags-complete-list*)
      (forward-line))
    (message "Making completion list ... Done")
    (kill-buffer (selected-buffer))))

;;;###autoload
(defun gtags-mode (&optional (arg nil sv))
  "Toggle Gtags mode, a minor mode for browsing source code using GLOBAL.
Input tag name and move to the definition.
\\[gtags-find-tag]
Input tag name and move to the referenced point.
\\[gtags-find-rtag]
Input symbol and move to the locations.
\\[gtags-find-symbol]
Input pattern, search with grep(1) and move to the locations.
\\[gtags-find-with-grep]
Input pattern, search with id-utils(1) and move to the locations.
\\[gtags-find-with-idutils]
Input pattern and move to the top of the file.
\\[gtags-find-file]
Get the expression as a tagname around here and move there.
\\[gtags-find-tag-from-here]
Display current screen on hypertext browser.
\\[gtags-display-browser]
Get the expression as a tagname around here and move there.
\\[gtags-find-tag-by-event]
Move to previous point on the stack.
\\[gtags-pop-stack]
Make tag name list for completion.
\\[gtags-make-complete-list]

Key definitions:
\\{gtags-mode-map}
Turning on Gtags mode calls the value of the variable `gtags-mode-hook'
with no args, if that value is non-nil."
  (interactive "p")
  (toggle-mode 'gtags-mode arg sv)
  (if gtags-mode
      (set-minor-mode-map *gtags-mode-map*)
    (unset-minor-mode-map *gtags-mode-map*))
  (update-mode-line t);)
  (run-hooks '*gtags-mode-hook*))

(pushnew '(gtags-mode . "Gtags") *minor-mode-alist* :key #'car)


;; make gtags select-mode
(defun gtags-select-mode ()
  "Major mode for choosing a tag from tags list.

Select a tag in tags list and move there.
\\[gtags-select-tag]
Move to previous point on the stack.
\\[gtags-pop-stack]

Key definitions:
\\{gtags-select-mode-map}
Turning on Gtags-Select mode calls the value of the variable
`gtags-select-mode-hook' with no args, if that value is non-nil."
  (interactive)
  (kill-all-local-variables)
  ;(use-keymap *gtags-select-mode-map*)
  (setq buffer-read-only t)
  ;truncate-lines t
  ;major-mode 'gtags-select-mode
  (setq buffer-mode 'gtags-select-mode)
  (setq mode-name "Gtags-Select")
  (setq *gtags-current-buffer* (selected-buffer))
  (goto-char (point-min))
  (message "[GTAGS SELECT MODE] ~D lines" (count-lines (point-min) (point-max)))
  (use-keymap *gtags-select-mode-map*)
  (run-hooks '*gtags-select-mode-hook*))

;;; gtags.l ends here
