GPG-algorithms
==============

**GPG-algorithms** is a repository for tools working on all GPG keys.
**GPG-algorithms** is based on [sks-keyserver](https://bitbucket.org/skskeyserver/sks-keyserver/)

For now :
* *listall* can display all GPG keys

Build
-----

To build the project, you need **ocaml** and **cryptokit**.

On Archlinux, simply run `yaourt ocaml-cryptokit`

After, you just have to run `make dep` and then `make all`

You may need to update `COMMONCAMLFLAGS` in the Makefile to set the path for cryptokit.

Fetch all GPG keys
------------------

To run on all GPG keys, you need a **keydump**.

These keydumps are available on some key servers, and are updated about each week.
The complete keydump is around 4GB large.

Quoting [sks-keyserver wiki](https://bitbucket.org/skskeyserver/sks-keyserver/wiki/KeydumpSources) :

>  * http://key-server.org/dump  generated every Friday
>   ** {{{ftp://key-server.org/dump}}}   (for anonymous FTP)
>  * http://keys.niif.hu/keydump/  generated every Monday
>   ** http://keydumps.trickhieber.de/  mirrored from keys.niif.hu
>  * http://keyserver.borgnet.us/dump/  generated every Sunday
>  * http://ftp.prato.linux.it/pub/keyring/dump-latest/  generated every Wednesday
>   ** {{{ftp://ftp.prato.linux.it/pub/keyring/}}}   (for anonymous FTP)
>  * http://keyserver.secretresearchfacility.com/dump/ generated every Thursday (EU morning)
>   ** {{{ftp://keyserver.secretresearchfacility.com/dump/}}} (only IPv4; for anonymous FTP)
>   ** {{{rsync://keyserver.secretresearchfacility.com/dump/}}}
>  * http://pgp.jjim.de/sksdump/  (v4/v6) every Friday (~01:30 UTC), loc. Duessseldorf DE, 1.5MiB/s per con. parallel download allowed
>   ** https://pgp.jjim.de/sksdump/ (self signed SSL available, same rules apply)

TODO
----

* *fetchall* to automatically fetch a keydump
* *pgcd* to try to factor some GPG keys
* *graph* to generate a graph of all of the signature relationships in GPG
