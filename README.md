# tarball

Download Urbit cages in a directory hierarchy as a tarball.

To download the example tarball when you have the desk running go to `[your-url]/tarball` e.g. `localhost:8080/tarball` in your browser.

(this desk also uses `/lib/bind.hoon` to get rid of `%eyre` binding boilerplate)

## Installation
1. Clone this repo.
2. Boot up a ship (fakezod or moon or whatever you use).
3. `|new-desk %tarball` to create a new desk called `%tarball`.
4. `|mount %tarball` to access the `%tarball` desk from the unix command line.
5. At the unix command line `rm -rf [ship-name]/tarball/*` to empty out the contents of the desk.
6. `cp -rL tarball/* [ship-name]/tarball` to copy the contents of this repo into your new desk.
7. At the dojo command line `|commit %tarball`.
8. Install with `|install our %tarball`.

## Overview

Basically everything important is in `/app/tarball.hoon` and `/lib/tarball.hoon`. Use the `$ball` type to organize cages into a directory structure, then use `+make-tarball` to convert it to a tarball...

```
/lib/tarball.hoon

...
+$  metadata  (map @t @t)
+$  content
  $%  [%file =metadata =cage]
      [%symlink =metadata link=@t]
  ==
+$  lump  [=metadata contents=(map @ta content)]
+$  ball  (axal lump)
...
```

I don't really expect these metadata parts to ever be used, but in principle you can add metadata to files and directories that tar parsers will recognize...

```
/app/tarball.hoon

...
++  example-ball
  ^-  ball:tarb
  =|  =ball:tarb
  ::
  =.  ball
    %+  ~(put-file bl:tarb ball)
      /'example_dir'/hello
    [~ txt+!>(~['Hello, world!'])]
  ::
  %+  ~(put-symlink bl:tarb ball)
    /'symlink_dir'/'hello.txt'
  [~ '../example_dir/hello.txt']
...
```

```
/lib/tarball.hoon

...
+$  tarball-header
  $:  name=@t
      mode=@t
      uid=@t
      gid=@t
      size=@t
      mtime=@t
      typeflag=@t
      linkname=@t
      uname=@t
      gname=@t
      devmajor=@t
      devminor=@t
      prefix=@t
  ==
::
+$  tarball-entry  [header=tarball-header data=(unit octs)]
+$  tarball        (list tarball-entry)
...
```
