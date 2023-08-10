(import ./debug)

(def deprintf debug/deprintf)

########################################################################

(import ./name)

(def cmd-name name/cmd-name)

(def subcmds-file-env-var-name
  (string/format "%s_SUBCMDS"
                 (string/ascii-upper cmd-name)))

# XXX: investigate whether this is sufficient
(def home-dir
  (if (= :windows (os/which))
    (os/getenv "USERPROFILE")
    (os/getenv "HOME")))

# XXX: make configurable via env var?
(def subcmds-dir
  (string/format "%s/.%s"
                 home-dir cmd-name))

(def subcmds-file-path
  (string subcmds-dir "/subcommands.janet"))

########################################################################

(import ./utils)

########################################################################

(import ./vendor/argy-bargy :as ab)

########################################################################

(import ./subcommands/bash-completion :as bc)
(import ./subcommands/clink-completion :as cc)
(import ./subcommands/zsh-completion :as zc)
(import ./subcommands/list-subcommands :as lc)

(def default-subcommands
  ["bash-completion" bc/config
   "clink-completion" cc/config
   "zsh-completion" zc/config
   "list-subcommands" lc/config])

########################################################################

(def config
  {:info {:about (string/format "Janet, please ... (%s)"
                                cmd-name)
          :opts-header "The following global options are available:"
          :subs-header "The following subcommands are available:"}
   :rules ["--version" {:help "Show version information."
                        :kind :flag
                        :short "v"}]})

########################################################################

(defn get-subconfig
  [subcommands args]
  (var res nil)
  (var sub args)
  (var sub-args nil)
  (while (set sub (get sub :sub))
    (set sub-args sub)
    (set res (get sub :cmd)))
  (def i (find-index (fn [x] (= res x)) subcommands))
  (if (nil? i)
    [nil nil]
    [(get subcommands (inc i)) sub-args]))

(defn load-subcommands
  [defaults]
  (def subcommands (array ;defaults))
  (unless (os/stat subcmds-dir)
    (break subcommands))
  (def user-sc-names @[])
  # subcommand per directory
  (each name (os/dir subcmds-dir)
    (def full-dir-path (string subcmds-dir "/" name))
    (when (= :directory (os/stat full-dir-path :mode))
      (def sc-file-path (string full-dir-path "/subcommand.janet"))
      (when (os/stat sc-file-path)
        (def env (dofile sc-file-path))
        (unless (env 'config)
          (errorf "%s: missing `config` binding" sc-file-path))
        (def user-config (get-in env ['config :value]))
        (def result (utils/validate-config user-config))
        (when (tuple? result)
          (break result))
        (array/push subcommands "---")
        (array/concat subcommands [name user-config])
        (array/push user-sc-names name))))
  (setdyn :user-subcmds user-sc-names)
  # subcommands in file "subcommands.janet"
  (def user-file
    (or (os/getenv subcmds-file-env-var-name)
        subcmds-file-path))
  (when user-file
    (when (= :file (os/stat user-file :mode))
      (def env (dofile user-file))
      #
      (unless (env 'subcommands)
        (errorf "%s: missing `subcommands` binding" user-file))
      (def user-subcommands (get-in env ['subcommands :value]))
      (def result (utils/validate-subcommands user-subcommands))
      (when (tuple? result)
        (break result))
      (array/push subcommands "---")
      (array/concat subcommands user-subcommands)
      #
      (def sub-cmd-names (utils/just-names user-subcommands))
      (setdyn :user-subcmds [;sub-cmd-names ;(dyn :user-subcmds)])))
  subcommands)

########################################################################

(defn main
  [& argv]
  (def default-sc-names (utils/just-names default-subcommands))
  (setdyn :default-subcmds default-sc-names)
  #
  (def result (load-subcommands default-subcommands))
  (when (tuple? result)
    (utils/report-error result)
    (os/exit 1))
  (def subcommands result)
  (deprintf "subcommands: %p\n" subcommands)
  (def full-config (merge config {:subs subcommands}))
  (deprintf "full-config: %p\n" full-config)
  (def res (ab/parse-args cmd-name full-config))
  (deprintf "parse-args returned: %p\n" res)
  (def help (get res :help))
  (def err (get res :err))

  (when (and err
             (string/has-prefix?
               (string cmd-name ": unrecognized subcommand") err))
    (eprint err)
    (os/exit 1))

  (cond
    (and help (not (empty? help)))
    (prin help)

    (and err (not (empty? err)))
    (eprin err)

    (get-in res [:opts "version"])
    # XXX: use timestamp from file content?
    (print "Some version")

    (do
      (def [subconfig sub-res] (get-subconfig subcommands res))
      (if subconfig
        ((subconfig :fn) @{} sub-res)
        # XXX: don't know if this is so good
        (prin (get (with-dyns [:args @[cmd-name "--help"]]
                     (ab/parse-args cmd-name full-config))
                   :help))))))

