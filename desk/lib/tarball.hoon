|%
+$  calp   ?(%'A' %'B' %'C' %'D' %'E' %'F' %'G' %'H' %'I' %'J' %'K' %'L' %'M' %'N' %'O' %'P' %'Q' %'R' %'S' %'T' %'U' %'V' %'W' %'X' %'Y' %'Z')
+$  octal  (list ?(%'0' %'1' %'2' %'3' %'4' %'5' %'6' %'7'))
::
+$  typeflag
  $?  %'0'  %'' :: Regular file. (The null character '\0' is for backward compatibility with older tar formats where the typeflag was not used.)
      %'1'      :: Hard link. The entry should be linked to another entry in the archive, which is identified by the linkname.
      %'2'      :: Symbolic link. The entry is a symbolic link, pointing to another file. The linkname field contains the target of the link.
      %'3'      :: Character special. The entry is a character device. Device major and minor numbers are specified in the devmajor and devminor fields.
      %'4'      :: Block special. The entry is a block device.
      %'5'      :: Directory. The entry is a directory.
      %'6'      :: FIFO (named pipe). The entry is a FIFO special file.
      %'7'      :: Contiguous file. This is rarely used and typically treated as a regular file.
      %'g'      :: Global extended header. Used for metadata that applies to all subsequent entries in the archive.
      %'x'      :: Extended header. Used for metadata that applies to the following entry in the archive.
      calp :: A-Z: Vendor-specific extensions. These are reserved for custom usage by vendors.
  ==
:: 'g': Global Extended Header
::
:: 1. Purpose: The Global Extended Header is used to store metadata
::    that applies to all subsequent entries in the tar archive. This is
::    useful for defining attributes or properties that are common to all
::    files and directories in the archive.
::
:: 2. Usage: In an archive, a 'g' typeflag entry contains key-value
::    pairs of metadata. These pairs provide additional information that is
::    not part of the standard tar header, such as extended file
::    attributes, ACLs (Access Control Lists), or other user-defined
::    metadata.
::
:: 3. Format: The entry with a 'g' typeflag typically consists of a
::    series of newline-separated key-value pairs, followed by an empty
::    line. Each key-value pair is in the format key=value\n.
::
:: 4. Scope: The metadata defined in a Global Extended Header applies to
::    all files and directories archived after this header, up to either
::    the end of the archive or the next Global Extended Header.
::
:: 'x': Extended Header
:: 
:: 1. Purpose: The Extended Header is similar to the Global Extended Header but
::    is used for metadata that applies only to the following entry in the tar
::    archive.
:: 
:: 2. Usage: This is used to provide additional metadata for a specific file or
::    directory, such as file comments, longer path names, or any other
::    metadata that exceeds the limits of the standard USTAR header fields.
:: 
:: 3. Format: Like the Global Extended Header, the 'x' typeflag entry is
::    formatted as newline-separated key-value pairs, indicating the extended
::    metadata for the subsequent file or directory.
:: 
:: 4. Scope: The metadata in an Extended Header only applies to the next file
::    or directory that immediately follows this header in the archive.
::
+$  tarball-header
  $:  name=@t     :: file or directory name
      mode=@t     :: octal - permissions as octal (e.g. 0755)
      uid=@t      :: octal - user id
      gid=@t      :: octal - group id
      size=@t     :: octal - size of file or directory
      mtime=@t    :: octal - time at which last modified
      typeflag=@t :: type of file, directory, etc.
      linkname=@t :: linkname for symlink and hardlink
      uname=@t    :: user name
      gname=@t    :: group name
      devmajor=@t :: octal - for devices
      devminor=@t :: octal - for devices
      prefix=@t   :: name prefix; allows for longer names
  ==
::
+$  tarball-entry  [header=tarball-header data=(unit octs)]
+$  tarball        (list tarball-entry)
:: sub-decimal base
::
++  sud-base
  |=  [a=@u b=@u]
  ^-  @t
  ?>  &((gth b 0) (lte b 10))
  ?:  =(0 a)  '0'
  %-  crip
  %-  flop
  |-  ^-  tape
  ?:(=(0 a) ~ [(add '0' (mod a b)) $(a (div a b))])
::
++  numb      (curr sud-base 10)
++  ud-oct    (curr sud-base 8)
++  da-oct    |=(=@da (ud-oct (unt:chrono:userlib da)))
::
++  validate-header
  |=  tarball-header
  ^-  tarball-header
  =*  header  +<
  :: assert length limits
  ::
  ?>  ?&  (lte (met 3 name) 100)
          (lte (met 3 mode) 8)
          (lte (met 3 uid) 8)
          (lte (met 3 gid) 8)
          (lte (met 3 size) 8)
          (lte (met 3 mtime) 12)
          (lte (met 3 typeflag) 1)
          (lte (met 3 linkname) 100)
          (lte (met 3 uname) 32)
          (lte (met 3 gname) 32)
          (lte (met 3 devmajor) 8)
          (lte (met 3 devminor) 8)
          (lte (met 3 prefix) 155)
      ==
  :: assert correct octal values
  ::
  =:  mode      (crip ;;(octal (trip mode)))
      uid       (crip ;;(octal (trip uid)))
      gid       (crip ;;(octal (trip gid)))
      size      (crip ;;(octal (trip size)))
      mtime     (crip ;;(octal (trip mtime)))
      devmajor  (crip ;;(octal (trip devmajor)))
      devminor  (crip ;;(octal (trip devminor)))
    ==
  :: assert correct typeflag
  ::
  =.  typeflag  ;;(^typeflag typeflag)
  header
::
++  validate-entry
  |=  entry=tarball-entry
  ^-  tarball-entry
  =/  header  (validate-header header.entry)
  ?~  data.entry
    entry
  ?>  =(0 (mod p.u.data.entry 512))
  entry
::
++  common-mode
  |=  typeflag=@t
  ^-  @t
  ?+  typeflag   '0000'
    ?(%'0' %'')  '0644'
    %'2'         '0777'
    %'5'         '0755'
    %'6'         '0644'
  ==
:: REMEMBER: Urbit refuses to pad with leading zeros
:: cats left to right accounting for unpadded leading zeros
::
++  octs-cat
  |=  [a=octs b=octs]
  ^-  octs
  :: assumes valid octs with (lte (met 3 q.octs) p.octs)
  =/  z=@  (sub p.a (met 3 q.a)) :: leading zeros for a
  :-  (add p.a p.b)
  (cat 3 q.a (lsh [3 z] q.b))
:: raps left to right
::
++  octs-rap
  |=  =(list octs)
  ^-  octs
  ?<  ?=(?(~ [octs ~]) list)
  ?:  ?=([octs octs ~] list)
    (octs-cat i.list i.t.list)
  %+  octs-cat  i.list
  $(list t.list)
::
++  pack  |=([f=@t l=@] `octs`?>((lte (met 3 f) l) l^f))
++  sum   |=(@ (roll (rip 3 +<) add))
::
++  encode-header
  =|  checksum=(unit @t)
  |=  header=tarball-header
  ^-  octs
  =.  header  (validate-header header)
  =/  fields
    :~  [name.header 100]
        [mode.header 8]
        [uid.header 8]
        [gid.header 8]
        [size.header 12]
        [mtime.header 12]
        [?^(checksum u.checksum '        ') 8]
        [typeflag.header 1]
        [linkname.header 100]
        ['ustar' 6]    :: hardcoded ustar field
        ['00' 2]       :: hardcoded [ustar] version field
        [uname.header 32]
        [gname.header 32]
        [devmajor.header 8]
        [devminor.header 8]
        [prefix.header 155]
        ['' 12] :: padding
    ==
  =/  data=octs  (octs-rap (turn fields pack))
  ?>  =(512 p.data)
  ?^  checksum
    data
  $(checksum `(ud-oct (sum q.data)))
::
++  encode-tarball
  =|  =octs
  |=  tar=tarball
  ?~  tar
    octs(p (add 1.024 p.octs)) :: add two null blocks
  =/  head  (encode-header header.i.tar)
  =/  data  ?~(data.i.tar 0^0 u.data.i.tar)
  $(tar t.tar, octs (octs-rap octs head data ~))
:: Intermediate states
::
+$  metadata  (map @t @t)
+$  content
  $%  [%file =metadata =cage]
      [%symlink =metadata link=@t]
  ==
+$  lump  [=metadata contents=(map @ta content)]
+$  ball  (axal lump) :: can add mtime and mode as metadata
::
++  bl
  |_  =ball
  ++  put-file
    |=  [=path =metadata =cage]
    =/  lump=(unit lump)
      (~(get of ball) (snip path))
    =?  lump  ?=(~ lump)
      `[~ ~]
    ?>  ?=(^ lump)
    =.  contents.u.lump
      %+  ~(put by contents.u.lump)
        (rear path)
      [%file metadata cage]
    (~(put of ball) (snip path) (need lump))
  ::
  ++  put-files
    |=  args=(list [=path =metadata =cage])
    ?~  args
      ball
    %=  $
      args  t.args
      ball  (put-file i.args)
    ==
  ::
  ++  put-symlink
    |=  [=path =metadata link=@t]
    =/  lump=(unit lump)
      (~(get of ball) (snip path))
    =?  lump  ?=(~ lump)
      `[~ ~]
    ?>  ?=(^ lump)
    =.  contents.u.lump
      %+  ~(put by contents.u.lump)
        (rear path)
      [%symlink metadata link]
    (~(put of ball) (snip path) (need lump))
  ::
  ++  put-symlinks
    |=  args=(list [=path =metadata link=@t])
    ?~  args
      ball
    %=  $
      args  t.args
      ball  (put-symlink i.args)
    ==
  ::
  ++  del-content
    |=  =path
    =/  lump=(unit lump)
      (~(get of ball) (snip path))
    =?  lump  ?=(~ lump)
      `[~ ~]
    ?>  ?=(^ lump)
    =.  contents.u.lump
      (~(del by contents.u.lump) (rear path))
    (~(put of ball) (snip path) (need lump))
  ::
  ++  del-contents
    |=  args=(list path)
    ?~  args
      ball
    %=  $
      args  t.args
      ball  (del-content i.args)
    ==
  ::
  ++  get-content
    |=  =path
    =/  lump=(unit lump)
      (~(get of ball) (snip path))
    =?  lump  ?=(~ lump)
      `[~ ~]
    ?>  ?=(^ lump)
    (~(get by contents.u.lump) (rear path))
  --
++  gen
  |_  =bowl:gall
  ++  generate-header
    |=  fields=(map @t @t)
    ^-  tarball-header
    =|  header=tarball-header
    ::
    =.  name.header       (~(got by fields) 'name')
    =.  typeflag.header   (~(got by fields) 'typeflag')
    ::
    =.  mode.header       (~(gut by fields) 'mode' (common-mode typeflag.header))
    =.  uid.header        (~(gut by fields) 'uid' '0000000')
    =.  gid.header        (~(gut by fields) 'gid' '0000000')
    =.  size.header       (~(gut by fields) 'size' '0')
    =.  mtime.header      (~(gut by fields) 'mtime' (da-oct now.bowl))
    =.  linkname.header   (~(gut by fields) 'linkname' '')
    =.  uname.header      (~(gut by fields) 'uname' 'root')
    =.  gname.header      (~(gut by fields) 'gname' 'root')
    =.  devmajor.header   (~(gut by fields) 'devmajor' '')
    =.  devminor.header   (~(gut by fields) 'devminor' '')
    =.  prefix.header     (~(gut by fields) 'prefix' '')
    header
  ::
  ++  generate-entry
    |=  [fields=(map @t @t) data=(unit octs)]
    ^-  tarball-entry
    =/  tf=@t  (~(got by fields) 'typeflag')
    ~?  >>>  &(?=(^ data) ?=(?(%'1' %'2' %'3' %'4' %'5' %'6') tf))
      `@t`(cat 3 'tarball: unexpected data for header with typeflag ' tf)
    ~?  >>  (~(has by fields) 'size')  'tarball: ignoring size field'
    =.  fields
      %+  ~(put by fields)
        'size'
      (ud-oct ?~(data 0 p.u.data))
    %-  validate-entry
    :-  (generate-header fields)
    ?~  data
      ~
    :: pad to multiple of 512
    `u.data(p (add p.u.data (sub 512 (mod p.u.data 512))))
  ::
  ++  make-directory-entry
    |=  [=path =metadata]
    ^-  tarball-entry
    =/  [prefix=^path name=^path]  (split-path path)
    =.  metadata
      %-  ~(gas by metadata)
      :~  ['typeflag' '5']
          ['prefix' (rsh [3 1] (spat prefix))]
          ['name' (cat 3 (rsh [3 1] (spat name)) '/')]
      ==
    (generate-entry metadata ~)
  ::
  ++  make-content-entry
    |=  [=path =content]
    ^-  tarball-entry
    =/  [prefix=^path name=^path]  (split-path path)
    ?-    -.content
        %symlink
      =.  metadata.content
        %-  ~(gas by metadata.content)
        :~  ['typeflag' '2']
            ['prefix' (rsh [3 1] (spat prefix))]
            ['name' (rsh [3 1] (spat name))]
            ['linkname' link.content]
        ==
      (generate-entry metadata.content ~)
      ::
        %file
      =/  =tube:clay  (get-tube p.cage.content %mime)
      :: get extension
      ::
      =/  ext=(unit mark)  p:(rash (spat path) apat:de-purl:html)
      :: assert extension corresponds to mark
      ::
      ?>  ?~(ext & =(u.ext p.cage.content))
      =+  !<(=mime (tube q.cage.content))
      =.  metadata.content
        %-  ~(gas by metadata.content)
        :~  ['typeflag' '0']
            ['prefix' (rsh [3 1] (spat prefix))]
            ['name' (rap 3 (rsh [3 1] (spat name)) ?^(ext ~ ['.' p.cage.content ~]))]
        ==
      (generate-entry metadata.content `q.mime)
    ==
  ::
  ++  make-tarball
    |=  [=path =ball]
    ^-  tarball
    :: Add directory entry and subfiles entries.
    ::
    =/  tarball
      ?~  fil.ball
        ~
      :: TODO: consider metadata tar headers....
      %+  weld
        ?~  path
          ~
        [(make-directory-entry path metadata.u.fil.ball) ~]
      %+  turn  ~(tap by contents.u.fil.ball)
      |=  [name=@ta =content]
      (make-content-entry (snoc path name) content)
    =/  directories  ~(tap by dir.ball)
    :: Recurse over sub-directories
    ::
    |-
    ?~  directories
      tarball
    =/  [name=@ta sub-ball=^ball]  i.directories
    =/  sub-tarball=^tarball
      (make-tarball (snoc path name) sub-ball)
    %=  $
      directories  t.directories
      tarball      (weld tarball sub-tarball)
    ==
  ::
  ++  get-tube
    |=  [from=mark to=mark]
  .^(tube:clay %cc /(scot %p our.bowl)/[q.byk.bowl]/(scot %da now.bowl)/[from]/[to])
  :: make use of as much of the prefix field as possible
  ::
  ++  split-path
    |=  =path
    ^-  [prefix=^path name=^path]
    =/  p=^path  (flop path)
    =|  n=^path
    |-
    ?>  ?=(^ p) :: p should never be empty here
    ?:  (lte (sub (lent (spud p)) 1) 155) :: sub 1 for leading /
      ?~  n
        [(flop t.p) [i.p ~]] :: need some content for name
      [(flop p) n]
    $(p t.p, n [i.p n])
  --
--
