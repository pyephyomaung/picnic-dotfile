(require 'transient)
(require 'json)

(defvar blanket/default-picnic-directory "~/Repositories/picnic")
(defvar blanket/shell-buffer-name "blanket/shell")
(defvar blanket/shell-banner-message
  "\n.______    __    ______ .__   __.  __    ______\n|   _  \\  |  |  /      ||  \\ |  | |  |  /      |\n|  |_)  | |  | |  ,----'|   \\|  | |  | |  ,----'\n|   ___/  |  | |  |     |  . `  | |  | |  |\n|  |      |  | |  `----.|  |\\   | |  | |  `----.\n| _|      |__|  \\______||__| \\__| |__|  \\______|\n\n"

  "Picnic banner. Tip: use string-edit")

(defun blanket/create-or-pop-to-buffer (name)
  "Create or find existing buffer by matching NAME."
  (unless (get-buffer name)
    (get-buffer-create name))
  (pop-to-buffer name))

(defun blanket/upsert-eshell-buffer (buffer-name)
  "Initialize eshell buffer."
  (let ((eshell-buffer-exists (member buffer-name
                                (mapcar (lambda (buf) (buffer-name buf))
                                  (buffer-list))))
        (eshell-banner-message blanket/shell-banner-message))
    (if eshell-buffer-exists
      (pop-to-buffer buffer-name)
      (progn
        (eshell 99)
        (rename-buffer buffer-name)))))

(defun blanket/repo-root ()
  "Get picnic project root directory"
  (let ((current-root (vc-call-backend 'git 'root default-directory)))
    (cond
      ((string-match "picnic" current-root) current-root)
      (t blanket/default-picnic-directory))))

(defun blanket/api-key-header (api-key)
  (format
    "Basic %s"
    (base64-encode-string (format "%s:" api-key))))

(cond ((string-match "picnic" "~/Repositiories/picnic") "yes") (t "no"))

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Development commands ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun blanket/make (command &optional args)
  (interactive)
  (let
    ((blanket/shell-buffer-name "blanket/shipping"))
    (setenv "EDITOR" "emacs -Q")
    (blanket/dev-run-in-terminal
      (blanket/repo-root)
      (format "make %s" command))))

(defun blanket/fix-lint-diff ()
  (interactive)
  (blanket/dev-run-in-terminal
    (blanket/repo-root)
    "make lint-fix-js-changed && make lint-fix-py-changed"))

(defun blanket/basket-snapshot ()
  (interactive)
  (blanket/dev-run-in-terminal
    (blanket/repo-root)
    "yarn --cwd \"packages/basket\" run test:frontend:snapshots"))

(defun blanket/dev-select-migration-file ()
  (interactive)
  (file-name-nondirectory
    (read-file-name "Select migration: "
      (buffer-file-name))))

(defun blanket/dev-run-in-terminal (working-directory command)
  (interactive)
  (let ((buffer-name blanket/shell-buffer-name))
    (blanket/upsert-eshell-buffer buffer-name)
    (with-current-buffer buffer-name
      (eshell/cd working-directory)
      (eshell-return-to-prompt)
      (insert command)
      ;; (eshell-send-input)
      )))


(defun blanket/dev-run-in-app (env working-directory command)
  (interactive)
  (let ((app-container (string-trim-right (shell-command-to-string "docker compose ps app -q"))))
    (cond
      ((> (length app-container) 0)
        (blanket/dev-run-in-terminal
          (blanket/repo-root)
          (concat
            "docker compose exec -it app"
            (format " sh -c 'cd %s && %s'" working-directory command))))
      (t
        (blanket/dev-run-in-terminal
          (blanket/repo-root)
          (concat
            "docker run --rm"
            (format " --env-file %sinfra/local/secrets/local.env" (blanket/repo-root))
            (format " --env NODE_ENV=%s" env)
            " --env USER"
            " --env DEV_LOCAL_IP=host.docker.internal"
            (format " -v %s:/picnic" (blanket/repo-root))
            " -v /picnic/node_modules"
            " -v /picnic/packages/app/node_modules"
            " -v /picnic/packages/libs/node_modules"
            " -v /picnic/packages/mission-design/node_modules"
            " -v /picnic/packages/models/node_modules"
            " picnic_app"
            (format " sh -c 'cd %s && %s'" working-directory command)))))))

(defun blanket/dev-exec-to-app ()
  (interactive)
  (blanket/dev-run-in-terminal
    default-directory
    "docker compose exec -it bash"))

;;;;;;;;;;;;;;;
;; Migration ;;
;;;;;;;;;;;;;;;

(defun blanket/dev-migration-create ()
  (interactive)
  (let ((name (read-string "Migration name (use kebab-case): ")))
    (blanket/dev-run-in-app
      "development"
      "/picnic/packages/models"
      (format "bin/sequelize migration:create --name %s" name))))

(defun blanket/dev-migration-up ()
  "Run migration."
  (interactive)
  (blanket/dev-run-in-app "development" "/picnic/packages/models" "bin/sequelize db:migrate"))

(defun blanket/dev-migration-down ()
  "Undo database migration on dev env."
  (interactive)
  (let ((migration-name (blanket/dev-select-migration-file)))
    (blanket/dev-run-in-app
      "development"
      "/picnic/packages/models"
      (format "bin/sequelize db:migrate:undo --name %s" migration-name))))

;;;;;;;;;;;;;
;; Testing ;;
;;;;;;;;;;;;;

(defun blanket/dev-test-app (&optional module)
  "Test app."
  (interactive)
  (let* ((blanket-root (blanket/repo-root))
         (test-file (replace-regexp-in-string
                      ".*\/packages"
                      "packages"
                      (read-file-name "Select test file: " (buffer-file-name))))
          (env "test"))
    (blanket/dev-run-in-app
      env
      "/picnic"
      (cond
        ((string-equal module "frontend")
          (format "yarn --cwd \"packages/app\" run test:frontend %s" test-file))
        ((string-equal module "models")
          (format "make test-js-models TEST_FILES=%s NODE_ENV=%s" test-file env))
        (t
          (format "make test-js-app TEST_FILES=%s NODE_ENV=%s" test-file env))))))

(defun blanket/dev-test-models ()
  (interactive)
  (blanket/dev-test-app "models"))

(defun blanket/dev-test-app-frontend ()
  (interactive)
  (blanket/dev-test-app "frontend"))

(defun blanket/dev-test-python-module (module)
  "Test a python module"
  (interactive)
  (blanket/dev-run-in-terminal
    (concat (blanket/repo-root) (format "python/picnic/%s" module))
    (format "../../bin/docker-test %s picnichealth/%s mount " module (string-inflection-kebab-case-function module))))

(defun blanket/dev-test-python-models ()
  (interactive)
  (blanket/dev-test-python-module "db_models"))

(defun blanket/dev-test-python-dicom ()
  (interactive)
  (blanket/dev-test-python-module "dicom"))

(defun blanket/dev-test-python-export-dataset ()
  (interactive)
  (blanket/dev-test-python-module "export_dataset"))

(defun blanket/dev-test-python-edata ()
  (interactive)
  (blanket/dev-test-python-module "edata"))

(defun blanket/dev-test-python-labelling ()
  (interactive)
  (blanket/dev-test-python-module "labelling"))

(defun blanket/dev-test-python-trialing ()
  (interactive)
  (blanket/dev-test-python-module "trialing"))

(defun blanket/dev-test-python-visor ()
  (interactive)
  (blanket/dev-test-python-module "visor"))

(defun blanket/dev-test-python-ui-action-logger ()
  (interactive)
  (blanket/dev-run-in-terminal
    (concat (blanket/repo-root) "python/picnic/ui_action_logger")
    (concat
      "docker run --rm"
      (format " --env-file %sinfra/local/secrets/local.env" (blanket/repo-root))
      " --env PYTHON_ENV=test"
      " --env VERBOSE=0"
      " --env USER"
      (format " -v %s/python/picnic/db_models:/picnic/db_models" (blanket/repo-root))
      (format " -v %s/python/picnic/ui_action_logger:/picnic/ui_action_logger" (blanket/repo-root))
        " picnichealth/ui-action-logger/test"
        " sh -c 'pytest -q /picnic/'")))

(defun blanket/dev-test-export-dataset-tools ()
  "Test export-dataset-tools."
  (interactive)
  (let ((blanket-root (blanket/repo-root)))
    (blanket/dev-run-in-terminal
      (blanket/repo-root)
      (concat
        "docker run --rm"
        (format " --env-file %sinfra/local/secrets/local.env" blanket-root)
        " --env PYTHON_ENV=test"
        (format " -v %spython/picnic/export_dataset:/picnic/export_dataset" blanket-root)
        (format " -v %spython/picnic/config:/picnic/config" blanket-root)
        (format " -v %spython/picnic/enums:/picnic/enums" blanket-root)
        (format " -v %spython/picnic/db_models:/picnic/db_models" blanket-root)
        (format " -v %spython/picnic/utils:/picnic/utils" blanket-root)
        (format " -v %spython/picnic/jobs:/picnic/jobs" blanket-root)
        (format " -v %spackages/export-dataset-tools:/picnic/export_dataset_tools" blanket-root)
        (format " -v %spackages/libs:/picnic/libs" blanket-root)
        " -v /picnic/export_dataset_tools/node_modules"
        " -v /picnic/libs/node_modules"
        " picnichealth/export-dataset"
        " sh -c 'cd /picnic/export_dataset_tools && make test'"))))

;;;;;;;;;;;;;;
;; Snippets ;;
;;;;;;;;;;;;;;
(when (require 'yasnippet nil 'noerror)
  (setq yankpad-file
    (expand-file-name
      "yankpad/yankpad.org" (file-name-directory (or load-file-name buffer-file-name)))))

(defun blanket/find-yankpad-file ()
  (interactive)
  (read-file-name "Select snippets file: " (expand-file-name
        "yankpad" (file-name-directory (or load-file-name buffer-file-name)))))

(transient-define-prefix blanket/snippets ()
  "Snippets"
  [
    ("u" "Insert" yankpad-insert)
    ("e" "Edit snippets" blanket/find-yankpad-file)
  ])


(defun blanket/read-logs-by-change-set-id ()
  "Read Stackdriver logs by changeSetId"
  (interactive)
  (setq-local shell-command-switch "-ic")
  (let*
    (
      (json-object-type 'hash-table)
      (json-array-type 'list)
      (json-key-type 'string)
      (change-set-id (read-string "changeSetId: "))
      (query (format "logName=projects/prod-176122/logs/picnic-app-general-log labels.changeSetId=%s" change-set-id))
      (logs
        (json-read-from-string
          (shell-command-to-string
            (format "gcloud logging read '%s' --limit 20 --format json --project prod-176122" query)
          )
        )
      )
      (log-buffer-name "*logs*")
    )
    (blanket/create-or-pop-to-buffer log-buffer-name)
    (with-current-buffer log-buffer-name
      (erase-buffer)
      (font-lock-mode)
      (insert (propertize query 'font-lock-face '(:background "steel blue" :foreground "white")))
      (insert "\n\n\n")
      (dolist (log logs)
        (let*
          (
            (json-payload (gethash "jsonPayload" log))
            (timestamp
              (format-time-string
                "%m/%d/%y %H:%M:%S"
                (parse-iso8601-time-string (gethash "timestamp" log))))
            (message (gethash "message" json-payload))
          )
          (insert
            (format
              "%s %s\n"
              (propertize timestamp 'font-lock-face '(:background "white" :foreground "black"))
              message
            )
          )
        )
      )
    )
  )
)

(transient-define-prefix blanket/logs ()
  "Logs"
  [
    ("c" "By change set id" blanket/read-logs-by-change-set-id)
  ]
)

;;;;;;;;;;;;;;;
;; Main menu ;;
;;;;;;;;;;;;;;;

(transient-define-prefix blanket ()
  [
    "Picnista Fiesta! glhf!\n"
    [
      "Crafting"
      ("s" "Snippets" blanket/snippets)
      ("d" "Fix Lint diff" blanket/fix-lint-diff)
      ("b" "Basket snapshots" blanket/basket-snapshot)
      ("l" "Logs" blanket/logs)
    ]
    [
      "Migration"
      ("m c" "Create" blanket/dev-migration-create)
      ("m r" "Run" blanket/dev-migration-up)
      ("m u" "Undo" blanket/dev-migration-down)
    ]
    [
      "Testing javascript"
      ("t a" "app" blanket/dev-test-app)
      ("t m" "models" blanket/dev-test-models)
      ("t f" "app/frontend" blanket/dev-test-app-frontend)
      ("t x" "export-dataset-tools" blanket/dev-test-export-dataset-tools)
    ]
    [
      "Testing python"
      ("t o" "models" blanket/dev-test-python-models)
      ("t d" "dicom" blanket/dev-test-python-dicom)
      ("t x" "export-dataset" blanket/dev-test-python-export-dataset)
      ("t e" "edata" blanket/dev-test-python-edata)
      ("t l" "labelling" blanket/dev-test-python-labelling)
      ("t t" "trialing" blanket/dev-test-python-trialing)
      ("t u" "ui-action-logger" blanket/dev-test-python-ui-action-logger)
      ("t v" "visor" blanket/dev-test-python-visor)
    ]
  ]
)


(provide 'blanket)
;;; blanket.el ends here
