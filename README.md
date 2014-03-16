GPG-algorithms
==============

**GPG-algorithms** is a repository for tools working on all GPG keys.
**GPG-algorithms** is based on [sks-keyserver](https://bitbucket.org/skskeyserver/sks-keyserver/)

For now :
* *listall* can display all GPG keys
* *gcd* can compute the gcd of each pair of GPG keys, see below

Build
-----

To build the project, you need **ocaml**, **cryptokit** and **gmp**.

On Archlinux, simply run `yaourt -S ocaml gmp ocaml-cryptokit`

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

You can use `fetchall` to easily fetch a keydump.

GCD
---

When you have a flaw in a random number generator and that you are generating RSA keys,
it is possible that you choose twice the same *p*. That makes your keys vulnerable, because
someone could compute the gcd of each pair of keys and find this *p*, and so break our keys.

The idea here is to compute the gcd of each pair of RSA keys.

First, make a dump of all RSA keys by running `./exportrsa *.pgp > dump_rsa`
Then, run `./gcd dump_rsa`

TODO
----

* *graph* to generate a graph of all of the signature relationships in GPG
