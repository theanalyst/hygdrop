(import requests)

(defun get-github-issue [connection target issue
			 &optional [project "hylang"] [repo "hy"]
			 [dry-run False]]
  (let [[api-url (.format "https://api.github.com/repos/{}/{}/issues/{}"
			  project repo issue)]
	[api-result (.get requests api-url)]
	[api-json (.json api-result)]]
    (if (= (getattr api-result "status_code") 200)
      (let [[title (get api-json "title")]
	    [status (get api-json "state")]
	    [issue-url (get api-json "html_url")]
	    [get-name (fn [x] (get x "name"))]
	    [labels (.join "|" (map get-name (get api-json "labels")))]
	    [author (get (get api-json "user") "login")]
	    [message (list)]]
	(if (get (get api-json "pull_request") "html_url")
	  (.extend message [(+ "Pull Request #" issue)])
	  (.extend message [(+ "Issue #" issue)]))
	(.extend message ["on" (+ project "/" repo)
			       "by" (+ author ":") title
			       (+ "(" status ")")])
	(if labels
	  (setv please-hy-don-t-return-when-i
		(.append message (+ "[" labels "]"))))
	(.append message (+ "<" issue-url ">"))
	(if dry-run
	  (.join " " message)
	  (.notice connection target (.join " " message)))))))

(defun get-github-commit [connection target commit
			  &optional [project "hylang"] [repo "hy"]
			  [dry-run False]]
  (let [[api-url (.format "https://api.github.com/repos/{}/{}/commits/{}"
			  project repo commit)]
	[api-result (.get requests api-url)]
	[api-json (.json api-result)]]
    (if (= (getattr api-result "status_code") 200)
      (let [[commit-json (get api-json "commit")]
	    
	    [title (get (.splitlines (get commit-json "message")) 0)]
	    [author (get (get commit-json "author") "name")]
	    [commit-url (get api-json "html_url")]
	    [shasum (get api-json "sha")]
	    [message ["Commit" (slice shasum 0 7) "on"
			       (+ project "/" repo)
			       "by" (+ author ":") title
			       (+ "<" commit-url ">")]]]
	(if dry-run
	  (.join " " message)
	  (.notice connection target (.join " " message)))))))
