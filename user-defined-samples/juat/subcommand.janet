(import ./make-and-run-tests :as mart)

# XXX: work-around for redundancy...
(def about-string
  "Generate and run janet-usages-as-tests tests.")

(def config
  {:help about-string
   :rules [:paths {:help "Input files and/or directories"
                   :rest? true}]
   :info {:about about-string}
   :fn (fn [_meta args]
         (def paths
           (if-let [paths (get-in args [:params :paths])]
             paths
             @["."]))
         (mart/main nil ;paths))})

