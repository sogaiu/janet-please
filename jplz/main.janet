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

(import ./version)

(def ver-string version/ver-string)

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
          :subs-header "The following subcommands are available:"
          :usages [(string/format "Usage: %s [--help | --version]"
                                  cmd-name)
                   (string/format "       %s help <subcommand>"
                                  cmd-name)
                   (string/format "       %s <subcommand> [<args>]"
                                  cmd-name)]}
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
  (when i
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

  (def err (get res :err))
  (deprintf "err: %p\n" err)

  # hopefully failing fast is appropriate
  (when (not (empty? err))
    (eprint err)
    (os/exit 1))

  (def help (get res :help))
  (deprintf "help: %p\n" help)

  (def opts (get res :opts))
  (deprintf "opts: %p\n" opts)

  (def params (get res :params))
  (deprintf "params: %p\n" params)

  (def sub (get res :sub))
  (deprintf "sub: %p\n" sub)

  (cond
    (get opts "help")
    (prin help)

    (get opts "version")
    (printf "%s: %s" cmd-name ver-string)

    (def result (get-subconfig subcommands res))
    (let [[subconfig sub-res] result]
      (if subconfig
        ((subconfig :fn) @{} sub-res)
        # XXX: don't know if this is so good
        (let [a-res (with-dyns [:args @[cmd-name "--help"]]
                      (ab/parse-args cmd-name full-config))]
          (prin (get a-res :help)))))

    (not (empty? help))
    (prin help)

    (do (eprint "Unexpected state") (os/exit 1))))

