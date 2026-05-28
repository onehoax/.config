;;; -*- lexical-binding: t; -*-

(require 'package)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/")
             t)

(require 'use-package)

(setq use-package-always-ensure t)

(setq org-src-preserve-indentation t)
(setq org-edit-src-content-indentation nil)

(use-package org-modern
  :hook (org-mode . org-modern-mode))

(use-package toc-org
  :hook (org-mode . toc-org-mode))

(add-hook 'org-mode-hook #'org-indent-mode)

(require 'org-tempo)

;; Expansions
(with-eval-after-load 'org
  (add-to-list 'org-structure-template-alist
                 '("el" . "src emacs-lisp"))

  (add-to-list 'org-structure-template-alist
               '("sh" . "src shell"))

  (add-to-list 'org-structure-template-alist
               '("js" . "src javascript"))

  (add-to-list 'org-structure-template-alist
               '("ts" . "src typescript")))

(with-eval-after-load 'org
  (tempo-define-template
   "org-header"
   '("#+TITLE: " p n
     "#+AUTHOR: Andres Osorio" n
     "#+DESCRIPTION: " n
     "#+DATE: " (format-time-string "%Y-%m-%d") n
     "#+STARTUP: content" n n
     "* TABLE OF CONTENTS :toc:" n n)
   "<oh"))

(defun my/org-no-angle-brackets ()
  (let ((old-predicate electric-pair-inhibit-predicate))
    (setq-local electric-pair-inhibit-predicate
                (lambda (c)
                  (if (char-equal c ?<)
                      t
                    (funcall old-predicate c))))))

(add-hook 'org-mode-hook #'my/org-no-angle-brackets)

(setq
 ;; The customize system in Emacs provides a user-friendly way to configure settings without directly editing init.el.
 ;; However, can't easily be disabled, so discard its contents.
 custom-file "/dev/null"

 ;; No backup files, please
 make-backup-files nil

 ;; Disable auto-save
 auto-save-default nil

 ;; Disable lock files
 create-lockfiles nil

 ;; Inhibit startup dashboard
 inhibit-startup-message t

 ;; Flash the UI instead of beeping
 visible-bell t)

;; Disable visible scrollbar
(scroll-bar-mode -1)

;; Disable the toolbar
(tool-bar-mode -1)

;; Disable the menu bar
(menu-bar-mode -1)

;; Show line numbers
(global-display-line-numbers-mode 1)

;; Show column number on mode line
(column-number-mode 1)

;; Very nice smooth scrolling on modern Emacs.
(pixel-scroll-precision-mode 1)

;; Fullscreen on init
;;(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; Set frame dimensions on init and subsequent frames created
(setq initial-frame-alist
      '((width . 150)
        (height . 50))

      default-frame-alist initial-frame-alist)

;; Tabs to spaces
(setq-default
 indent-tabs-mode nil
 tab-width 2)

;; Refresh buffer contents when corresponding file is saved to disk from somewhere else
(global-auto-revert-mode 1)

;; Automatic pairing of delimeters
(electric-pair-mode t)

(load-theme 'wombat)

(add-hook 'shell-mode-hook
          (lambda ()
            (display-line-numbers-mode 0)))

(put 'narrow-to-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; files
(keymap-global-unset "C-x C-f")
(keymap-global-set "C-x f" #'find-file)

;; buffers
(keymap-global-set "C-x C-b" #'buffer-menu)

;; completion
(keymap-global-set "C-;" #'completion-at-point)

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

;; press `RET` only once to choose and execute option in (e)shell
;;(keymap-set corfu-map "RET" #'corfu-send)

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
  :ensure t)

(transient-define-prefix my/lsp-menu ()
  "LSP + Diagnostics control panel"
  [
   ;;["Navigation (xref)"
   ;; `xref-find-definitions` can't ID the symbol at point when called from here for some reason; use `M-,` instead.
   ;; ("d" "definition" xref-find-definitions)
   ;; the rest of the functions below do work well but just use the default `xref` keybindings for consistency.
   ;; ("r" "references" xref-find-references) `M-?`
   ;; ("b" "back" xref-go-back) `M-,`
   ;; ("f" "forward" xref-go-forward)] `M-C-,`

   ["Refactor (Eglot)"
    ("r" "rename symbol" eglot-rename)
    ("a" "code actions" eglot-code-actions)
    ("f" "format buffer" eglot-format)
    ("s" "restart server" eglot-reconnect)]

   ["Diagnostics (Flymake)"
    ("n" "next error" flymake-goto-next-error)
    ("p" "previous error" flymake-goto-prev-error)
    ("l" "list diagnostics" flymake-show-buffer-diagnostics)]])

(keymap-global-set "C-c l" #'my/lsp-menu)
