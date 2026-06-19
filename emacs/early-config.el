;;; -*- lexical-binding: t; -*-

;; Frame settings on init and subsequent frames created
(setq initial-frame-alist
      '((fullscreen . maximized)
        ;; (width . 150)
        ;; (height . 50)
        (vertical-scroll-bars . nil)
        (tool-bar-lines . 0)
        (menu-bar-lines . 0))

      default-frame-alist initial-frame-alist)
