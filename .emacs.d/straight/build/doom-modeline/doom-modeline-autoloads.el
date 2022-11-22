;;; doom-modeline-autoloads.el --- automatically extracted autoloads
;;
;;; Code:


;;;### (autoloads nil "doom-modeline" "doom-modeline.el" (0 0 0 0))
;;; Generated autoloads from doom-modeline.el

(autoload 'doom-modeline-set-main-modeline "doom-modeline" "\
Set main mode-line.
If DEFAULT is non-nil, set the default mode-line for all buffers.

\(fn &optional DEFAULT)" nil nil)

(defvar doom-modeline-mode nil "\
Non-nil if Doom-Modeline mode is enabled.
See the `doom-modeline-mode' command
for a description of this minor mode.
Setting this variable directly does not take effect;
either customize it (see the info node `Easy Customization')
or call the function `doom-modeline-mode'.")

(custom-autoload 'doom-modeline-mode "doom-modeline" nil)

(autoload 'doom-modeline-mode "doom-modeline" "\
Toggle `doom-modeline' on or off.

\(fn &optional ARG)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "doom-modeline" '("doom-modeline-")))

;;;***

;;;### (autoloads nil "doom-modeline-core" "doom-modeline-core.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from doom-modeline-core.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "doom-modeline-core" '("doom-modeline")))

;;;***

;;;### (autoloads nil "doom-modeline-env" "doom-modeline-env.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from doom-modeline-env.el
 (autoload 'doom-modeline-env-setup-python "doom-modeline-env")
 (autoload 'doom-modeline-env-setup-ruby "doom-modeline-env")
 (autoload 'doom-modeline-env-setup-perl "doom-modeline-env")
 (autoload 'doom-modeline-env-setup-go "doom-modeline-env")
 (autoload 'doom-modeline-env-setup-elixir "doom-modeline-env")
 (autoload 'doom-modeline-env-setup-rust "doom-modeline-env")

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "doom-modeline-env" '("doom-modeline-")))

;;;***

;;;### (autoloads nil "doom-modeline-segments" "doom-modeline-segments.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from doom-modeline-segments.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "doom-modeline-segments" '("doom-modeline-")))

;;;***

(provide 'doom-modeline-autoloads)
;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; doom-modeline-autoloads.el ends here
