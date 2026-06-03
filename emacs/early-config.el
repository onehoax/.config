;;; -*- lexical-binding: t; -*-

;; Disable scrollbar
(scroll-bar-mode nil)

;; Disable toolbar
(tool-bar-mode nil)

;; Disable menu bar
(menu-bar-mode nil)

;; Set frame dimensions on init and subsequent frames created
(setq initial-frame-alist
      '((width . 150)
        (height . 50))
      ;;'(fullscreen . maximized)

      default-frame-alist initial-frame-alist)
