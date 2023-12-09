/+  server, bind, verb, dbug, default-agent
|%
+$  state-0  [%0 ~]
+$  versioned-state
  $%  state-0
  ==
+$  card        card:agent:gall
++  agent-bind  (agent:bind & ~[[`/tarball &]])
::
++  tarb
  |%
  +$  calp   ?(%'A' %'B' %'C' %'D' %'E' %'F' %'G' %'H' %'I' %'J' %'K' %'L' %'M' %'N' %'O' %'P' %'Q' %'R' %'S' %'T' %'U' %'V' %'W' %'X' %'Y' %'Z')
  +$  octal  (list ?(%'0' %'1' %'2' %'3' %'4' %'5' %'6' %'7'))
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
  ::
  +$  tarball-header
    $:  name=@t
        mode=octal
        uid=octal
        gid=octal
        size=octal
        mtime=octal
        =typeflag
        linkname=@t
        uname=@t
        gname=@t
        devmajor=octal
        devminor=octal
        prefix=@t
    ==
  ::
  +$  tarball-entry  [header=tarball-header data=(unit octs)]
  +$  tarball        (list tarball-entry)
  ::
  ++  validate-header
    |=  header=tarball-header
    ^-  tarball-header
    :: !!
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

  :: REMEMBER: Urbit refuses to pad with leading zeros
  :: cats left to right accounting for unpadded leading zeros
  ::
  ++  octs-cat
    |=  [a=octs b=octs]
    ^-  octs
    =/  z=@  (sub p.b (met 3 q.b)) :: leading zeros for b
    :-  (add p.a p.b)
    (cat 3 q.b (lsh [3 z] q.a))
  :: raps left to right
  ::
  ++  octs-rap
    |=  =(list octs)
    ^-  octs
    ?:  ?=(?(~ [octs ~]) list)
      !!
    ?:  ?=([octs octs ~] list)
      (octs-cat i.list i.t.list)
    %+  octs-cat  i.list
    $(list t.list)
  :: sub-decimal base
  ::
  ++  sud-base
    |=  [a=@u b=@u]
    ?>  &((gth b 0) (lte b 10))
    ?:  =(0 a)  '0'
    %-  crip
    %-  flop
    |-  ^-  tape
    ?:(=(0 a) ~ [(add '0' (mod a b)) $(a (div a b))])
  ::
  ++  numb    (curr sud-base 10)
  ++  ud-oct  (curr sud-base 8)
  ::
  ++  pack  |=([f=@t l=@] `octs`l^(lsh [3 (sub l (met 3 f))] (swp 3 f)))
  ::
  ++  encode-header
    |=  header=tarball-header
    ^-  octs
    =.  header  (validate-header header)
    =;  data=@
      :: front-pad with zeros if < 512
      ?>  (lte (met 3 data) 512)
      [512 data]
    =/  data=@
      =;  fields
        q:(octs-rap (turn fields pack))
      :~  [name.header 100]
          [(crip mode.header) 8]
          [(crip uid.header) 8]
          [(crip gid.header) 8]
          [(crip size.header) 12]
          [(crip mtime.header) 12]
          ['        ' 8] :: checksum placeholder
          [typeflag.header 1]
          [linkname.header 100]
          ['ustar' 6]    :: hardcoded ustar field
          ['00' 2]       :: hardcoded [ustar] version field
          [uname.header 32]
          [gname.header 32]
          [(crip devmajor.header) 8]
          [(crip devminor.header) 8]
          [prefix.header 155]
          ['' 12] :: padding
      ==
    :: calculate and insert the correct checksum
    ::
    =/  checksum  (ud-oct (sum data))
    =/  beg=@  (rsh [3 (sub 512 148)] data) :: grab beginning
    =/  end=@  (end [3 (sub 512 156)] data) :: grab end
    =.  data  (cat 3 (swp 3 checksum) beg)  :: add checksum after beginning
    =.  data  (lsh [3 (sub 8 (met 3 checksum))] data) :: pad to 8 bytes
    (cat 3 end data) :: add end after beginning and padded checksum
  --
:: REMEMBER: Urbit refuses to pad with leading zeros
::
:: sub-decimal base
::
++  sud-base
  |=  [a=@u b=@u]
  ?>  &((gth b 0) (lte b 10))
  ?:  =(0 a)  '0'
  %-  crip
  %-  flop
  |-  ^-  tape
  ?:(=(0 a) ~ [(add '0' (mod a b)) $(a (div a b))])
::
++  numb   (curr sud-base 10)
++  octal  (curr sud-base 8)
::
++  pack
  |=  =(list [@t @])
  ^-  @
  %+  roll  list
  |=  [[fel=@t len=@] acc=@]
  =.  acc  (cat 3 (swp 3 fel) acc)
  (lsh [3 (sub len (met 3 fel))] acc)
::
++  sum  |=(@ (roll (rip 3 +<) add))
:: Create a tar header for a file or directory.
::   $name: Name of the file or directory.
::   $size: Size of the file. Should be 0 for directories.
::   $is-dir: %.y if creating a header for a directory, %.n for a file.
::
++  create-tar-header
  |=  [name=@t size=@ is-dir=?]
  ^-  @
  =-  q.-
  %-  encode-header:tarb
  ;;  tarball-header:tarb
  :*  name
      mode=?:(is-dir "0755" "0644")
      uid="0000000"
      gid="0000000"
      size=(trip (octal size))
      mtime=(trip (octal (unt:chrono:userlib ~2000.1.1)))
      typeflag=?:(is-dir '5' '0')
      linkname=''
      uname='root'
      gname='root'
      devmajor=""
      devminor=""
      prefix=''
  ==
::
++  create-tar-header-original
  |=  [name=@t size=@ is-dir=?]
  ^-  @
  :: Tar header fields
  ::
  =/  mode=@t      ?:(is-dir '0755' '0644')
  =/  uid=@t       '0000000'
  =/  gid=@t       '0000000'
  =/  mtime=@t     (octal (unt:chrono:userlib ~2000.1.1))
  =/  checksum=@t  '        ' :: checksum placeholder
  =/  typeflag=@t  ?:(is-dir '5' '0')
  =/  linkname=@t  ''
  =/  ustar=@t     ''
  =/  version=@t   ''
  =/  uname=@t     'root'
  =/  gname=@t     'root'
  =/  devmajor=@t  ''
  =/  devminor=@t  ''
  =/  prefix=@t    ''
  =/  header
    %-  pack
    :~  [name 100]
        [mode 8]
        [uid 8]
        [gid 8]
        [(octal size) 12]
        [mtime 12]
        [checksum 8]
        [typeflag 1]
        [linkname 100]
        [ustar 6]
        [version 2]
        [uname 32]
        [gname 32]
        [devmajor 8]
        [devminor 8]
        [prefix 155]
        ['' 12] :: padding
    ==
  :: calculate and insert the correct checksum
  ::
  =.  checksum  (octal (sum header))
  =/  beg=@  (rsh [3 (sub 512 148)] header) :: grab beginning
  =/  end=@  (end [3 (sub 512 156)] header) :: grab end
  =.  header  (cat 3 (swp 3 checksum) beg)  :: add checksum after beginning
  =.  header  (lsh [3 (sub 8 (met 3 checksum))] header) :: pad to 8 bytes
  (cat 3 end header) :: add end after beginning and padded checksum
::
++  create-tarball
  ^-  octs
  =;  tar=@
    [(met 3 tar) (swp 3 tar)]
  =/  dir-name=@t      'example_dir/'
  =/  file-name=@t     (cat 3 dir-name 'hello.txt')
  =/  file-content=@t  'Hello, world!'
  =/  file-size=@      (met 3 file-content)
  ^-  @
  =/  tarball=@  (create-tar-header dir-name 0 &)
  =.  tarball    (cat 3 (create-tar-header file-name file-size |) tarball)
  :: TODO: Be careful here that leading zeros don't get erased
  ::
  =.  tarball    (cat 3 (swp 3 file-content) tarball)
  :: Pad the end of file contents to 512 bytes
  ::
  =.  tarball    (lsh [3 (sub 512 (mod file-size 512))] tarball)
  :: two null blocks signify end of archive
  ::
  (lsh [3 1.024] tarball)
--
::
=|  state-0
=*  state  -
::
%+  verb  |
%-  agent-bind
%-  agent:dbug
^-  agent:gall
|_  =bowl:gall
+*  this    .
    def   ~(. (default-agent this %.n) bowl)
::
++  on-init   `this
++  on-save   !>(state)
::
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  =+  !<(old=state-0 ole)
  =.  state  old
  `this
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  =(src our):bowl
  ?+    mark  (on-poke:def mark vase)
      %handle-http-request
    =+  !<([eyre-id=@ta req=inbound-request:eyre] vase)
    ?+    method.request.req   (on-poke:def mark vase)
        %'GET'
      =/  data=octs  create-tarball
      =/  content-length=@t  (crip ((d-co:co 1) p.data))
      =/  =response-header:http
        :-  200
        :~  ['Content-Length' content-length]
            ['Content-Type' 'application/x-tar']
        ==
      :_(this (give-simple-payload:app:server eyre-id response-header `data))
    ==
  ==
::
++  on-peek   on-peek:def
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
