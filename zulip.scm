(require-extension defstruct)
(use http-client)
(use intarweb)
(use uri-common)
(use json)

; Surrounds a string between two delimiters
; Example:
; >>> (string-surround "hello" "[" "]")
; "[hello]"
; >>> (string-surround "hello" "\"")
; "\"hello\""
(define (string-surround str del1 #!optional del2)
  (if del2
    (string-append del1 str del2)
    (string-append del1 str del1)))

; Returns a copy of the first `n` elements of a list
; Example:
; >>> (list-head '(1 2 3 4) 2)
; (1 2)
(define (list-head l n)
  (if (> n 1)
    (cons (car l) (list-head (list-tail l 1) (- n 1)))
    (list (car l))))

; Joins a list with a delimiter
; Example:
; >>> (join '("1" "2" "3") ",")
; 1,2,3
(define (join l c)
  (let ((len-prime (- (length l) 1)))
    (if (= len-prime -1)
      (car l)
      (foldr (lambda (x m) (string-append x c m))
             (list-ref l len-prime)
             (list-head l len-prime)))))

; Renders a list of strings as a JSON list of strings
; Example:
; >>> (to-json-arr '("1" "2" "3"))
; "[\"3\",\"2\",\"1\"]"
(define (to-json-arr l)
  (string-surround (join (map (lambda (c)
                                (string-surround c "\"")) l)
                         ",")
                   "["
                   "]"))

; Represents a Zulip API "connection"
(defstruct conn username key baseuri authuri)

; Creates a new Zulip API "connection" given an `username` and `key`
(define (simple-conn #!key username key)
  (let ((conn (make-conn username: username
                         key: key
                         baseuri: "https://api.zulip.com/v1/messages")))
    (update-conn conn
                 authuri: (generate-authuri (conn-baseuri conn)
                                            username
                                            key))))

; Get's the `intarweb` authenticated URI object, for an username, key and
; baseuri
(define (generate-authuri #!key baseuri username key)
  (update-uri (absolute-uri baseuri)
              username: username
              password: key))

; Sends a message through the zulip api
(define (zulip-send-message #!key conn type content subject to)
  (zulip-request conn
                 'POST
                 '((type    . type)
                   (content . content)
                   (subject . subject)
                   (to      . (to-json to)))))

; Sends a private message over zulip
(define (zulip-private-message conn content to)
  (zulip-send-message conn "private" content "" to))

; Sends a stream message over zulip
(define (zulip-stream conn subject content to)
  (zulip-send-message conn "stream" content subject to))

; Makes an authentiated `method` HTTP request to the zulip API, sending a
; form-data representation of `body` and parsing the JSON response.
(define (zulip-request conn method body)
  (let ((req (make-request uri:    (conn-authuri conn)
                           port:   80
                           method: method)))
    (with-input-from-request req body json-read)))
