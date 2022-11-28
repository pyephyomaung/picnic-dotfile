;;; wgrep-ag-autoloads.el --- automatically extracted autoloads  -*- lexical-binding: t -*-
;;
;;; Code:


;;;### (autoloads nil "wgrep-ag" "wgrep-ag.el" (0 0 0 0))
;;; Generated autoloads from wgrep-ag.el

(autoload 'wgrep-ag-setup "wgrep-ag" nil nil nil)

(add-hook 'ag-mode-hook 'wgrep-ag-setup)

(register-definition-prefixes "wgrep-ag" '("wgrep-ag-"))

;;;***

(provide 'wgrep-ag-autoloads)
;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; wgrep-ag-autoloads.el ends here
