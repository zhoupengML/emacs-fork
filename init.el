;; -*- coding: utf-8 -*-
;(defvar best-gc-cons-threshold gc-cons-threshold "Best default gc threshold value. Should't be too big.")
(defvar best-gc-cons-threshold 4000000 "Best default gc threshold value. Should't be too big.")
;; don't GC during startup to save time
(setq gc-cons-threshold most-positive-fixnum)

(setq emacs-load-start-time (current-time))
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp"))

;;----------------------------------------------------------------------------
;; Which functionality to enable (use t or nil for true and false)
;;----------------------------------------------------------------------------
(setq *is-a-mac* (eq system-type 'darwin))
(setq *win64* (eq system-type 'windows-nt) )
(setq *cygwin* (eq system-type 'cygwin) )
(setq *linux* (or (eq system-type 'gnu/linux) (eq system-type 'linux)) )
(setq *unix* (or *linux* (eq system-type 'usg-unix-v) (eq system-type 'berkeley-unix)) )
(setq *emacs24* (and (not (featurep 'xemacs)) (or (>= emacs-major-version 24))) )
(setq *no-memory* (cond
                   (*is-a-mac*
                    (< (string-to-number (nth 1 (split-string (shell-command-to-string "sysctl hw.physmem")))) 4000000000))
                   (*linux* nil)
                   (t nil)))

;; *Message* buffer should be writable in 24.4+
(defadvice switch-to-buffer (after switch-to-buffer-after-hack activate)
  (if (string= "*Messages*" (buffer-name))
      (read-only-mode -1)))

;; @see https://www.reddit.com/r/emacs/comments/3kqt6e/2_easy_little_known_steps_to_speed_up_emacs_start/
;; Normally file-name-handler-alist is set to
;; (("\\`/[^/]*\\'" . tramp-completion-file-name-handler)
;; ("\\`/[^/|:][^/|]*:" . tramp-file-name-handler)
;; ("\\`/:" . file-name-non-special))
;; Which means on every .el and .elc file loaded during start up, it has to runs those regexps against the filename.
(let ((file-name-handler-alist nil))
  (require 'init-autoload)
  (require 'init-modeline)
  (require 'cl-lib)
  (require 'init-compat)
  (require 'init-utils)
  (require 'init-site-lisp) ;; Must come before elpa, as it may provide package.el

  ;; Windows configuration, assuming that cygwin is installed at "c:/cygwin"
  ;; (condition-case nil
  ;;     (when *win64*
  ;;       ;; (setq cygwin-mount-cygwin-bin-directory "c:/cygwin/bin")
  ;;       (setq cygwin-mount-cygwin-bin-directory "c:/cygwin64/bin")
  ;;       (require 'setup-cygwin)
  ;;       ;; better to set HOME env in GUI
  ;;       ;; (setenv "HOME" "c:/cygwin/home/someuser")
  ;;       )
  ;;   (error
  ;;    (message "setup-cygwin failed, continue anyway")
  ;;    ))

  (require 'idle-require)
  (require 'init-elpa)
  (require 'init-exec-path) ;; Set up $PATH
  (require 'init-frame-hooks)
  ;; any file use flyspell should be initialized after init-spelling.el
  ;; actually, I don't know which major-mode use flyspell.
  (require 'init-spelling)
  (require 'init-xterm)
  (require 'init-gui-frames)
  (require 'init-ido)
  (require 'init-dired)
  (require 'init-uniquify)
  (require 'init-ibuffer)
  (require 'init-flymake)
  (require 'init-ivy)
  (require 'init-hippie-expand)
  (require 'init-windows)
  (require 'init-sessions)
  (require 'init-git)
  (require 'init-crontab)
  (require 'init-markdown)
  (require 'init-erlang)
  (require 'init-javascript)
  (require 'init-org)
  (require 'init-css)
  (require 'init-python-mode)
  (require 'init-haskell)
  (require 'init-ruby-mode)
  (require 'init-lisp)
  (require 'init-elisp)
  (require 'init-yasnippet)
  ;; Use bookmark instead
  (require 'init-zencoding-mode)
  (require 'init-cc-mode)
  (require 'init-gud)
  (require 'init-linum-mode)
  ;; (require 'init-gist)
  (require 'init-moz)
  (require 'init-gtags)
  ;; init-evil dependent on init-clipboard
  (require 'init-clipboard)
  ;; use evil mode (vi key binding)
;;  (require 'init-evil)			
  (require 'init-sh)
  (require 'init-ctags)
  (require 'init-bbdb)
  (require 'init-gnus)
  (require 'init-lua-mode)
  (require 'init-workgroups2)
  (require 'init-term-mode)
  (require 'init-web-mode)
  (require 'init-slime)
  (require 'init-company)
  (require 'init-chinese-pyim) ;; cannot be idle-required
  ;; need statistics of keyfreq asap
  (require 'init-keyfreq)
  (require 'init-httpd)

  ;; projectile costs 7% startup time

  ;; misc has some crucial tools I need immediately
  (require 'init-misc)

  ;; comment below line if you want to setup color theme in your own way
  ;; (if (or (display-graphic-p) (string-match-p "256color"(getenv "TERM"))) (require 'init-color-theme))

  (require 'init-emacs-w3m)
  (require 'init-hydra)

  ;; {{ idle require other stuff
  (setq idle-require-idle-delay 2)
  (setq idle-require-symbols '(init-misc-lazy
                               init-which-func
                               init-fonts
                               init-hs-minor-mode
                               init-writting
                               init-pomodoro
                               init-emacspeak
                               init-artbollocks-mode
                               init-semantic))
  (idle-require-mode 1) ;; starts loading
  ;; }}

  (when (require 'time-date nil t)
    (message "Emacs startup time: %d seconds."
             (time-to-seconds (time-since emacs-load-start-time))))

  ;; my personal setup, other major-mode specific setup need it.
  ;; It's dependent on init-site-lisp.el
  (if (file-exists-p "~/.custom.el") (load-file "~/.custom.el"))
  )

;; @see https://www.reddit.com/r/emacs/comments/4q4ixw/how_to_forbid_emacs_to_touch_configuration_files/
(setq custom-file (concat user-emacs-directory "custom-set-variables.el"))
(load custom-file 'noerror)

(setq gc-cons-threshold best-gc-cons-threshold)
;;; Local Variables:
;;; no-byte-compile: t
;;; End:
(put 'erase-buffer 'disabled nil)

;;;******************************
;;; cpputils-cmake
(add-hook 'c-mode-common-hook
          (lambda ()
            (if (derived-mode-p 'c-mode 'c++-mode)
                (cppcm-reload-all))))
;; OPTIONAL, somebody reported that they can use this package with Fortran
(add-hook 'c90-mode-hook (lambda () (cppcm-reload-all)))
;; OPTIONAL, avoid typing full path when starting gdb
(global-set-key (kbd "C-c C-g")
                '(lambda () (interactive) (gud-gdb (concat "gdb --fullname " (cppcm-get-exe-path-current-buffer)))))
;; OPTIONAL, some users need specify extra flags forwarded to compiler
(setq cppcm-extra-preprocss-flags-from-user '("-I/usr/src/linux/include" "-DNDEBUG"))
(put 'dired-find-alternate-file 'disabled nil)

;;;******************************
;; list recenly opened file
(global-set-key (kbd "<f7>")
                'recentf-open-files)

;;;******************************
(require 'dired)

;; (define-key dired-mode-map
;;   (kbd "RET") 'dired-find-alternate-file)

(define-key dired-mode-map
  (kbd "^") ( lambda ()
  (interactive) (find-alternate-file "..")))

;;;******************************
(load "flycheck-autoloads")

;;;******************************
;; (require 'ctags)
;; (setq tags-revert-without-query t)
;; (global-set-key (kbd "<f5>") 'ctags-create-or-update-tags-table)

;;;******************************
;;; etags 
(global-set-key (kbd "<f5>") 'visit-tags-table)
(global-set-key  [C-f5] 'sucha-generate-tag-table)

(defun sucha-generate-tag-table ()
  "Generate tag tables under current directory(Linux)."
  (interactive)
  (let
      ((exp "")
       (dir ""))
    (setq dir
          (read-from-minibuffer "generate tags in: " default-directory)
          exp
          "*[ch]*")
    (with-temp-buffer
      (shell-command
       (concat "find " dir " -name " "\"" exp "\"" " | xargs etags ")
              (buffer-name)))))

;; (read-from-minibuffer "suffix: "))

;;;******************************
;;set transparent effect
(global-set-key [(f9)] 'loop-alpha)

;; (setq alpha-list '((100 100)  (75 45) (10 35)))
(setq alpha-list '((100 100)  (75 45) (60 60)))

(defun loop-alpha ()
  (interactive)
  (let ((h (car alpha-list)))                ;; head value will set to
    ((lambda (a ab)
       (set-frame-parameter (selected-frame) 'alpha (list a ab))
       (add-to-list 'default-frame-alist (cons 'alpha (list a ab)))
       ) (car h) (car (cdr h)))
    (setq alpha-list (cdr (append alpha-list (list h))))
    )
  )

;;;******************************
(global-set-key [(f8)] 'multi-term)

;;;******************************
;;; ycmd
(require-package 'ycmd)
(require-package 'company-ycmd)
(require-package 'flycheck-ycmd)
; ;;;;;;;;;;;;;;;;;;;;;;;company;;;;;;;;;;;;;;;;;
(add-hook 'after-init-hook #'global-company-mode)
;;;;;;;;;;;;;;;;;;;;;;;;;;;flycheck;;;;;;;;;;;;;;;;
(add-hook 'after-init-hook #'global-flycheck-mode)
;;;;;;;;;;;;;;;;;;;emacs-ycmd;;;;;;;;;;;;;;;;;;;
(require 'ycmd)
(add-hook 'after-init-hook #'global-ycmd-mode)

;;(ycmd-force-semantic-completion t)
;; (ycmd-global-config nil)
(set-variable 'ycmd-server-command
              '("python" "/home/shhs/usr/soft/ycmd/ycmd"))

(set-variable 'ycmd-global-config "/home/shhs/usr/soft/ycmd/.ycm_extra_conf.py")
(set-variable 'ycmd-extra-conf-whitelist '("please add project .ycm_extra_conf.py"))
(require 'company-ycmd)
(company-ycmd-setup)
(require 'flycheck-ycmd)
(flycheck-ycmd-setup)
(global-ycmd-mode t)
(global-set-key [(f12)] 'ycmd-goto-definition)
(global-set-key [(S-f12)] 'ycmd-goto-declaration)

;;;******************************
(global-set-key [(f3)] 'read-only-mode)
(defun make-some-files-read-only ()
  "when file opened is of a certain mode, make it read only"
  (when (memq major-mode '(c++-mode c-mode))
    (toggle-read-only 1)))

;; (add-hook 'find-file-hooks 'make-some-files-read-only)

;;******************************
;; comment
(global-set-key [?\C-c ?\C-/] 'comment-or-uncomment-region)
(defun my-comment-or-uncomment-region (beg end &optional arg)
  (interactive (if (use-region-p)
                   (list (region-beginning) (region-end) nil)
                 (list (line-beginning-position)
                       (line-beginning-position 2))))
  (comment-or-uncomment-region beg end arg)
)
(global-set-key [remap comment-or-uncomment-region] 'my-comment-or-uncomment-region)

;;;******************************
;;;
;; 设置emacs窗口的位置和大小
;; 让窗口最大化
(defun my-max-window()
(x-send-client-message nil 0 nil "_NET_WM_STATE" 32
'(2 "_NET_WM_STATE_MAXIMIZED_HORZ" 0))
(x-send-client-message nil 0 nil "_NET_WM_STATE" 32
'(2 "_NET_WM_STATE_MAXIMIZED_VERT" 0))
)
(run-with-idle-timer 1 nil 'my-max-window)
;;;****************************** 
;;; new line under curent cursor
(global-set-key (kbd "C-o")
                '(lambda ()
                     (interactive)
                     (move-end-of-line 1)
                     (newline)))
;;;******************************
;;; turn off auto newline
;;;(c-toggle-newline -1)

;;;******************************
;;; org-mode 自动换行
(add-hook 'org-mode-hook (lambda () (setq truncate-lines nil)))

;;;******************************
;;; org-mode 插入源代码
(org-babel-do-load-languages
 'org-babel-load-languages
 '(
   (latex . t)
   (sh . t)
   (python . t)
   (R . t)
   (ruby . t)
   (ditaa . t)
   (dot . t)
   (octave . t)
   (sqlite . t)
   (perl . t)
   (C . t)
   ))

;;;******************************
;;; google-c-style

(add-hook 'c-mode-common-hook 'google-set-c-style)
(add-hook 'c-mode-common-hook 'google-make-newline-indent)

;;;******************************
;;; GTD 日程管理
(global-set-key (kbd "C-c c")  'remember)
;; GTD 收集项目的模板设置 
(org-remember-insinuate)
(setq org-directory "~/usr/notes/GTD")

(setq org-remember-templates '(
("Task" ?t "** TODO %? %t\n %i\n" (concat org-directory "/inbox.org") "Tasks")
("Book" ?b "** %? %t\n %i\n" (concat org-directory "/inbox.org") "Book")
("Calendar" ?c "** %? %t\n %i\n " (concat org-directory "/inbox.org") "Calender")
("Project" ?p "** %? %t\n %i\n " (concat org-directory "/inbox.org") "Project")))
(setq org-default-notes-file (concat org-directory "/inbox.org"))
;;设置TODO关键字
(setq org-todo-keywords
      (list "TODO(t)" "|" "CANCELED(c)" "DONE(d)"))
;; 将项目转接在各文件之间，方便清理和回顾。
(custom-set-variables
'(org-refile-targets
  (quote
   (("inbox.org" :level . 1)("canceled.org" :level . 1) ("finished.org":level . 1))
)))
;; 快速打开inbox
(defun inbox() (interactive) (find-file org-default-notes-file))
(global-set-key "\C-cz" 'inbox)

;; 快速启动 agenda-view
(define-key global-map "\C-ca" 'org-agenda-list)
(define-key global-map "\C-ct" 'org-todo-list)
(define-key global-map "\C-cm" 'org-tags-view)
;;显示他们的内容
(setq org-agenda-files
(list (concat org-directory "/inbox.org")
      (concat org-directory "/canceled.org")
      (concat org-directory "/finished.org")
      ))
;;;******************************
;;; 加载auctex
(load "auctex.el" nil t t)
(load "preview-latex.el" nil t t)
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)
;;; 使用C-c C-c编译tex文件，使用C-c C-v使用evince阅读生成的pdf文件
(setq TeX-output-view-style (quote (("^pdf$" "." "evince %o %(outpage)"))))
(add-hook 'LaTeX-mode-hook
(lambda()
(add-to-list 'TeX-command-list '("XeLaTeX" "%`xelatex%(mode)%' %t" TeX-run-TeX nil t))
(setq TeX-command-default "XeLaTeX")))


;;; set org latex size
(require 'org)
(setq org-format-latex-options (plist-put org-format-latex-options :scale 1.5))

;;;************************************************************
;;; Start my config *******************************************
;;;************************************************************

(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.milkbox.net/packages/")
	     t)
(add-to-list 'package-archives
	     '("marmalade" . "http://marmalade-repo.org/packages/")
	     t)
(package-initialize)

(require-package 'monokai-theme)
(require 'monokai-theme)
;; (load-theme 'monokai t)
;;;------------------------------------------------------------
;;; save your current opened buffer nad window layout,
;;;auto-restore next time
(require-package 'revive)
(autoload 'save-current-configuration "revive" "Save status" t)
(autoload 'resume "revive" "Resume Emacs" t)
(autoload 'wipe "revive" "Wipe Emacs" t)
;And define favorite keys to those functions.  Here is a sample.
(define-key ctl-x-map "S" 'save-current-configuration)
(define-key ctl-x-map "F" 'resume)
(define-key ctl-x-map "K" 'wipe)
;[Sample Operations]
;C-u 2 C-x S		;save status into the buffer #2
;C-u 3 C-x F		;load status from the buffer #3

;;;------------------------------------------------------------
(global-set-key (kbd "<f6>") 'find-file-in-project)
;;;------------------------------------------------------------
(require-package 'column-enforce-mode)
(column-enforce-mode)
(global-column-enforce-mode)
(setq column-enforce-column 80)
;;;------------------------------------------------------------
(require-package 'alpha)
(require 'alpha)
(global-set-key (kbd "C-M-)") 'transparency-increase)
(global-set-key (kbd "C-M-(") 'transparency-decrease)
;;;------------------------------------------------------------
;; (require-package 'ace-jump-mode)
;; repalced with avy 
(global-set-key (kbd "C->") 'avy-goto-word-or-subword-1)
;;;------------------------------------------------------------
;; buffer-move buf-move-down/up/right/left
;;;------------------------------------------------------------
;;; (require-package 'multiple-cursors)
(global-set-key (kbd "C-M-}") 'mc/mark-next-like-this)
(global-set-key (kbd "C-M-{") 'mc/mark-previous-like-this)
;;;------------------------------------------------------------
(require-package 'undo-tree)
(global-undo-tree-mode)
(global-set-key (kbd "M-/") 'undo-tree-visualize)
;;;------------------------------------------------------------





;;;************************************************************
;;; End my config *********************************************
;;;************************************************************

;;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
(desktop-save-mode t)
(global-company-mode t)
(show-paren-mode)
;;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

(provide 'init)


