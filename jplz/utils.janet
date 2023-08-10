(defn just-names
  [subcommands]
  (->> (partition 2 subcommands)
       (map first)))

# XXX: unnecssary extra searching happens, but does it really matter?
(defn validate-subcommands
  [subcommands]
  (def subcommands-len (length subcommands))
  (unless (even? subcommands-len)
    (break [:length-not-even subcommands-len]))
  (def subcommands-names (just-names subcommands))
  (unless (all string? subcommands-names)
    (break [:name-not-string
            (find |(not (string? $)) subcommands-names)]))
  (def subcommands-configs
    (->> (partition 2 subcommands)
         (map (fn [[_name config]] config))))
  (unless (all |(dictionary? $) subcommands-configs)
    (break [:config-not-dictionary
            (find |(not (dictionary? $)) subcommands-configs)]))
  (unless (all |(has-key? $ :fn) subcommands-configs)
    (break [:config-missing-fn-key
            (find |(not (has-key? $ :fn)) subcommands-configs)]))
  #
  true)

(defn validate-config
  [config]
  (unless (dictionary? config)
    (break [:config-not-dictionary config]))
  (unless (has-key? config :fn)
    (break [:config-missing-fn-key config]))
  #
  true)

(defn report-error
  [[err-type value]]
  (case err-type
    :length-not-even
    (eprintf "Expected even number of items, but found: %d" value)
    :name-not-string
    (eprintf "Expected name to be a string, but found a %s: %p"
             (type value) value)
    :config-not-dictionary
    (eprintf "Expected config to be a dictionary, but found a %s: %p"
             (type value) value)
    :config-missing-fn-key
    (eprintf "Expected :fn key in config, but only found keys: %p"
             (keys value))
    #
    (errorf "Unknown error: %p" err-type)))

