;;; marginalia-autoloads.el --- automatically extracted autoloads
;;
;;; Code:


;;;### (autoloads nil "marginalia" "marginalia.el" (0 0 0 0))
;;; Generated autoloads from marginalia.el

(defvar marginalia-mode nil "\
Non-nil if Marginalia mode is enabled.
See the `marginalia-mode' command
for a description of this minor mode.
Setting this variable directly does not take effect;
either customize it (see the info node `Easy Customization')
or call the function `marginalia-mode'.")

(custom-autoload 'marginalia-mode "marginalia" nil)

(autoload 'marginalia-mode "marginalia" "\
Annotate completion candidates with richer information.

\(fn &optional ARG)" t nil)

(autoload 'marginalia-cycle "marginalia" "\
Cycle between annotators in `marginalia-annotator-registry'.

\(fn)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "marginalia" '("marginalia-")))

;;;***

(provide 'marginalia-autoloads)
;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; marginalia-autoloads.el ends here
