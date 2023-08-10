(import jplz/debug)

(def deprintf debug/deprintf)

########################################################################

(import jplz/name)

(def cmd-name name/cmd-name)

########################################################################

(def sample-config
  {:help "Simple sample subcommand."
   :rules []
   :fn (fn [_meta _args] (print "hi"))})

########################################################################

(def juat-config
  {:help "Run juat tests."
   :rules []
   :fn (fn [_meta _args]
         (os/execute ["janet"
                      (string (os/getenv "HOME")
                              "/"
                              "src/"
                              "janet-usages-as-tests/"
                              "janet-usages-as-tests/"
                              "make-and-run-tests.janet" )
                      (os/cwd)]
                     :px))})

########################################################################

(def chomp-slow-config
  {:help "Remove trailing newlines from end of file."
   :rules [:file-path {:help "File to examine and may be change"}]
   :fn (fn [_meta args]
         (def file-path
           (get-in args [:params :file-path]))
         (deprintf "%p" file-path)
         (when (= :file
                  (os/stat file-path :mode))
           (def backwards
             (string/reverse (slurp file-path)))
           (def m
             (peg/match '(capture (any "\n")) backwards))
           (when m
             (def n (length (first m)))
             (def b-len (length backwards))
             (spit file-path
                   (slice (string/reverse backwards)
                          0 (- b-len n))))))})

########################################################################

# required - used by jplz/main.janet
(def subcommands
  ["my/sample" sample-config
   "juat" juat-config
   "chomp-slow" chomp-slow-config])

