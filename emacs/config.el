;;; -*- lexical-binding: t; -*-

(require 'package)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/")
             t)

(package-initialize)

(require 'use-package)

(setq use-package-always-ensure t)

(defun my/fix-scratch-margin ()
  (with-current-buffer "*scratch*"
    (kill-local-variable 'left-margin-width)
    (set-window-buffer nil (current-buffer))))

(defun my/copy-line ()
  "Copy line without killing."
  (interactive)
  (save-excursion
    (kill-new
     (buffer-substring
      (line-beginning-position)
      (line-beginning-position 2))))
  (message "Line copied"))

(defun my/shell-mode-setup ()
  (display-line-numbers-mode 0))

(use-package emacs
  :ensure nil

  :init
  ;; Tabs to spaces and width
  (setq-default
   indent-tabs-mode nil
   tab-width 2)

  :config
  ;; Theme
  (load-theme 'wombat t)

  ;; Show line numbers
  (global-display-line-numbers-mode t)

  ;; Show column number on mode line
  (column-number-mode t)

  ;; Very nice smooth scrolling on modern Emacs.
  (pixel-scroll-precision-mode t)

  ;; Refresh buffer contents when corresponding file is saved to disk from somewhere else
  (global-auto-revert-mode 1)

  ;; Automatic pairing of delimeters
  (electric-pair-mode t)

  ;; Replace selected region with input
  (delete-selection-mode t)

  ;; Disabled commands by default
  (put 'narrow-to-region 'disabled nil)
  (put 'upcase-region 'disabled nil)

  ;;;; Keybindings
  ;; Files
  (keymap-global-unset "C-x C-f")
  (keymap-global-set "C-x f" #'find-file)

  ;; Buffers
  (keymap-global-set "C-x C-b" #'buffer-menu)

  ;; Completion
  (keymap-global-set "C-;" #'completion-at-point)

  ;; Copy line
  (keymap-global-set "C-c w" #'my/copy-line)

  ;; Invoke shell
  (keymap-global-set "C-c s" #'shell)

  :custom
  ;; The customize system in Emacs provides a user-friendly way to configure settings without directly editing init.el.
  ;; However, can't easily be disabled, so discard its contents.
  (custom-file "/dev/null")

  ;; No backup files, please
  (make-backup-files nil)

  ;; Disable auto-save
  (auto-save-default nil)

  ;; Disable lock files
  (create-lockfiles nil)

  ;; Inhibit startup dashboard
  (inhibit-startup-message t)

  ;; Flash the UI instead of beeping
  (visible-bell t)
  
  ;; Column boundary
  (fill-column 120)
  
  :hook
  ;; Left margin on scratch gets set to 2 on daemon+client setup for some reason - set it back to 0
  (emacs-startup . my/fix-scratch-margin)

  ;; Enable flymake for elisp files
  (emacs-lisp-mode . flymake-mode)

  ;; Disable line numbers in shell buffers
  (shell-mode . my/shell-mode-setup))

(defun my/org-no-angle-brackets ()
  (let ((old-predicate electric-pair-inhibit-predicate))
    (setq-local electric-pair-inhibit-predicate
                (lambda (c)
                  (if (char-equal c ?<)
                      t
                    (funcall old-predicate c))))))

(use-package org
  :ensure nil
  
  :custom
  ;; prevent org from modifying the whitespace inside your code blocks
  ;;(org-src-preserve-indentation t)
  ;; keep some org-mode formatting features but want the code content to start at the absolute beginning of the line
  (org-edit-src-content-indentation 0)
  (org-directory "~/org")
  (org-default-notes-file (expand-file-name "notes.org" org-directory))
  (org-agenda-files (list org-directory))
  
  :hook
  (org-mode . my/org-no-angle-brackets)
  (org-mode . org-indent-mode))

(use-package org-tempo
  :ensure nil
  
  :after org
  
  :config
  (dolist (template '(("el" . "src emacs-lisp")
                      ("sh" . "src shell")
                      ("js" . "src javascript")
                      ("ts" . "src typescript")))
    (add-to-list 'org-structure-template-alist template))

  (tempo-define-template
   "org-header"
   '("#+TITLE: " p n
     "#+AUTHOR: Andres Osorio" n
     "#+DESCRIPTION: " n
     "#+DATE: " (format-time-string "%Y-%m-%d") n
     "#+STARTUP: content" n n
     "* TABLE OF CONTENTS :toc:" n n)
   "<oh"))

(use-package toc-org
  :hook (org-mode . toc-org-mode))

(use-package corfu
  :init
  (global-corfu-mode))

;; minibuffer
(setq global-corfu-minibuffer
      (lambda ()
        (not (or (bound-and-true-p mct--active)
                 (bound-and-true-p vertico--input)
                 (eq (current-local-map) read-passwd-map)))))

(add-hook 'eshell-mode-hook (lambda ()
                              (setq-local corfu-auto nil)
                              (corfu-mode)))

(use-package exec-path-from-shell
  :if (daemonp)
  :config
  (exec-path-from-shell-initialize))

(use-package eglot
  :ensure nil
  :hook ((js-ts-mode
          typescript-ts-mode
          tsx-ts-mode) . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs
               '((js-ts-mode
                  typescript-ts-mode
                  tsx-ts-mode)
                 . ("vtsls" "--stdio"))))

(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . tsx-ts-mode))

(add-to-list 'major-mode-remap-alist
             '(javascript-mode . js-ts-mode))

(add-to-list 'major-mode-remap-alist
             '(typescript-mode . typescript-ts-mode))

(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))

(use-package transient
  :ensure nil)

(defun my/eval-init ()
  "Evaluate emacs `init.el' file."
  (interactive)
  (with-current-buffer
      (find-file-noselect user-init-file)
    (eval-buffer)
    (message "Reloaded init.el")))

(transient-define-prefix my/menu-general ()
  "General"
  [["Buffer"
    ("e" "evaluate buffer (elisp)" eval-buffer)
    ("k" "kill buffer" kill-buffer)]

   ["Config"
    ("c" "open config.org"
     (lambda ()
       (interactive)
       (find-file "~/.config/emacs/config.org")))
    ("t" "open todo.org"
     (lambda ()
       (interactive)
       (find-file "~/org/todo.org")))
    ("i" "evaluate init.el" my/eval-init)]])

(keymap-global-set "C-c g" #'my/menu-general)

(transient-define-prefix my/menu-search-&-replace ()
  "Search & Replace"
  [["Normal (All Instances After Cursor)"
    ("ns" "string matches" replace-string)
    ("nr" "regex matches" replace-regexp)]

   ["Interactive (Use Chooses Action On Each Instance)"
    ("is" "string matches" query-replace)
    ("ir" "regex matches" query-replace-regexp)]])

(keymap-global-set "C-c r" #'my/menu-search-&-replace)

(transient-define-prefix my/menu-diagnostics ()
  "Diagnostics"
  [["Flymake"
    ("n" "next error" flymake-goto-next-error)
    ("p" "previous error" flymake-goto-prev-error)
    ("l" "list diagnostics" flymake-show-buffer-diagnostics)]])

(keymap-global-set "C-c d" #'my/menu-diagnostics)

(transient-define-prefix my/menu-lsp ()
  "LSP"
  [
   ;;["Navigation (xref)"
   ;; `xref-find-definitions` can't ID the symbol at point when called from here for some reason; use `M-,` instead.
   ;; ("d" "definition" xref-find-definitions)
   ;; the rest of the functions below do work well but just use the default `xref` keybindings for consistency.
   ;; ("r" "references" xref-find-references) `M-?`
   ;; ("b" "back" xref-go-back) `M-,`
   ;; ("f" "forward" xref-go-forward)] `M-C-,`

   ["Eglot"
    ("r" "rename symbol" eglot-rename)
    ("a" "code actions" eglot-code-actions)
    ("f" "format buffer" eglot-format)
    ("s" "restart server" eglot-reconnect)]])

(keymap-global-set "C-c l" #'my/menu-lsp)
