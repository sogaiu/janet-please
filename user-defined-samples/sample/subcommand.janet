(import jplz/debug)

(def deprintf debug/deprintf)

########################################################################

(def config
  {:help "Simple sample subcommand."
   :rules []
   :fn (fn [_meta _args] (print "hi"))})

