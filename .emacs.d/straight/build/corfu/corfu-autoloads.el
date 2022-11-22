;;; corfu-autoloads.el --- automatically extracted autoloads
;;
;;; Code:


;;;### (autoloads nil "corfu" "corfu.el" (0 0 0 0))
;;; Generated autoloads from corfu.el

(autoload 'corfu-mode "corfu" "\
Completion Overlay Region FUnction.

\(fn &optional ARG)" t nil)

(defvar global-corfu-mode nil "\
Non-nil if Global Corfu mode is enabled.
See the `global-corfu-mode' command
for a description of this minor mode.
Setting this variable directly does not take effect;
either customize it (see the info node `Easy Customization')
or call the function `global-corfu-mode'.")

(custom-autoload 'global-corfu-mode "corfu" nil)

(autoload 'global-corfu-mode "corfu" "\
Toggle Corfu mode in all buffers.
With prefix ARG, enable Global Corfu mode if ARG is positive;
otherwise, disable it.  If called from Lisp, enable the mode if
ARG is omitted or nil.

Corfu mode is enabled in all buffers where
`corfu--on' would do it.
See `corfu-mode' for more information on Corfu mode.

\(fn &optional ARG)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "corfu" '("corfu-")))

;;;***

(provide 'corfu-autoloads)
;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; corfu-autoloads.el ends here
