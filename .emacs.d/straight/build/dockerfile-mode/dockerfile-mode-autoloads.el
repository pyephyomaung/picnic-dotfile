;;; dockerfile-mode-autoloads.el --- automatically extracted autoloads  -*- lexical-binding: t -*-
;;
;;; Code:


;;;### (autoloads nil "dockerfile-mode" "dockerfile-mode.el" (0 0
;;;;;;  0 0))
;;; Generated autoloads from dockerfile-mode.el

(autoload 'dockerfile-build-buffer "dockerfile-mode" "\
Build an image called IMAGE-NAME based upon the buffer.

If the prefix arg NO-CACHE is set, don't cache the image.

The shell command used to build the image is:

    sudo docker build    \\
      --no-cache         \\
      --force-rm         \\
      --pull             \\
      --tag IMAGE-NAME   \\
      --build-args args  \\
      --progress type    \\
      -f filename        \\
      directory

\(fn IMAGE-NAME &optional NO-CACHE)" t nil)

(autoload 'dockerfile-build-no-cache-buffer "dockerfile-mode" "\
Build an image called IMAGE-NAME based upon the buffer without cache.

\(fn IMAGE-NAME)" t nil)

(autoload 'dockerfile-mode "dockerfile-mode" "\
A major mode to edit Dockerfiles.
\\{dockerfile-mode-map}

\(fn)" t nil)

(add-to-list 'auto-mode-alist (cons (concat "[/\\]" "\\(?:Containerfile\\|Dockerfile\\)" "\\(?:\\.[^/\\]*\\)?\\'") 'dockerfile-mode))

(add-to-list 'auto-mode-alist '("\\.dockerfile\\'" . dockerfile-mode))

(register-definition-prefixes "dockerfile-mode" '("dockerfile-"))

;;;***

(provide 'dockerfile-mode-autoloads)
;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; dockerfile-mode-autoloads.el ends here
