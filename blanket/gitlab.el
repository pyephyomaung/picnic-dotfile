(defvar blanket/gitlab-root "https://gitlab.picnichealth.com")
(defvar blanket/gitlab-gql-endpoint (concat blanket/gitlab-root "/api/graphql"))
(defvar blanket/gitlab-gql-token (getenv "GITLAB_TOKEN"))
(defvar blanket/gitlab-username (getenv "GITLAB_USERNAME"))
(defvar blanket/gitlab-default-project-fullpath "team/picnic")

(defvar blanket/gitlab-issue-query "
query GetIssues($project: ID!, $assignee: String!) {
  project(fullPath: $project) {
    name,
  	issues (assigneeUsername: $assignee, state: opened, sort: created_asc) {
      nodes {
        iid,
        title,
        state,
        dueDate,
        webUrl,
        description,
        milestone {
          id,
          title
        },
        labels {
          edges {
            node {
              id,
              title
            }
          }
        },
        createdAt,
        updatedAt
      }
    }
  }
}
")

(defun blanket/gitlab-gql-request (query &optional variables)
  ;; Query Gitlab api
  ;; Test:
  ;; (with-current-buffer (switch-to-buffer "output")
  ;;   (insert
  ;;     (json-encode
  ;;       (blanket/gitlab-gql-request
  ;;           blanket/gitlab-issue-query
  ;;           (list
  ;;             (cons "project" blanket/gitlab-default-project-fullpath)
  ;;             (cons "assignee" blanket/gitlab-username)))))
  ;;     (json-pretty-print-buffer))
  (let* ((url-request-method "POST")
          (url-request-extra-headers
            (list
              (cons "Content-Type" "application/json")
              (cons "Authorization" (format "Bearer %s" blanket/gitlab-gql-token))))
          (url-request-data
            (json-encode
              (list
                (cons "query" query)
                (cons "variables" (and variables (json-encode variables))))))
          (buffer (url-retrieve-synchronously blanket/gitlab-gql-endpoint)))
    (with-current-buffer buffer
      (goto-char url-http-end-of-headers)
      (let ((json-object-type 'hash-table))
        (json-read)))))

(defun blanket/gitlab-fetch-issues ()
  "Return list of issues"
  (let*
    ((response
       (blanket/gitlab-gql-request
         blanket/gitlab-issue-query
         (list
           (cons "project" blanket/gitlab-default-project-fullpath)
           (cons "assignee" blanket/gitlab-username))))
      (data (gethash "data" response))
      (project (gethash "project" data))
      (issues (gethash "nodes" (gethash "issues" project))))
    ;; issues is a vector so convert to list and return
    (cl-map 'list 'identity issues)))

(defun blanket/gitlab-issue-label-titles (issue)
  "Return ISSUE.labels.title"
  (cl-map
    'list
    (lambda (edge) (gethash "title" (gethash "node" edge)))
    (gethash "edges" (gethash "labels" issue))))

(defun blanket/gitlab-issue-priority (issue)
  "Parse priority from ISSUE.labels.title"
  (let ((label-titles (blanket/gitlab-issue-label-titles issue)))
    (cond
    ((seq-some (lambda (x) (string-prefix-p "P0" x)) label-titles) "[#A] ")
    ((seq-some (lambda (x) (string-prefix-p "P1" x)) label-titles) "[#A] ")
    ((seq-some (lambda (x) (string-prefix-p "P3" x)) label-titles) "[#C] ")
    (t "[#B] "))))

(defun blanket/gitlab-issue-to-org-element (issue)
  (let*
    ((id (gethash "iid" issue))
      (title (gethash "title" issue))
      (state (gethash "state" issue))
      (link (gethash "webUrl" issue))
      (description (gethash "description" issue))
      (label-titles (blanket/gitlab-issue-label-titles issue))
      (is-paused (seq-some (lambda (x) (string-prefix-p "Paused" x)) label-titles))
      (priority (blanket/gitlab-issue-priority issue)))
    (list
      'headline
      (list
        :level 2
        :title (format "%s[[%s][#%s]] %s" priority link id title)
        :todo-keyword "TODO"
        :tags (cond (is-paused (list "paused")) (t (list))))
      ;; (list 'property-drawer)
      (list
        'section
        (list
          'src-block
          (list
            :language "markdown"
            :value description))))))

(defun blanket/gitlab-checkout-branch ()
  (interactive)
  (let ((element (org-element-at-point)))
    (print element)))

(defun blanket/gitlab-issue-to-org-document ()
  "Generate org elements as strin for Gitlab issues."
  (let*
    (
      (issues (blanket/gitlab-fetch-issues))
      (milestone-to-issues
        (sort
          (seq-group-by
            (lambda (issue)
              (let ((milestone (gethash "milestone" issue)))
                (cond ((null milestone) "Backlog") (t (gethash "title" milestone)))
              )
            )
            issues
          )
          (lambda (pair1 pair2) (string> (car pair1) (car pair2)))
        )
      )
    )
    (org-element-interpret-data
      (append
        (list
          '(keyword (:key "TITLE" :value "Gitlab issues"))
          '(keyword (:key "STARTUP" :value "content")))
        (mapcar
          (lambda (pair)
            (let
              ((milestone (car pair))
                (issues
                  (sort
                    (cdr pair)
                    (lambda (issue1 issue2)
                      (string<
                        (blanket/gitlab-issue-priority issue1)
                        (blanket/gitlab-issue-priority issue2))))))
              (list
                'headline
                (list :level 1 :title milestone)
                (mapcar 'blanket/gitlab-issue-to-org-element issues))
            ))
          milestone-to-issues)
        ))
    )
  )



(defun blanket/gitlab-show-issues ()
  "Show Gitlab issues"
  (interactive)
  (with-current-buffer (switch-to-buffer "blanket/gitlab")
    (erase-buffer)
    (insert (blanket/gitlab-issue-to-org-document))
    (org-mode)))
