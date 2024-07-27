(def default-cols 72)

(defn split-words
  ```
  Split a string into words
  ```
  [str]
  (peg/match ~(any (choice " "
                           (cmt (capture (at-least 2 "\n"))
                                ,(fn [_] "\n\n"))
                           "\n"
                           (capture (to (choice " " "\n" -1)))))
             str))

(comment

  (split-words "hello there sam")
  # =>
  @["hello" "there" "sam"]

  (split-words
    ``
    A first paragraph.

    A second paragraph.
    ``)
  # =>
  @["A" "first" "paragraph."
    "\n\n"
    "A" "second" "paragraph."]

  (split-words
    ``
    A first paragraph.


    A second paragraph.
    ``)
  # =>
  @["A" "first" "paragraph."
    "\n\n"
    "A" "second" "paragraph."]

  )

# XXX: adapted from argy-bargy's indent-str
# XXX: "Hanging Indent" https://www.computerhope.com/jargon/h/hanginde.htm
(defn format
  ```
  Formats a string.

  `start-w` (start width - default 0) specifies the starting tracking
  position - with respect to wrapping - on the first line.

  `start-p` (start position - default 0) spaces are added at the
  beginning of the result.

  `max-w` (maximum width - default `default-cols` [1]) affects
  wrapping.

  `hang-p` (hanging padding - default 0) affects indentation on all
  lines except the first one.

  [1] `max-w`'s default value is can be overriden by the dynamic
  variable `:text/cols`.
  ```
  [str &opt start-w start-p hang-p max-w]
  (default start-w 0)
  (default start-p 0)
  (default hang-p 0)
  (default max-w (dyn :text/cols default-cols))
  (def res (buffer (string/repeat " " start-p)))
  (var curr-w start-w)
  (var first-in-p? true)
  (each word (split-words str)
    (cond
      first-in-p?
      (do
        (buffer/push res word)
        (+= curr-w (length word))
        (set first-in-p? false))
      #
      (= "\n\n" word)
      (do
        (buffer/push res word (string/repeat " " hang-p))
        (set curr-w hang-p)
        (set first-in-p? true))
      #
      (< (+ curr-w 1 (length word)) max-w)
      (do
        (buffer/push res " " word)
        (+= curr-w (+ 1 (length word))))
      #
      (do
        (buffer/push res "\n" (string/repeat " " hang-p) word)
        (set curr-w (+ hang-p (length word))))))
  res)

(comment

  (format
    ``
    With a peg-special, but no options, show docs and usages.
    If any of "integer", "string", or "struct" are specified as the
    "peg-special", show docs and usages about using those as PEG
    constructs.

    With the `-d` or `--doc` option, show docs for specified
    PEG special, or if none specified, for a randomly chosen one.

    With the `-q` or `--quiz` option, show quiz question for
    specified PEG special, or if none specified, for a randonly chosen
    one.
    ``
    2 2 2 40)
  # =>
  @``
     With a peg-special, but no options,
     show docs and usages. If any of
     "integer", "string", or "struct" are
     specified as the "peg-special", show
     docs and usages about using those as
     PEG constructs.

     With the `-d` or `--doc` option, show
     docs for specified PEG special, or if
     none specified, for a randomly chosen
     one.

     With the `-q` or `--quiz` option,
     show quiz question for specified PEG
     special, or if none specified, for a
     randonly chosen one.
   ``

  )

# XXX: what to do if some item exceeds limit - indent?  options:
#
#      1. abort execution
#      2. insert at current position and go to next line
#      3. insert at beginning of next line + indent and go to next
#         line
(defn layout
  [list indent limit &opt eol]
  (default eol "\n")
  (def buf @"")
  (def indent-spaces (string/repeat " " indent))
  (def list-len (length list))
  (var col indent) # left-most column is 0
  (var idx 0)
  #(var insert-failed nil)
  (buffer/push buf indent-spaces)
  (while (< idx list-len)
    (def item (get list idx))
    (def item-len (length item))
    (when (> item-len (- limit indent))
      (errorf "item len > limit - indent: %d > (%d - %d)"
              item-len limit indent))
    (if (< (+ col item-len) limit)
      (do
        (buffer/push buf item " ")
        (+= col item-len 1)
        #(set insert-failed false)
        (++ idx))
      (do
        #(assert (not insert-failed)
        #        (string/format "item len > limit - indent: %d > (%d - %d)"
        #                       item-len limit indent))
        # remove last space
        (buffer/popn buf 1)
        (buffer/push buf eol)
        (buffer/push buf indent-spaces)
        (set col indent)
        #(set insert-failed true)
        )))
  #
  buf)

(comment

  (layout '[abstract? accumulate accumulate2 all all-bindings all-dynamics
            any? apply array array/clear array/concat array/ensure
            array/fill array/insert array/new array/new-filled array/peek
            array/pop]
          6 72)

  (def a-list
    '[abstract? accumulate accumulate2 all all-bindings all-dynamics
      any? apply array array/clear array/concat array/ensure array/fill
      array/insert array/new array/new-filled array/peek array/pop
      array/push array/remove array/slice array/trim array/weak array?
      asm

      bad-compile bad-parse band blshift bnot boolean? bor brshift
      brushift buffer buffer/bit buffer/bit-clear buffer/bit-set
      buffer/bit-toggle buffer/blit buffer/clear buffer/fill
      buffer/format buffer/format-at buffer/from-bytes buffer/new
      buffer/new-filled buffer/popn buffer/push buffer/push-at
      buffer/push-byte buffer/push-float32 buffer/push-float64
      buffer/push-string buffer/push-uint16 buffer/push-uint32
      buffer/push-uint64 buffer/push-word buffer/slice buffer/trim
      buffer? bundle/add bundle/add-directory bundle/add-file
      bundle/install bundle/installed? bundle/list bundle/manifest
      bundle/prune bundle/reinstall bundle/topolist bundle/uninstall
      bundle/update-all bxor bytes?])

  (layout a-list 6 72)

  )

(defn group-by-nth-char
  [things n]
  (def groups @{})
  (def before-key (dec (chr "A")))
  (each item things
    (def head (get item n))
    (cond
      (or (<= (chr "a") head (chr "z"))
          (<= (chr "A") head (chr "Z")))
      (put groups head
           (array/push (get groups head @[])
                       item))
      #
      (put groups before-key
           (array/push (get groups before-key @[])
                       item))))
  #
  groups)

(defn group-nicely
  [things]
  (def a-first-char (get-in things [0 0]))
  (def things-all-start-same?
    (all |(= a-first-char (get $ 0)) things))
  (if things-all-start-same?
    (group-by-nth-char things 1)
    (group-by-nth-char things 0)))

(comment

  (group-nicely
    '@[% * + - / < <= = > >=

       abstract? accumulate accumulate2 all all-bindings all-dynamics
       any? apply array array/clear array/concat array/ensure array/fill
       array/insert array/new array/new-filled array/peek array/pop
       array/push array/remove array/slice array/trim array/weak array?
       asm

       bad-compile bad-parse band blshift bnot boolean? bor brshift
       brushift buffer buffer/bit buffer/bit-clear buffer/bit-set
       buffer/bit-toggle buffer/blit buffer/clear buffer/fill
       buffer/format buffer/format-at buffer/from-bytes buffer/new
       buffer/new-filled buffer/popn buffer/push buffer/push-at
       buffer/push-byte buffer/push-float32 buffer/push-float64
       buffer/push-string buffer/push-uint16 buffer/push-uint32
       buffer/push-uint64 buffer/push-word buffer/slice buffer/trim
       buffer? bundle/add bundle/add-directory bundle/add-file
       bundle/install bundle/installed? bundle/list bundle/manifest
       bundle/prune bundle/reinstall bundle/topolist bundle/uninstall
       bundle/update-all bxor bytes?])
  # =>
  '@{64 @[% * + - / < <= = > >=]

     97 @[abstract? accumulate accumulate2 all all-bindings
          all-dynamics any? apply array array/clear array/concat
          array/ensure array/fill array/insert array/new
          array/new-filled array/peek array/pop array/push
          array/remove array/slice array/trim array/weak array? asm]

     98 @[bad-compile bad-parse band blshift bnot boolean? bor brshift
          brushift buffer buffer/bit buffer/bit-clear buffer/bit-set
          buffer/bit-toggle buffer/blit buffer/clear buffer/fill
          buffer/format buffer/format-at buffer/from-bytes buffer/new
          buffer/new-filled buffer/popn buffer/push buffer/push-at
          buffer/push-byte buffer/push-float32 buffer/push-float64
          buffer/push-string buffer/push-uint16 buffer/push-uint32
          buffer/push-uint64 buffer/push-word buffer/slice buffer/trim
          buffer? bundle/add bundle/add-directory bundle/add-file
          bundle/install bundle/installed? bundle/list bundle/manifest
          bundle/prune bundle/reinstall bundle/topolist
          bundle/uninstall bundle/update-all bxor bytes?]}

  (group-nicely
    '@["*args*" "*current-file*" "*debug*" "*defdyn-prefix*"
       "*doc-color*" "*doc-width*" "*err*" "*err-color*"
       "*executable*" "*exit*" "*exit-value*" "*ffi-context*"
       "*lint-error*" "*lint-levels*" "*lint-warn*"
       "*macro-form*" "*macro-lints*" "*module-cache*"
       "*module-loaders*" "*module-loading*"
       "*module-make-env*" "*module-paths*" "*out*"
       "*peg-grammar*" "*pretty-format*" "*profilepath*"
       "*redef*" "*syspath*" "*task-id*"])
  # =>
  '@{97 @["*args*"]
     99 @["*current-file*"]
     100 @["*debug*" "*defdyn-prefix*" "*doc-color*" "*doc-width*"]
     101 @["*err*" "*err-color*" "*executable*" "*exit*" "*exit-value*"]
     102 @["*ffi-context*"]
     108 @["*lint-error*" "*lint-levels*" "*lint-warn*"]
     109 @["*macro-form*" "*macro-lints*" "*module-cache*"
           "*module-loaders*" "*module-loading*" "*module-make-env*"
           "*module-paths*"]
     111 @["*out*"]
     112 @["*peg-grammar*" "*pretty-format*" "*profilepath*"]
     114 @["*redef*"]
     115 @["*syspath*"]
     116 @["*task-id*"]}

  )
