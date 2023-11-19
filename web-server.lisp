;;;; See the LICENSE file for licensing information.

(in-package :lisppaste)

;; (define-handler-hierarchy (:application lisppaste-application)
;;     (*paste-external-url*
;;      ("request-deletion" (request-deletion-handler lisppaste-basic-behavior) :inexact t)
;;      ("mark-as-spam" (mark-as-spam-handler lisppaste-basic-behavior) :inexact t)
;;      ("mark-as-wrong-channel" (mark-as-wrong-channel-handler lisppaste-basic-behavior) :inexact t)
;;      ("administration" (administration-handler lisppaste-basic-behavior admin-mixin))
;;      ("administration/"
;;       ("login" (login-handler lisppaste-basic-behavior))
;;       ("logout" (logout-handler lisppaste-basic-behavior))
;;       ("kill-paste" (kill-paste-handler lisppaste-basic-behavior admin-mixin))
;;       ("spam-review" (spam-review-handler lisppaste-basic-behavior admin-mixin))
;;       ("spam-review-required" (spam-review-required-handler lisppaste-basic-behavior)))))

(defvar *referer-hash* (make-hash-table :test #'equalp))

(defvar *referer-example-hash* (make-hash-table :test #'equalp))

(defun times-file-for-class (class)
  (merge-pathnames (format nil "times-~(~A~)"
                           (symbol-name (class-name (class-of class))))
                   *times-file-root*))

(defun referer-list ()
  (loop for link being the hash-values of *referer-example-hash* using (hash-key host)
        collect (cons host link)))

(defun fix-referers ()
  (loop for count being the hash-values of *referer-hash* using (hash-key host)
        do (let ((split-host (split-sequence:split-sequence #\. host)))
             (when (or
                    (and (eql (length split-host) 3)
                         (string-equal (first split-host) "www")
                         (string-equal (second split-host) "google"))
                    (and (eql (length split-host) 4)
                         (string-equal (first split-host) "www")
                         (string-equal (second split-host) "google")
                         (or
                          (string-equal (third split-host) "co")
                          (string-equal (third split-host) "com"))
                         (eql (length (fourth split-host)) 2)))
               (remhash host *referer-hash*)
               (incf (gethash "Google" *referer-hash* 0) count)))))

(defvar *show-captcha* t)

;; (defmethod handle-request-response :around ((handler lisppaste-basic-behavior) method request)
;;   (with-open-file (*trace-output* (times-file-for-class handler)
;;                                   :direction :output
;;                                   :if-exists :append :if-does-not-exist :create)
;;     (expire-authorization-tokens)
;;     (unwind-protect
;;          (call-unless-banned
;;           request
;;           (lambda ()
;;             (let ((*show-captcha* (not (is-authorized request))))
;;               (call-next-method)))
;;           nil)
;;       (force-output *trace-output*))))

(defun make-css ()
  (let ((colorize:*css-background-class* "paste"))
    (format nil "body { background: white; color: black; }
a { margin:1px; border-collapse: collapse; }
a:link { color:#335570; text-decoration: none; background-color: transparent;}
a:visited { color:#705533; text-decoration: none; background-color: transparent;}
a:hover { color:#000000; text-decoration: none; background-color: #BBCCEE; border: 1px solid #335577; margin: 0px;}
a:active { color:#000000; text-decoration: none; background-color: #CCBBFF; border: 1px solid #335577; margin: 0px;}
.simple-paste-list { background-color : #E9FFE9 ; border: 2px solid #9D9; padding : 4px; font-size: small; }
.simple-paste-list td { border-bottom: 1px dotted #9D9; font-size: small; }
table.detailed-paste-list { border-collapse: collapse; border : 1px solid #AAA ; }
table.detailed-paste-list td { border : 1px dotted #AAA; }
table.info-table { border-collapse: collapse; border : 1px solid #AAA ; background-color: #F9E9F9; empty-cells: hide; }
table.info-table td { border : 1px dotted #AAA; background-color: transparent; padding-left: 2em; padding-right: 2em; }
table.info-table th { border : 1px dotted #AAA; background-color: transparent; text-align: left; padding-right: 1em; }
table.rate-table { border-collapse: collapse; border : 1px solid #AAA ; background-color: #F9E9F9; empty-cells: hide; }
table.rate-table td { border : 1px dotted #AAA; background-color: transparent; padding: 2pt; }
table.rate-table th { border : 1px dotted #AAA; background-color: transparent; text-align: left; padding: 1pt; }
.new-paste-form { background-color : #FFE9E9 ; border: 2px solid #D99; padding : 4px; }
.paste-header { background-color : #E9F9F9 ; border: 2px solid #9DD; padding : 4px; margin-bottom : 4px; }
.info-text { background-color : #E9F9F9 ; border: 2px solid #9DD; padding : 4px; margin-top : 4px; text-align: justify; }
div.ads-text { background-color : #F9E9F9 ; border: 2px solid #D9D; padding : 4px; margin-top : 4px; text-align: justify; font-size: small; display: table; padding-right: 1em; }
div.ads-text ul { margin-top: 0; margin-bottom: 0; padding-top: 0; padding-bottom: 0; }
div.ads-text li { padding-bottom: 1ex; }
.ohloh a:link { margin: 0px; border-collapse: collapse; border: 0; }
.ohloh a:active { margin: 0px; border-collapse: collapse; border: 0; }
.ohloh a:visited { margin: 0px; border-collapse: collapse; border: 0; }
.ohloh a:hover { margin: 0px; border-collapse: collapse; border: 0; }
.controls { background-color : #E9E9FF ; border: 2px solid #99D; padding : 4px; display: inline-block; }
.small-header { font-weight: bold; font-size: large; }
.top-header { text-align : center; font-style: italic; font-weight: bold; font-size: x-large; }
.top-link { background-color : #E9F9F9 ; border: 2px solid #9DD; padding: 4px; font-weight: bold; font-size: large; display: table; margin-bottom: 1em; margin-left: auto; margin-right: auto; }
.big-warning { text-align : center; font-weight: bold; font-size: x-large; }
pre.paste-area {
    white-space: pre-wrap; /* css-3 */
    white-space: -moz-pre-wrap !important; /* Mozilla, since 1999 */
    white-space: -pre-wrap; /* Opera 4-6 */
    white-space: -o-pre-wrap; /* Opera 7 */
    word-wrap: break-word; /* Internet Explorer 5.5+ */
    background-color : #F4F4F4 ; border : 2px solid #AAA ; padding : 4px;
}
.bottom-links { background-color : #F9F9E9; border: 2px solid #DD9; padding : 4px; margin-bottom : 4px;}
#main-link { text-align : left; font-weight: bold; }
#other-links { text-align : right; }
hr { border: 1px solid #999; }
@media screen {
div.altdiv { display: none; }
}
table.webutils-form { background-color : #E9E9FF ; border: 2px solid #99D; padding : 4px; }
table.webutils-form th { text-align: left; }
~A~&~A~&"
            (colorize:make-background-css "#F4F4F4")
            colorize:*coloring-css*)))

(define-easy-handler (css :uri *css-url*) ()
  (setf (content-type*) "text/html; charset=utf-8")
  (make-css))


(defun rss-link-header ()
  <link rel="alternate" type="application/rss+xml" title="Lisppaste RSS" href=?*rss-url*/>)

(defparameter *form-accept-translator* (make-translator))

(define-translator *form-accept-translator* mutate-forms
  (:oaoo <form $attributes> . body)
  (<form accept-charset= "utf-8" $attributes> body))

(defun lisppaste-wrap-page (title &rest forms)
  (<html>
   (<head> (<title> title)
           <link type="text/css" rel="stylesheet" href=?*css-url*/>
           (rss-link-header))
   (<body>
    (<div class="top-header"> title)
    <p/>
    (apply-translator *form-accept-translator* forms)
    (bottom-links))))

(defun merge-url (base url)
  (format nil "~a~a" base url))

(defun urlstring-escape (string)
  string)

(defun bottom-links ()
  (list
   <p/>
   (<div class="bottom-links">
         (<table width="100%">
                 (<tr>
                  (<td id="main-link">
                       (<a href=?*paste-external-url*> "Main page"))
                  (<td id="other-links">
                       (<a href=?*new-paste-url*> "New paste")
                       " | "
                       ;; (<a href=?*list-paste-url*> "List all pastes")
                       ;; " | "
                       ;; (<a href=?*syndication-url*> "Syndication")
                       ;; " | "
                       ;; (<a href="http://common-lisp.net/project/lisppaste/xml-rpc.html"> "XML-RPC")
                       (when *serve-source*
                         (list " | "
                               (<a href=?(merge-url *show-component-url* "lisppaste")>
                                   "Source")))
                       " | "
                       (<a href=? *email-redirect-url*> "Requests Email")
                       " | "
                       ;; (<a href= "a";; (urlstring (handler-url 'administration-handler))
                       ;;     > "Administrate")
                       " | "
                       (<a href="http://www.common-lisp.net/project/lisppaste"> "Project home")))))
   (<i> "Lisppaste pastes can be made by anyone at any time. Imagine a fearsomely comprehensive disclaimer of liability. Now fear, comprehensively.")))

;; (defmethod application-wrap-page ((application-handler lisppaste-application) request title body &rest extra-headers)
;;   (apply #'request-send-headers request :expires 0 :content-type "text/html; charset=utf-8" extra-headers)
;;   (xml-output-to-stream (request-stream request)
;;                         (lisppaste-wrap-page title body)))

(defun lisppaste-send-headers-for-html (request &rest other-arguments)
  (apply #'request-send-headers request :expires 0 :content-type "text/html; charset=utf-8" other-arguments))

(defun recent-paste-list-div (&key (count 10))
  ;; (<div class="simple-paste-list">
  ;;       (<table>
  ;;        (loop for j in (list-pastes :limit count)
  ;;             collect (<tr>
  ;;                      (<td valign="center"> (<a href=?(paste-display-url j)>
  ;;                                                (paste-title j)))
  ;;                      (<td valign="bottom"> " by " (paste-user j))
  ;;                      (<td valign="bottom"> (paste-channel j))))
  ;;        (<tr> (<td colspan="3">
  ;;                   (<center> (<b> (<a href=?*list-paste-url*>
  ;;                                      "More recent pastes...")))))))
  )

(defun xml-to-string (xml)
  (with-output-to-string (stream)
    (xml-output-to-stream stream xml)))

(define-easy-handler (main :uri "/") ()
  (xml-to-string
   (lisppaste-wrap-page
    (format nil "~A pastebin" *paste-site-name*)
    (<table width="100%" border="0" cellpadding="2">
            (<tr> (<td> ;; (<div class="small-header"> "Recent Pastes")
                        )
                  (<td align="right"> (<div class="small-header"> "Make a new paste")))
            (<tr> (<td valign="top" width="40%">
                       (recent-paste-list-div)
                       <p/>
                       (<div class="small-header"> "About lisppaste")
                       (<div class="info-text">
                             "Lisppaste is a pastebot / pastebin / nopaste service with syntax highlighting, XML-RPC support, annotations, and more."
                             <p/>
                             "Many times when working via IRC, people
want to share a snippet of code with somebody else. However, just
pasting the code into IRC creates a flood of text which is hard to
read and scrolls by as discussion progresses."
                             <p/>
                             "Thus, the pastebot was invented, which
has a web form where users can paste code, and the URL of the paste is
announced on the desired channel. Lisppaste is an advanced pastebot
running on the IRC server "
                             *irc-network-name*
                             " which has many unique features."
                             (when *no-channel-pastes*
                               (list
                                <p/>
                                "It also allows pastes which are not
announced on any channel, which is useful for sections of code which
need to be sent to a mailing list or are discussed in ways other than
IRC."
                                <p/>
                                "Lisppaste is graciously hosted by "
                                (<b> (<a href="http://www.common-lisp.net/"> "common-lisp.net"))
                                " - a hosting service for projects written in Common Lisp (like this one)."
                                <p/>
                                "Questions? Comments? Want lisppaste in your channel? "
                                (<a href=?*email-redirect-url*> "Email me")
                                "."))))
                  (<td valign="top" align="right">
                       (<form method="post" action=? *submit-paste-url*>
                              (generate-new-paste-form :width 60 :default-user (get-default-user)))
                       <p/>))))))

(defun ban-log (user request)
  (log-event
   (format nil "Blocked attempt by ~S, IP ~S, (referred by ~S) to submit a paste.~%Request headers are: ~S.~%Request body is: ~S.~%"
           user
           (car (request-header request :x-forwarded-for))
           (car (request-header request :referer))
           (request-headers request)
           (request-body request))
   :log-file *ban-log-file*))

(defun ban-ip/request (request)
  (let ((forwarded-for (car (request-header request :x-forwarded-for))))
    (when forwarded-for
      (ban-ip forwarded-for))))

(defun call-unless-banned (request thunk is-pasting)
  (let ((forwarded-for (car (request-header request :x-forwarded-for))))
    (if (and forwarded-for
             (not (paste-allowed-from-ip-p forwarded-for is-pasting)))
        (progn
          (ban-log forwarded-for request)

          (xml-output-to-stream
           (request-stream request)
           (<html> (<head> (<title> "No cookie for you!"))
                   (<body> (<h1> (<font color="red"> "Naughty boy!"))))))
        (funcall thunk))))

(defun quick-parse-junk-integer (string &key (start 0) (limit 64) (radix 10))
  (if (> (length string) start)
      (let ((end start))
        (loop while (and (< end (length string))
                         (plusp limit)
                         (digit-char-p (elt string end) radix))
              do (incf end)
              (decf limit))
        (if (> end start)
            (parse-integer string :start start :end end :radix radix)))))

(defun parse-new-paste-channel ()
  (ppcre:register-groups-bind (channel)
      (#.(format nil "^~a/(\.+)" *new-paste-url*) (script-name*))
    (format nil "#~a" channel)))

(define-easy-handler (new-paste :uri (match-prefix *new-paste-url*))
    (annotate channel)
  (xml-to-string
   (lisppaste-wrap-page
    "Submit"
    (<table>
     (<th> "Due to continued abuse, this service has been discontinued")))))
;;  (let* ((annotate-number (if annotate (quick-parse-junk-integer annotate)))
;;         (annotate-paste (if annotate-number (find-paste annotate-number)))
;;         (default-channel
;;           (or (and annotate-paste (paste-channel annotate-paste))
;;               (if (ends-with (script-name*) "/none")
;;                   "None")
;;               (or channel
;;                   (parse-new-paste-channel))
;;               (and *no-channel-pastes*
;;                    "None"))))
;;    (cond
;;      ((and default-channel (or (and *no-channel-pastes*
;;                                     (string-equal default-channel "None"))
;;                                (find default-channel *channels* :test #'string-equal)))
;;       (new-paste-form :annotate annotate-paste :default-channel default-channel))
;;      (t
;;         (xml-to-string
;;          (lisppaste-wrap-page
;;           "Select a channel"
;;           (<form method="post" action=?*new-paste-url*>
;;                  (<div class="controls">
;;                        <input type="hidden" name="annotate" value=?annotate />
;;                        "Please select a channel to lisppaste to: "
;;                        (<select name="channel">
;;                                 (<option value=""> "")
;;                                 (mapcar (lambda (e)
;;                                           (<option value=?e> e))
;;                                         *channels*))
;;                        <input type="submit" value="Submit"/>))))))))

(defun time-delta (time &key (level 2) (ago-p t) (origin (get-universal-time)) (inverse nil))
  (let ((delta (if inverse
                   (- time origin)
                   (- origin time))))
    (cond
     ((< delta 0) (list "<Doc Brown>From the " (<i> "future") "...</Doc Brown>"))
     ((< delta (* 60 60)) (format nil "~A~A" (time-delta-primitive delta 1) (if ago-p " ago" "")))
     (t (format nil "~A~A" (time-delta-primitive delta level) (if ago-p " ago" ""))))))

(defun irc-log-link (utime channel)
  (format nil "http://ircbrowse.com/cview.html?utime=~A&channel=~A&start=~A&end=~A#utime_requested"
          (- utime 5)
          (string-left-trim "#" channel)
          (- utime (* 60 60))
          (+ utime (* 60 60))))

(defun first-<-mod (n &rest nums)
  (some #'(lambda (n2)
            (if (< n2 n) (mod n n2) nil)) nums))

(defun time-delta-primitive (delta &optional (level 2))
  (let* ((seconds 60)
         (minutes (* seconds 60))
         (hours (* minutes 24))
         (days (* hours 7))
         (weeks (* hours 487/16))
         (months (* weeks 12))
         (years (* hours (+ 365 1/4))))
    (let ((primitive
           (cond
            ((< delta seconds) (format nil "~D second~:P" delta))
            ((< delta minutes) (format nil "~D minute~:P" (floor delta seconds)))
            ((< delta hours) (format nil "~D hour~:P" (floor delta minutes)))
            ((< delta days) (format nil "~D day~:P" (floor delta hours)))
            ((< delta weeks) (format nil "~D week~:P" (floor delta days)))
            ((< delta months) (format nil "~D month~:P" (floor delta weeks)))
            (t (format nil "~D year~:P" (floor delta months))))))
      (if (eql level 1) primitive
        (format nil "~A, ~A" primitive
                (time-delta-primitive
                 (first-<-mod delta years months weeks days hours minutes seconds)
                 (1- level)))))))

(defun max-length (str n)
  (if (> (length str) n)
      (concatenate 'string (subseq str 0 (1- n)) "...")
    str))

(define-easy-handler (syndication :uri *syndication-url*) ()
  ;; (xml-to-string
;;    (lisppaste-wrap-page
;;     "Syndication options"
;;     "Lisppaste can be syndicated in a variety of RSS formats for use
;; with your favorite RSS reader."
;;     <p/>
;;     (<table class="info-table">
;;             (<tr>
;;              (<th align="left"> "All channels")
;;              (<td> (<a href=?*rss-url*> "Basic"))
;;              (<td> (<a href=?*rss-full-url*> "Full")))
;;             (mapcar (lambda (channel)
;;                       (let ((append (if (and *no-channel-pastes*
;;                                              (string-equal channel "None"))
;;                                         "?none"
;;                                         (substitute #\? #\# channel))))
;;                         (<tr>
;;                          (<th align="left"> channel)
;;                          (<td> (<a href=?(concatenate 'string *rss-url* append)>
;;                                    "Basic"))
;;                          (<td> (<a href=?(concatenate 'string *rss-full-url* append)>
;;                                    "Full")))))
;;                     *channels*))))
  )

(defun last-paste-date-for-channel (channel)
  (let ((paste (car (list-pastes :limit 1 :in-channel channel))))
    (if paste
        (time-delta (paste-universal-time paste) :level 1 :ago-p nil)
        "Never")))

(defun channel-paste-url (channel)
  (concatenate 'string
               *new-paste-url*
               "/"
               (urlstring-escape (if (equalp channel "none")
                                     "None"
                                     (subseq channel 1)))))

(defun channel-list-url (channel)
  (concatenate 'string
               *list-paste-url*
               "/"
               (urlstring-escape (if (equalp channel "none")
                                     "None"
                                     (subseq channel 1)))))

(define-easy-handler (channelselect :uri *channel-select-url*) ()
  (xml-to-string
   (lisppaste-wrap-page
    (format nil "~A channel list" *paste-site-name*)
    (<table width="100%" border="0" cellpadding="2">
            (<tr valign="top" align="center">
                 (<td>
                  (<div class="info-text">
                        "Lisppaste is available in "
                        (<b> (prin1-to-string
                              (length (remove "None" *channels* :test #'equal))))
                        (format nil " channels on the IRC network ~A. Select a channel from the list below and bookmark its URL to paste with direct notification to your channel." *irc-network-name*)
                        <p/>
                        "Questions? Comments? Want lisppaste in your channel? "
                        (<a href=?*email-redirect-url*> "Email me")
                        ".")
                  <p/>
                  (<table class="info-table">
                          (<tr>
                           (<th align="left"> "Channel Name")
                           (<th align="left"> "")
                           (<th align="left"> "")
                           (<th align="left"> "Last Paste"))
                          (mapcar (lambda (channel)
                                    (<tr>
                                     (<th align="left">
                                          channel)
                                     (<th align="left">
                                          (<a href=?(channel-paste-url channel)>
                                              "New paste here"))
                                     (<th align="left">
                                          (<a href=?(channel-list-url channel)>
                                              "List"))
                                     (<td align="left">
                                          (last-paste-date-for-channel channel))))
                                  (sort (remove "None" *channels* :test #'string-equal) #'string<)))))))))

(define-easy-handler (stats :uri *stats-url*) ()
  (xml-to-string
   (lisppaste-wrap-page
    "Statistics"
    (<div>
     (<span class="small-header"> "Uptime: ")
     (time-delta *boot-time* :ago-p nil :level 3)))))

(defun page-links-for-paste-list (page highest-page channel)
  (let ((base-url (if channel
                      (merge-url *list-paste-url*
                                  (format nil "/~A"
                                          (if (char= #\# (char channel 0))
                                              (subseq channel 1)
                                              channel)))
                      *list-paste-url*)))
    (flet ((page-url (i)
             (merge-url base-url (format nil "?~A" i))))
      ;; XXX: Must we loop over all pages or is there a better way?
      (loop for i from 0 to highest-page
            for should-collect = (or (zerop i)
                                     (eql i highest-page)
                                     (eql (mod i 100) 99)
                                     (<= (abs (- i page)) 5)
                                     (and (<= (abs (- i page)) 50)
                                          (eql (mod i 10) 9)))
            if (eql (- i page) -5)
            collect "... "
            if should-collect
            collect (if (eql i page)
                        (<b> (prin1-to-string (1+ i)))
                        (<a href=?(page-url i)>
                            (prin1-to-string (1+ i))))
            if (and should-collect (not (eql i highest-page)))
            collect " "
            if (eql (- i page) 5)
            collect "... "))))

(defun parse-list-channel ()
  (ppcre:register-groups-bind (channel)
      (#.(format nil "^~a/(\.+)" *list-paste-url*) (script-name*))
    channel))

(define-easy-handler (list-all-pastes :uri (match-prefix *list-paste-url*)) (channel)
  (redirect (full-url "")))
  ;; (let* ((discriminate-channel (or channel (parse-list-channel)))
  ;;        (discriminate-channel
  ;;          (unless (equalp discriminate-channel "allchannels")
  ;;            discriminate-channel))
  ;;        (page-parameter (single-get-parameter))
  ;;        (page (or (and page-parameter
  ;;                       (parse-integer page-parameter :junk-allowed t))
  ;;                  0))
  ;;        (discriminated-pastes
  ;;          (list-pastes :in-channel (if (equal discriminate-channel "Some")
  ;;                                       t
  ;;                                       discriminate-channel)))
  ;;        (highest-page (floor (/ (- (length discriminated-pastes) 1)
  ;;                                *pastes-per-page*)))
  ;;        (page-links (page-links-for-paste-list page highest-page discriminate-channel)))
    ;; (xml-to-string
    ;;  (lisppaste-wrap-page
    ;;   (if discriminate-channel
    ;;       (format nil "All pastes in channel ~A" discriminate-channel)
    ;;       "All pastes in system")
    ;;   (when (and discriminate-channel
    ;;              (not (member discriminate-channel *channels* :test #'string-equal)))
    ;;     (<div>
    ;;      (<font color="red">
    ;;             (format nil "Lisppaste isn't in the channel ~A." discriminate-channel))))
    ;;   (when discriminate-channel
    ;;     (<div class="top-link">
    ;;           (<a href=?(channel-paste-url discriminate-channel)>
    ;;               "New paste here")))
    ;;   (<center>
    ;;    (<form method="post" action=?*list-paste-url*>
    ;;           (<table class="controls">
    ;;                   (<tr> (<td align="left"> "View only: ")
    ;;                         (<td valign="top" align="center">
    ;;                              (<select name="channel">
    ;;                                       (<option value="allchannels">
    ;;                                                "All channels")
    ;;                                       (mapcar (lambda (e)
    ;;                                                 (<option value=?e $ (if (equal e discriminate-channel) '("selected" "SELECTED"))> e)
    ;;                                                 ) *channels*))
    ;;                              <input type="submit" value="Submit"/>))
    ;;                   (<tr>
    ;;                    (<td align="left">
    ;;                         (if discriminate-channel
    ;;                             "Syndicate this channel: "
    ;;                             "Syndicate all channels: "))
    ;;                    (<td align="center">
    ;;                         (<a href=?(concatenate 'string
    ;;                                                *rss-url*
    ;;                                                (if discriminate-channel
    ;;                                                    (or (and *no-channel-pastes*
    ;;                                                             (string-equal discriminate-channel "none")
    ;;                                                             "?none")
    ;;                                                        (substitute #\? #\# discriminate-channel)) ""))>
    ;;                             "Basic")
    ;;                         " | "
    ;;                         (<a href=?(concatenate 'string
    ;;                                                *rss-full-url*
    ;;                                                (if discriminate-channel
    ;;                                                    (or (and *no-channel-pastes*
    ;;                                                             (string-equal discriminate-channel "none")
    ;;                                                             "?none")
    ;;                                                        (substitute #\? #\# discriminate-channel))
    ;;                                                    ""))>
    ;;                             "Full")))
    ;;                   (<tr>
    ;;                    (<td align="left">
    ;;                         "Page: ")
    ;;                    (<td align="center">
    ;;                         page-links)))))
    ;;   <p/>
    ;;   (<table width="100%" cellpadding="2" class="detailed-paste-list">
    ;;           (<tr>
    ;;            (<td>)
    ;;            (<td> "By")
    ;;            (<td> "Where")
    ;;            (<td> "When")
    ;;            (<td> "Title")
    ;;            (<td> "Ann."))
    ;;           (loop for i from 0 to (- (* (1+ page) *pastes-per-page*) 1)
    ;;                 for paste in discriminated-pastes
    ;;                 if (>= i (* page *pastes-per-page*))
    ;;                 collect
    ;;                 (<tr>
    ;;                  (<td nowrap="nowrap">
    ;;                       (<a href=?(paste-display-url paste)>
    ;;                           (concatenate 'string "#" (prin1-to-string (paste-number paste)))))
    ;;                  (<td nowrap="nowrap">
    ;;                       (max-length (paste-user paste) 12))
    ;;                  (<td nowrap="nowrap"> (paste-channel paste))
    ;;                  (<td nowrap="nowrap"> (time-delta (paste-universal-time paste) :level 1 :ago-p nil))
    ;;                  (<td width="100%" bgcolor="#F6F6F6" nowrap="nowrap">
    ;;                       (max-length (paste-title paste) 50))
    ;;                  (<td nowrap="nowrap"> (length (paste-annotations paste))))))
    ;;   <p/>
    ;;   (<center>
    ;;    (<table class="controls">
    ;;            (<tr> (<td> "Page: " page-links))))))
;;    ))

(defun single-get-parameter ()
  (ppcre:scan-to-strings "(?<=\\?).+$" (request-uri*)))

(defun handle-rss-request (&key full)
  (setf (content-type*) "application/rss+xml")
  (let* ((channel (single-get-parameter)))
    (with-html-output-to-string (*standard-output*)
      (format t "<?xml version=\"1.0\" encoding=\"UTF-8\"?>~C~C" #\Return #\Linefeed)
      (:rss :version "2.0"
            (:channel
             (:title "Lisppaste pastes"
                     (when channel
                       (fmt " for channel ~A" channel)))
             (:link (str *list-paste-url*))
             (:description "Pastes in this pastebot")
             (when channel
               (fmt " on channel ~A" channel))
             (loop for paste in (list-pastes :in-channel channel
                                             :limit 20)
                   do
                   (htm
                    (:item (:link (fmt "http://~a~a" *paste-site-name*
                                       (paste-display-url paste)))
                      (fmt "<pubDate>~A</pubDate>"
                           (date:universal-time-to-rfc-date
                            (apply #'max
                                   (paste-universal-time paste)
                                   (mapcar #'paste-universal-time
                                           (paste-annotations paste)))))
                      (:title (prin1 (encode-for-pre (paste-title paste)))
                              " by "
                              (str (encode-for-pre (paste-user paste))))
                      (:description
                       (if full
                           (str (encode-for-pre
                                 (encode-for-http
                                  (xml-to-string
                                   (<p>
                                    (format-paste paste nil (paste-number paste))
                                    (loop for a in (paste-annotations paste)
                                          collect (format-paste a nil (paste-number a) t)))))))
                           (fmt "Paste to channel ~A with ~A annotations."
                                (encode-for-pre (paste-channel paste))
                                (length (paste-annotations paste)))))))))))))

(define-easy-handler (rss :uri *rss-url*) ()
  ;; (handle-rss-request)
  )

(define-easy-handler (rss-full :uri *rss-full-url*) ()
  ;; (handle-rss-request :full t)
  )

(defun generate-new-paste-form (&key annotate
                                     (default-channel "None")
                                     (default-user "")
                                     (default-title "untitled")
                                     (default-contents "")
                                     (width 80))
  (<table class="new-paste-form">
     (<tr>
        (<th align="center" width="0%" nowrap="nowrap">
             "Due to continued abuse, this service has been disabled"))))

;;  (<table class="new-paste-form">
;;          (unless annotate
;;            (<tr>
;;             (<th align="left" width="0%" nowrap="nowrap">
;;                  "Select a channel:")
;;             (<td> (if (or (equal default-channel "")
;;                           (equal default-channel "None"))
;;                       (list
;;                        (<input type="hidden" name="channel" value="None"> "None ")
;;                        (<a href=?*channel-select-url*> "(Choose)"))
;;                       (list
;;                        (<select name="channel">
;;                                 (<option value=?default-channel selected="selected">
;;                                          default-channel)
;;                                 (when *no-channel-pastes*
;;                                   (<option value="None"> "None")))
;;                        <br/>
;;                        (format nil "To paste to a different IRC channel on the network ~A, select a channel from the " *irc-network-name*)
;;                        (<a href=?*channel-select-url*> "channel list")
;;                        ".")))))
;;          (<tr>
;;           (<th align="left" width="0%" nowrap="nowrap"> "Enter your username:")
;;           (<td> <input type="text" name="username" value=?default-user />))
;;          (<tr>
;;           (<th align="left" width="0%" nowrap="nowrap"> "Enter a title:")
;;           (<td> <input type="text" name="title" value=?default-title onfocus="if (this.value == 'untitled') { this.value = ''; this.onfocus = ''; }" />))
;;          (when *show-captcha*
;;            (<tr>
;;             (<th align="left" width="0%" nowrap="nowrap"> "Captcha:")
;;             (<td>
;;              (let* ((number1 (+ 32 (random 68)))
;;                     (number2 (+ 32 (random 68))))
;;                (multiple-value-bind (captcha captchaid)
;;                   (make-captcha 4 :string (format nil "~4,'0D" (* number1 number2)))
;;                 (list
;;                  (<div style= "display: table-cell;">
;;                        captcha)
;;                  <input type="text" name="captcha" />
;;                  <input type="hidden" name="captchaid" value=?captchaid />))))))
;;          (unless annotate

;;            (list
;;             (<tr>
;;              (<th align="left" width="0%" nowrap="nowrap">
;;                   "Colorize as: ")
;;              (<td> (let ((default (gethash default-channel *coloring-type-defaults*)))
;;                      (<select name="colorize">
;;                               (<option value="None" $(unless default
;;                                                        '("selected" "SELECTED"))> "None")
;;                               (loop for pair in (colorize:coloring-types)
;;                                     collect (<option value=?(cdr pair) $(if (eq (car pair) default)
;;                                                                             '("selected" "SELECTED"))>
;;                                                                             (cdr pair)))))))
;;             (<tr>
;;              (<th align="left" width="0%" nowrap="nowrap">
;;                   "Expires in: ")
;;              (<td> (<select name="expiration">
;;                             (loop for pair in *expiration-options*
;;                                   for first = t then nil
;;                                   collect (<option value=?(car pair) $(if first '("selected" "SELECTED"))>
;;                                                    (car pair))))))))
;;          (<tr>
;;           (<th align="left" valign="top" width="0%" nowrap="nowrap">
;;                "Enter your paste:")
;;           (<td>))
;;          (<tr>
;;           (<td colspan="2">
;;                (<textarea rows="24" cols=?(prin1-to-string width) name="text">
;;                           default-contents)))
;;          (<tr>
;;           (<th align="left" width="0%" nowrap="nowrap"> "Submit your paste:")
;;           (<td> <input type="submit" value="Submit paste" />
;;                 " "
;;                 <input type="reset" value="Clear paste" />))))

(defun get-default-user ()
  (or (cookie-in "USERNAME")
      ""))

(defun new-paste-form (&key (message "") (annotate nil) (default-channel "") default-user (default-title "untitled") (default-contents ""))
  (unless default-user
    (setf default-user (get-default-user)))
  (xml-to-string
   (lisppaste-wrap-page
    (if annotate "Enter your annotation" "Enter your paste")
    (if (not (zerop (length message)))
        (<div class="big-warning"> message)
        "")
    (<form method="post" action=?*submit-paste-url*>
           (<div class="info-text">
                 "Enter a username, title, and paste contents into the fields below. "
                 (unless (and *no-channel-pastes*
                              (or (and annotate (string-equal (paste-channel annotate) "None"))
                                  (string-equal default-channel "none")))
                   (list
                    "The paste will be announced on the selected channel on "
                    *irc-network-name* "."
                    (<p>
                     (<b> "Please do " (<i> "not") " use this form if you are not in this channel. "
                          (when *no-channel-pastes*
                            (<a href=?(channel-paste-url "/none")>
                                "Use this link instead."))))))
                 (when annotate
                   (list
                    "This paste will be used to annotate "
                    (<b>
                     (<a href=?(paste-display-url annotate)>
                         (paste-title annotate) "."))
                    <input type="hidden" name="annotate" value=?(prin1-to-string (paste-number annotate)) />
                    <input type="hidden" name="channel" value=?(paste-channel annotate) />)))
           <p/>
           (generate-new-paste-form :annotate annotate :default-channel default-channel :default-user default-user :default-title default-title :default-contents default-contents)))))

(defvar *used-captcha-hash* (make-hash-table :test #'equal))
(defvar *last-captcha-clear-time* 0)

(defun expire-used-captchas ()
  (let ((now (get-universal-time)))
    (when (> (- now *last-captcha-clear-time*) *used-captcha-release-time*)
      (setf *last-captcha-clear-time* now)
      (maphash (lambda (captchaid time)
                 (when (> (- now time) *used-captcha-release-time*)
                   (remhash captchaid *used-captcha-hash*)))
               *used-captcha-hash*))))

(defun paste-moldy (annotate-paste)
  (> (abs (- (get-universal-time) (paste-universal-time annotate-paste)))
     *annotate-moldy*))

(defun captcha-used (captchaid)
  (prog1 (gethash captchaid *used-captcha-hash*)
    (setf (gethash captchaid *used-captcha-hash*) (get-universal-time))))

(defun trim-to-length (string length)
  (if (> (length string) length)
      (concatenate 'string (subseq string 0 (- length 3)) "...")
      string))

(defun paste-tweet-url (paste)
  (format nil "http://twitter.com/home?status=~A"
          (full-url
           (urlstring-escape (trim-to-length (format nil "~A ~A"
                                                     (paste-short-url paste)
                                                     (paste-title paste))
                                             140)))))

(defun log-new-paste (ip number annotation title)
  (log-event
   (format nil "New paste from IP ~A: number ~A, annotation of ~A, title ~S.~%"
           ip number annotation title)))

(defun check (string)
  (ppcre:scan "http://.+?\\.php\\?" string))

(define-easy-handler (submit-paste :uri *submit-paste-url*)
    (username title text colorize expiration annotate channel captcha captchaid)
  (xml-to-string
    (lisppaste-wrap-page
       "Disabled"
       "Due to continued abuse, this service has been disabled")))

;;  (with-paste-lock
;;    (let* ((annotate-number (if annotate (quick-parse-junk-integer annotate)))
;;           (annotate-paste (if annotate-number (find-paste annotate-number)))
;;           (correct (and captcha captchaid (captcha-entered-correctly-p captcha 4 captchaid))))
;;      (let ((cookies nil))
;;        (when (> (length channel) 1)
;;          (push (format nil "USERNAME=~A; path=/"
;;                        (or username "")) cookies))
;;        ;; (when correct
;;        ;;   (push (make-authorization-token :extra :captcha) cookies))
;;        ;; (if cookies
;;        ;;     (request-send-headers request :expires 0
;;        ;;                        :content-type "text/html; charset=utf-8"
;;        ;;                           :set-cookie cookies)
;;        ;;     )
;;        )
;;      (expire-used-captchas)
;;      (cond
;;        ((or (check text)
;;             (check username)
;;             (check title))
;;         (new-paste-form :message "Bad content"
;;                         :default-channel channel
;;                         :annotate annotate-paste
;;                         :default-user username
;;                         :default-title title
;;                         :default-contents text))
;;        ((and (> (length captchaid) 0) (captcha-used captchaid))
;;         (new-paste-form :message "This captcha has been used already. Did you use the back button?"
;;                         :default-channel channel
;;                         :annotate annotate-paste
;;                         :default-user username
;;                         :default-title title
;;                         :default-contents text))
;;        ((and *show-captcha* (not correct))
;;         (new-paste-form :message "You entered the captcha incorrectly."
;;                         :default-channel channel
;;                         :annotate annotate-paste
;;                         :default-user username
;;                         :default-title title
;;                         :default-contents text))
;;        ((> (length text) *paste-maximum-size*)
;;         (new-paste-form :message "Paste too large."
;;                         :default-channel channel :annotate
;;                         annotate-paste :default-user
;;                         username :default-title title))
;;        ((zerop (length channel))
;;         (new-paste-form :message "Please select a channel."
;;                         :default-channel channel
;;                         :annotate annotate-paste
;;                         :default-user username
;;                         :default-title title
;;                         :default-contents text))
;;        ((zerop (length username))
;;         (new-paste-form :message "Please enter your username."
;;                         :default-channel channel
;;                         :annotate annotate-paste
;;                         :default-user username
;;                         :default-title title
;;                         :default-contents text))
;;        ((zerop (length title))
;;         (new-paste-form :message "Please enter a title."
;;                         :default-channel channel
;;                         :annotate annotate-paste
;;                         :default-user username
;;                         :default-title title
;;                         :default-contents text))
;;        ((zerop (length text))
;;         (new-paste-form :message "Please enter your paste."
;;                         :default-channel channel
;;                        :annotate annotate-paste
;;                         :default-user username
;;                         :default-title title
;;                         :default-contents text))
;;        ((and (not annotate)
;;              (not (assoc expiration *expiration-options* :test #'equal)))
;;         (new-paste-form :message "Please choose a valid expiration option."
;;                         :default-channel channel
;;                         :annotate annotate-paste
;;                         :default-user username
;;                         :default-title title
;;                         :default-contents text))
;;        ((and annotate (not annotate-paste))
;;         (new-paste-form :message "Malformed annotation request."
;;                         :default-channel channel
;;                         :default-user username
;;                         :default-title title
;;                         :default-contents text))
;;        ((and annotate annotate-paste (paste-moldy annotate-paste))
;;         (xml-to-string
;;          (lisppaste-wrap-page
;;           (format nil "Paste ~A too old!" (paste-number annotate-paste))
;;           (format nil "I can't imagine why you'd want to annotate a paste that's ~A old."
;;                   (time-delta (paste-universal-time annotate-paste) :ago-p nil)))))
;;        ((not (member channel *channels* :test #'string-equal))
;;         (new-paste-form :message "Whatever channel that is, I don't know about it."
;;                         :default-channel channel
;;                         :annotate annotate-paste
;;                         :default-user username
;;                         :default-title title
;;                         :default-contents text))
;;        ((or
;;          (some (lambda (regexp)
;;                  (or (cl-ppcre:scan regexp text)
;;                      (cl-ppcre:scan regexp title))) *banned-content-regexps*)
;;          (let ((user-agent (user-agent)))
;;            (when user-agent
;;              (some (lambda (regexp)
;;                      (cl-ppcre:scan regexp user-agent))
;;                    *banned-user-agent-regexps*)))
;;          (member title *banned-paste-titles* :test #'equal)
;;          (member username *banned-paste-users* :test #'equalp))
;;                                        ;(ban-ip/request request)
;;                                        ;(ban-log username request)
;;         (xml-to-string
;;          (lisppaste-wrap-page
;;           "Disallowed!"
;;           (<div class="info-text">
;;                 *paste-site-name*
;;                 " is a public service to the open source software community and is intended for sharing of code, debug output, and other software-related information. It is not a wiki or a forum and it cannot under any circumstances be made to link to any sites. It is also not a service to the torrent scene or to authors of erotic fiction. Please consider using another service such as "
;;                 (<a href= "http://www.pastebin.ca"> "pastebin.ca")
;;                 " for this content."
;;                 <p/>
;;                 "If you feel you have recieved this message in error, please "
;;                 (<a href=?*email-redirect-url*> "contact us")
;;                 " and include the contents of your paste. Thank you."))))
;;        (t
;;         (let* ((expiration-delta (unless annotate
;;                                    (cdr (assoc expiration *expiration-options*
;;                                                :test #'equal))))
;;                (paste (make-new-paste
;;                        annotate-paste
;;                        :user username
;;                        :title title
;;                        :contents text
;;                        :channel channel
;;                        :colorization-mode (coerce colorize 'string)
;;                        :expiration-time (if expiration-delta
;;                                             (+ (get-universal-time)
;;                                                expiration-delta))))
;;                (url (paste-short-url paste))
;;                (paste-number (or annotate-number (paste-number paste)))
;;                (annotation-number (if annotate-paste (paste-number paste))))
;;           (log-new-paste (remote-addr*)
;;                          paste-number
;;                         annotation-number
;;                          title)
;;           (xml-to-string
;;            (lisppaste-wrap-page
;;             (format nil "Paste number ~A pasted!" paste-number)
;;             (<p>
;;              (if annotate
;;                  "Your annotation should be available at "
;;                  "Your paste should be available at ")
;;              (<b> (<a href=?url> (full-url url)))
;;              (unless (and *no-channel-pastes*
;;                           (string-equal channel "none"))
;;                (list ", and was also sent to " channel " at " *irc-network-name*))
;;              ".")
;;             (<p>
;;              (<b> (<a href=? (paste-tweet-url paste)>
;;                       "Tweet this!")))
;;             (<form method="post" action=?*new-paste-url*>
;;                    <input type="hidden" name="annotate" value=?(prin1-to-string paste-number) />
;;                    (<div>
;;                     (<span class="controls">
;;                            (<span class="small-header">
;;                                   "Don't make more pastes; annotate this one!")
;;                            <br/>
;;                            <input type="submit" value="Annotate this paste" />)))))))))))

(defun ends-with (str end)
  (let ((l1 (length str))
        (l2 (length end)))
    (if (< l1 l2) nil
      (string= (subseq str (- l1 l2) l1) end))))

(defparameter *memoize-token* nil)
(defvar *memoize-hash*)

(defun memoize-format (key fn)
  (when (not (eq *memoize-token* colorize:*version-token*))
    (setf *memoize-token* colorize:*version-token*)
    (setf *memoize-hash* (make-hash-table :test #'equal #+sbcl :weakness #+sbcl :value)))
  (multiple-value-bind (val found) (gethash key *memoize-hash*)
    (if found
        val
        (setf (gethash key *memoize-hash*)
              (funcall fn)))))

;; (define-template-form-field hidden-paste-field hidden-form-field
;;   :string-acceptor (lambda (string)
;;                      (unless (and (> (length string) 0)
;;                                   (every #'digit-char-p string))
;;                        (fail-check "Please enter an integer."))
;;                      (unless (find-paste (quick-parse-junk-integer string))
;;                        (fail-check "No paste by this number!")))
;;   :string-to-value-translator (lambda (string)
;;                                 (find-paste (quick-parse-junk-integer string)))
;;   :value-to-string-translator (lambda (paste)
;;                                 (prin1-to-string (paste-number paste))))

;; (define-form mark-as-spam ()
;;     (paste)
;;   (:submit-text t "Mark as Spam"))

;; (define-form-field (mark-as-spam paste) hidden-paste-field)

;; (define-form request-deletion ()
;;   (paste)
;;   (:submit-text t "Request Deletion"))

;; (define-form-field (request-deletion paste) hidden-paste-field)

;; (define-form request-deletion-with-reason (request-deletion)
;;   (reason email)
;;   (:submit-text t "Request Deletion"))

;; (define-form-field (request-deletion-with-reason reason) textarea-form-field
;;   :string-acceptor (lambda (string)
;;                      (when (zerop (length string))
;;                        (fail-check "Please enter a reason."))))

;; (define-form-field (request-deletion-with-reason email) form-field
;;   :string-acceptor (lambda (string)
;;                      ;; This definition of what an email address is is
;;                      ;; very loose. Oh well.
;;                      (unless (cl-ppcre:scan "^[^@ ]+@[^ ]+\\.\.+$" string)
;;                        (fail-check "Please enter a vaild email address."))))

;; (define-form mark-as-wrong-channel ()
;;     (paste)
;;   (:submit-text t "Wrong Channel"))

;; (define-form-field (mark-as-wrong-channel paste) hidden-paste-field)

(defparameter *untablify-translator* (make-translator))

(define-translator *untablify-translator* untablify-table
  (<table $args> . body)
  body)

(define-translator *untablify-translator* untablify-tr
  (<tr $args> . body)
  body)

(define-translator *untablify-translator* untablify-td
  (<td $args> . body)
  body)

(define-translator *untablify-translator* untablify-th
  (<th $args> . body)
  body)

(defparameter *kill-table-header-contents* (make-translator))

(define-translator *kill-table-header-contents* kill-it
  (<th $args> . body)
  (<td $args>))

;; (define-application-handler (mark-as-spam-handler :get request)
;;   (application-process-form (mark-as-spam)
;;     (application-page ((format nil "Marking paste ~A as spam" (paste-number paste)))
;;      "Are you sure that this paste is spam? Spam for this purpose is defined as:"
;;      (<ul> (<li> "Commercial advertising")
;;         (<li> "Materials containing gratuitious profanity")
;;         (<li> "Materials relating to the mass violation of copyright (e.g. through file-sharing networks)"))
;;      "If so, please click the following button:"
;;      <p/>
;;      (apply-translator
;;       *untablify-translator*
;;       (form-html (mark-as-spam (handler-url 'mark-as-spam-handler))
;;               (paste paste)))
;;      <p/>
;;      "If the paste isn't spam, but you'd like to request that it be
;; deleted for other reasons, please click the following button:"
;;      <p/>
;;      (apply-translator
;;       *untablify-translator*
;;       (form-html (request-deletion (handler-url 'request-deletion-handler) :method :get)
;;               (paste paste)))
;;      <p/>
;;      "If not, please click the following:"
;;      <p/>
;;      (<form> <input type= "button" onclick= "history.back();" value= "It isn't spam!" />))))

;; (define-application-handler (mark-as-spam-handler :post request)
;;     (application-process-form (mark-as-spam)
;;       (setf (paste-maybe-spam-p paste) :true)
;;       (paste-write-xml-to-file paste)
;;       (application-page ((format nil "Paste ~A marked as spam!" (paste-number paste)))
;;      "The paste "
;;      (<a href=? (paste-display-url paste)>
;;          (prin1-to-string (paste-number paste)))
;;      " has been marked as spam. Thank you!")))

;; (define-application-handler (request-deletion-handler :get request)
;;   (application-process-form (request-deletion)
;;     (application-page ((format nil "Requesting deletion of paste ~A" (paste-number paste)))
;;      "Please fill in the following form describing the reason why you
;; want this paste to be deleted. For example:"
;;      (<ul> (<li> "Does it infringe on a copyright?")
;;         (<li> "Does it include personal information?")
;;         (<li> "Was it pasted in error?"))
;;      "Please also include a valid email address where you can be
;; contacted if there are questions about your request. This email will
;; only be shared with the administrator of the site."
;;      <p/>
;;      (form-html (request-deletion-with-reason (handler-url 'request-deletion-handler))
;;              (paste paste))
;;      <p/>
;;      "If not, please click the following:"
;;      <p/>
;;      (<form> <input type= "button" onclick= "history.back();" value= "Whoops! Get me out of here!" />))))

;; (define-application-handler (request-deletion-handler :post request)
;;     (application-process-form (request-deletion-with-reason)
;;       (setf (paste-deletion-requested paste) reason
;;          (paste-deletion-requested-email paste) email)
;;       (paste-write-xml-to-file paste)
;;       (application-page ((format nil "Paste ~A deletion request received!" (paste-number paste)))
;;      "The deletion request for paste "
;;      (<a href=? (paste-display-url paste)>
;;          (prin1-to-string (paste-number paste)))
;;      " has been received and will be reviewed shortly. Thank you!")))

;; (define-application-handler (mark-as-wrong-channel-handler :get request)
;;   (application-process-form (mark-as-wrong-channel)
;;     (application-page ((format nil "Marking paste ~A as to the wrong channel" (paste-number paste)))
;;      "Are you sure this paste went to the wrong channel? If so, please click the following button and paste annotations will no longer notify this channel:"
;;      <p/>
;;      (apply-translator
;;       *untablify-translator*
;;       (form-html (mark-as-wrong-channel (handler-url 'mark-as-wrong-channel-handler))
;;               (paste paste)))
;;      <p/>
;;      "If not, please click the following:"
;;      <p/>
;;      (<form> <input type= "button" onclick= "history.back();" value= "Oops! Never mind." />))))

;; (define-application-handler (mark-as-wrong-channel-handler :post request)
;;   (application-process-form (mark-as-wrong-channel)
;;     (setf (paste-channel paste) "None")
;;     (paste-write-xml-to-file paste)
;;     (application-page ((format nil "Paste ~A removed from this channel!" (paste-number paste)))
;;       "The paste "
;;       (<a href=? (paste-display-url paste)>
;;        (prin1-to-string (paste-number paste)))
;;       " has been removed from this channel. Thank you!")))

(defun format-paste (paste this-url paste-number &optional annotation colorize-as line-numbers)
  (let ((n 0) (next-first-char-nbsp t))
    (labels
        ((line-number ()
           (format nil "<span class=\"paste\">~A&nbsp;</span>"
                   (encode-for-tt (format nil "~4D:" (incf n))
                                  :first-char-nbsp t)))
         (encode (str)
           (if line-numbers
               (multiple-value-bind (encoded last)
                   (encode-for-tt (remove #\return str)
                                  :with-line-numbers #'line-number
                                  :first-char-nbsp next-first-char-nbsp)
                 (prog1 encoded
                   (setf next-first-char-nbsp last)))
               (encode-for-pre (remove #\return str)))))
      (<div>
       (<table class="paste-header">
               (<tr>
                (<td align="left" width="0%" nowrap="nowrap">
                     (if annotation
                         (<a name=?(prin1-to-string paste-number)> "Annotation number ")
                         "Paste number ") paste-number ": ")
                (<td align="left" width="100%">
                     (<b> (paste-title paste))))
               (<tr> (<td align="left" nowrap="nowrap"> "Pasted by: ")
                     (<td align="left" width="100%"> (paste-user paste)))
               (<tr> (<td> "When:")
                     (<td align="left" width="100%">
                          (time-delta (paste-universal-time paste))))
               (if (paste-expiration-time paste)
                   (<tr> (<td> "Expires:")
                     (<td align="left" width="100%">
                          "in " (time-delta (paste-expiration-time paste) :inverse t :ago-p nil))))
               (<tr> (<td> "Share:")
                     (<td align= "left" width= "100%">
                          (<a href=? (paste-tweet-url paste)>
                              "Tweet this!")
                          " | "
                          (<a href=? (paste-short-url paste) >
                              (full-url (paste-short-url paste)))))
               (when (not annotation)
                 (<tr>
                  (<td> "Channel:")
                  (<td align="left" width="100%">
                       (unless annotation
                         (<a href=?(channel-list-url (paste-channel paste))>
                             (paste-channel paste))))))
               (<tr>
                (<td align="left" valign="top" nowrap="nowrap"> "Paste contents:")
                (when this-url
                  (<td width="100%">
                       (<form method= "post" action=? (concatenate 'string (paste-display-url paste) "/raw")>
                              (<a href=?(concatenate 'string (paste-display-url paste) "/raw")> "Raw Source")
                              (unless annotation
                                (list " | "
                                      (<a href=?(concatenate 'string (paste-display-url paste) "/xml")> "XML")))
                              " | Display As "
                              (<select name= "type">
                                       (loop for type in *allowed-content-types*
                                             collect (<option value=?type> type)))
                              <input type= "submit" value= "OK" />)))))
       (<pre class="paste-area">
        (when line-numbers (make-unescaped-string (line-number)))
        ;; FIXME!!! This all needs to be converted to use
        ;; XML objects natively.
        (make-unescaped-string
         (if colorize-as
             (memoize-format (list (paste-contents paste)
                                   colorize-as
                                   line-numbers)
                             (lambda ()
                               (colorize:format-scan colorize-as
                                                     (mapcar #'(lambda (e)
                                                                 (cons (car e)
                                                                       (encode (cdr e))))
                                                             (colorize:scan-string colorize-as (paste-contents paste))))))
             (encode (paste-contents paste)))))))))

(defun parse-paste-number (script-name)
  (ppcre:register-groups-bind (integer)
      (#.(format nil "^~a(\\d+)" *display-paste-url*) script-name)
    (parse-integer integer)))

(define-easy-handler (display :uri (match-prefix *display-paste-url*))
    (colorize linenumbers type)
  (let* ((paste-number (parse-paste-number (script-name*)))
         (paste-number (if (= paste-number 132002)
                           (progn (setf (return-code*) +http-not-found+)
                                  (sleep 1)
                                  (return-from display ""))
                           paste-number))
         (raw (ends-with (script-name*) "/raw"))
         (xml (ends-with (script-name*) "/xml"))
         (content-type (or type "text/plain"))
         (paste (find-paste paste-number))
         (expired (find-expired-paste paste-number))
         (linenumbers (equalp linenumbers
                              "true"))
         (colorize-string (or colorize
                              (and paste
                                   (if (eql (paste-colorization-mode paste) :none)
                                       (progn (setf (paste-colorization-mode paste) "")
                                              nil)
                                       t)
                                   (> (length (paste-colorization-mode paste)) 0)
                                   (paste-colorization-mode paste))))
         (colorize-as (or
                       (car (rassoc colorize-string (colorize:coloring-types) :test #'string-equal))
                       (if (and paste
                                (not (string-equal colorize-string "None")))
                           (gethash (paste-channel paste) *coloring-type-defaults*))))
         (colorize:*css-background-class* "paste"))
    (cond
      ((find #\? (request-uri*))  ;; redirect when we have a query string; for some reason we're spammed with query strings...
       (redirect (paste-display-url paste) :code +http-moved-permanently+))
;;       (setf
;;         (return-code*) +http-moved-permanently+
;;         (headers-out*)
;;          (list*
;;           (list :location (paste-display-url paste))
;;           '((:expires "Fri, 30 Oct 1998 14:19:41 GMT")
;;             (:pragma "no-cache")
;;             (:response-code 301)
;;             (:response-text "Redirected")
;;            (:content-type "text/plain"))))
;;       (send-headers)
;;       (write-string "Redirected!" (request-stream request)))

      ((not (find content-type *allowed-content-types* :test #'equal))
       (xml-to-string
        (lisppaste-wrap-page
         (format nil "Bad content-type ~A!~%" content-type))))
      ((and paste (or raw xml))
       (let ((p (and raw (position #\, (script-name*)))))
         (cond (p
                (let ((ann (quick-parse-junk-integer (script-name*) :start (1+ p))))
                  (let ((theann (car (member ann (paste-annotations paste) :key #'paste-number :test #'eql))))
                    (when theann
                      (setf (content-type*) content-type)
                      (remove #\Return
                              (paste-contents theann)
                              :test #'char=)))))
               (raw (setf (content-type*) content-type)
                    (remove #\return
                            (paste-contents paste)
                            :test #'char=))
               (t (setf (content-type*) "text/xml")
                  (with-output-to-string (stream)
                    (paste-write-xml paste stream))))))
      (paste
       (let ((annotate-html
               (<table class="controls">
                       (<tr>
                        (<td>
                         (when (paste-annotations paste)
                           (list "Index of paste annotations: "
                                 (loop for ann in (reverse (paste-annotations paste))
                                       for test from (length (paste-annotations paste)) downto 1
                                       collect
                                       (<a href=?(format nil "#~A" (paste-number ann))>
                                           (prin1-to-string (paste-number ann)))
                                       if (not (eql test 1))
                                       collect " | ")
                                 <p/>))
                         <input type="hidden" name="annotate" value=?(prin1-to-string (paste-number paste)) />
                         (unless (paste-moldy paste)
                           <input type="submit" value="Annotate this paste"/>))))))
         (setf (content-type*)
               (if (paste-is-unicode-p paste)
                   "text/html; charset=utf-8"
                   "text/html; charset=iso-8859-1"))
         (xml-to-string
          (lisppaste-wrap-page
           (format nil "Paste number ~A: ~A" paste-number (paste-title paste))
           (<div>
            (<form method="post" action=?*new-paste-url*>

                   (when (or (paste-annotations paste)
                             (not (paste-moldy paste)))
                     (<center> annotate-html)))
            <p/>
            (format-paste paste (request-uri*) paste-number nil colorize-as
                          linenumbers)
            (if (paste-annotations paste)
                (<p>
                 (<span class="small-header">
                        "Annotations for this paste: "
                        )
                 (nreverse
                  (loop for a in (paste-annotations paste)
                        collect (<p>
                                 (format-paste
                                  a
                                  (format nil "~A,~A"
                                          (request-uri*)
                                          (paste-number a))
                                  (paste-number a)
                                  t colorize-as linenumbers)))))
                (<p>
                 (<span class="small-header">
                        "This paste has no annotations.")))
            <p/>
            (<table width="100%">
                    (<tr>
                     (<td align="left">
                          (<form method="post" action=?(request-uri*) >
                                 (<table class="controls">
                                         (<tr>
                                          (<td>
                                           "Colorize as: "
                                           (<select name="colorize">
                                                    (<option value="None"> "None")
                                                    (loop for pair in (colorize:coloring-types)
                                                          collect
                                                          (<option value=?(cdr pair) $(if (eq (car pair) colorize-as) '("selected" "SELECTED")) >
                                                                   (cdr pair))))
                                           <br/>
                                           <input type="checkbox" name="linenumbers" value="true" $(if linenumbers '("checked" "checked")) />
                                           " Show Line Numbers"
                                           <br/>
                                           (<center>
                                            <input type="submit" value="Format"/>))))))
                     ;; (<td align="right">
                     ;;      (apply-translator
                     ;;       *untablify-translator*
                     ;;       (list
                     ;;        (if (paste-maybe-spam-p paste)
                     ;;         (list
                     ;;          (<span class= "controls">
                     ;;                 "Already reported as spam.")
                     ;;          <p/>)
                     ;;         (form-html (mark-as-spam (handler-url 'mark-as-spam-handler) :method :get)
                     ;;              (paste paste)))

                     ;;        (if (paste-deletion-requested paste)
                     ;;         (list
                     ;;          (<span class= "controls">
                     ;;                 "Already requested for deletion.")
                     ;;          <p/>)
                     ;;         (form-html (request-deletion (handler-url 'request-deletion-handler) :method :get)
                     ;;              (paste paste)))

                     ;;        (unless (string-equal (paste-channel paste) "None")
                     ;;          (form-html (mark-as-wrong-channel (handler-url 'mark-as-wrong-channel-handler) :method :get)
                     ;;            (paste paste)))

                     ;;        (when (or (paste-annotations paste)
                     ;;               (not (paste-moldy paste)))
                     ;;          (<form method="post" action=?*new-paste-url*>
                     ;;              annotate-html)))))
                     ))
            <p/>)))))
      (expired
       (setf (return-code*)
             +http-not-found+)
       (xml-to-string
        (lisppaste-wrap-page
         (format nil "Sorry, the paste numbered ~A expired ~A." paste-number
                 (time-delta (paste-expiration-time expired))))))
      (t
       (setf (return-code*) +http-not-found+)
       (xml-to-string
        (lisppaste-wrap-page
         (format nil "Invalid paste number ~A!" paste-number)))))))

(defun parse-short-paste-number (script-name)
  (ppcre:register-groups-bind (paste annotation)
      ("^/\\+(\\w+)/?(\\w*)" script-name)
    (values
     (parse-integer paste :junk-allowed t :radix 36)
     (and annotation
          (parse-integer annotation :junk-allowed t :radix 36)))))



(define-easy-handler (short-paste :uri (match-prefix *short-paste-url* nil)) ()
  (multiple-value-bind (paste-number annotation)
      (parse-short-paste-number (script-name*))
    (let* ((paste (find-paste paste-number))
           (url (and paste
                     (format nil "~a~@[#~A~]" (paste-display-url paste) annotation))))
      (cond
        (paste
         (redirect url))
        (t
         (setf (return-code*) +http-not-found+)
         (xml-to-string
          (lisppaste-wrap-page
           (format nil "Invalid paste number ~A!" paste-number))))))))

(define-easy-handler (email-redirect :uri *email-redirect-url*) ()
  (redirect (format nil "mailto:~a?subject=" *owner-email*)))
