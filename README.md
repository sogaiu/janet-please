# janet-please (jplz)

Easily package up bits of functionality written in Janet to
be invokable at the command line in the form of subcommands for reuse,
sharing, and discussion.

By expressing specific functionality as a subcommand of an existing
already installed utility (`jplz`), we can:

* Skip some typical "deployment" / "installation" steps -- no need to
  place anything additional on `PATH` as adding a new subcommand only
  requires either:

    * editing a file (`subcommands.janet`) -OR-
    * creating a suitable directory and appropriately populating it
      with a single file

* Put off having to think of a name that doesn't conflict with other
  command line program names.  The only names that need to be avoided
  are the built-in subcommand names and others you may have already
  chosen for subcommands.

## Status

Used daily, but still working things out -- including these docs :)

## Setup

### Unixy

Clone this repository.  Suppose cloned source is typically stored
under `~/src`, then:

```
cd ~/src
git clone https://github.com/sogaiu/janet-please
```

Arrange for some place to house user-defined subcommands.  One way is
to symlink to the provided `user-defined-samples` subdirectory:

```
cd $HOME
ln -s ~/src/janet-please/user-defined-samples .jplz
```

Another way is to create the `~/.jplz` subdirectory:

```
cd $HOME
mkdir .jplz
```

### Windows

Clone this repository.  Suppose cloned source is typically stored
under `C:\Users\user\src`, then:

```
cd C:\Users\user\src
git clone https://github.com/sogaiu/janet-please
```

Arrange for some place to house user-defined subcommands.  One way is
to copy the provided `user-defined-samples` subdirectory:

```
cd %USERPROFILE%
xcopy /E /I C:\Users\user\src\janet-please\user-defined-samples .jplz
```

Another way is to create the `.jplz` subdirectory in an appropriate
location:

```
cd %USERPROFILE%
mkdir .jplz
```

## Completion

There are some built-in subcommands to output completion-related code
for various "shells":

### `bash`

```
jplz bash-completion
```

### `zsh`

```
jplz zsh-completion
```

### [`clink`](https://github.com/chrisant996/clink/) ("injected" `cmd.exe` on Windows)

```
jplz clink-completion
```

Each "shell" has one or more ways of making the completion
functionality active.  For example, in `bash`'s case, one way to get
things working is to place a file named `jplz` under
`~/.local/share/bash-completion/completions/` and populate it with the
output from `jplz bash-completion`.

## Related

* [`jeep`](https://github.com/pyrmont/jeep)
* [`sd`](https://github.com/ianthehenry/sd)

## Credits

* pyrmont - `jplz` was inspired through use and discussion of
  [`jeep`](https://github.com/pyrmont/jeep) and
  [`argy-bargy`](https://github.com/pyrmont/argy-bargy)

