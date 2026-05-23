(setq
 ;; The customize system in Emacs provides a user-friendly way to configure settings without directly editing init.el.
 ;; However, can't easily be disabled, so discard its contents
 custom-file "/dev/null"

 ;; No backup files, please
 make-backup-files nil

 ;; Disable auto-save
 auto-save-default nil
 )

(setq-default
 ;; Tabs to spaces
 indent-tabs-mode nil
 tab-width 2
 )

(load-theme 'wombat)

(setq
 ;; Inhibit startup dashboard
 inhibit-startup-message t

 ;; Flash the UI instead of beeping
 visible-bell t
 )

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
        (height . 50)))
(setq default-frame-alist initial-frame-alist)

(add-hook 'shell-mode-hook
          (lambda ()
            (display-line-numbers-mode 0)))

(put 'narrow-to-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;;;; keybinds
(keymap-global-unset "C-x C-f")
(keymap-global-set "C-x f" 'find-file)
(keymap-global-set "C-x C-b" 'buffer-menu)

