/+  tarb=tarball, server, bind, verb, dbug, default-agent
|%
+$  state-0  [%0 ~]
+$  versioned-state
  $%  state-0
  ==
+$  card        card:agent:gall
++  agent-bind  (agent:bind & ~[[`/tarball &]])
::
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
+*  this  .
    def   ~(. (default-agent this %.n) bowl)
    targ  ~(. gen:tarb bowl)
    hc    ~(. +> bowl)
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
    :: exposes ext, site and args
    ::
    =+  (parse-request-line:server url.request.req)
    :: thinking of exposing other endpoints...
    ::
    ?+    [site ext]  (on-poke:def mark vase)
        [[%tarball *] *]
      ?+    method.request.req   (on-poke:def mark vase)
          %'GET'
        =/  =tarball:tarb      (make-tarball:targ / example-ball)
        =/  data=octs          (encode-tarball:tarb tarball)
        =/  content-length=@t  (crip ((d-co:co 1) p.data))
        =/  =response-header:http
          :-  200
          :~  ['Content-Length' content-length]
              ['Content-Type' 'application/x-tar']
          ==
        :_(this (give-simple-payload:app:server eyre-id response-header `data))
      ==
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
