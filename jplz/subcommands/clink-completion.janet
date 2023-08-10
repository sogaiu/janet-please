(import ../name)

(def cmd-name name/cmd-name)

(def cc-src
  (string/format
    ``
    -- https://chrisant996.github.io/clink/clink.html#generator_basics
    local %s_autocomplete = clink.generator(1)

    local function starts_with(str, start)
        return string.sub(str, 1, string.len(start)) == start
    end

    local function is_%s_ac(text)
        if starts_with(text, "%s ") then
            return true
        end
        return false
    end

    local function get_subcommand_names()
        -- Run %s list-subcommands to get subcommand names
        local handle = io.popen("%s list-subcommands 2>&1")
        local result = handle:read("*a")
        handle:close()
        -- Parse the subcommand names from the output.
        local names = {}
        for name in string.gmatch(result, "%%S+") do
            table.insert(names, name)
        end
        return names
    end

    function %s_autocomplete:generate(line_state, match_builder)
        if not is_%s_ac(line_state:getline()) then
            return false
        end
        -- Get subcommand names and add them
        local matchCount = 0
        for _, name in ipairs(get_subcommand_names()) do
            match_builder:addmatch(name)
            matchCount = matchCount + 1
        end
        -- If we found names, then stop other match generators.
        return matchCount > 0
    end
    ``
    cmd-name cmd-name cmd-name cmd-name cmd-name cmd-name cmd-name))

(def config
  {:help (string/format "Print clink completion code.")
   :rules []
   :fn (fn [_meta _args]
         (print cc-src))})

