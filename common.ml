(***********************************************************************)
(* Copyright (C) 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, *)
(*               2011, 2012, 2013  Yaron Minsky and Contributors       *)
(*                                                                     *)
(* This file is part of SKS.  SKS is free software; you can            *)
(* redistribute it and/or modify it under the terms of the GNU General *)
(* Public License as published by the Free Software Foundation; either *)
(* version 2 of the License, or (at your option) any later version.    *)
(*                                                                     *)
(* This program is distributed in the hope that it will be useful, but *)
(* WITHOUT ANY WARRANTY; without even the implied warranty of          *)
(* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU   *)
(* General Public License for more details.                            *)
(*                                                                     *)
(* You should have received a copy of the GNU General Public License   *)
(* along with this program; if not, write to the Free Software         *)
(* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 *)
(* USA or see <http://www.gnu.org/licenses/>.                          *)
(***********************************************************************)

(** Common services, including error reporting, logging,
  exception handling and port definitions  *)

open Printf
open StdLabels
open MoreLabels
module Unix = UnixLabels

exception Bug of string
exception Transaction_aborted of string
exception Argument_error of string
exception Unit_test_failure of string

module Map = PMap.Map
let (|<) map key = (fun data -> Map.add ~key ~data map)
let (|=) map key = Map.find key map

(** Function sequencing *)
let (|!) x f = f x

(********************************************************************)

let err_to_string err = match err with
    Unix.Unix_error (enum,fname,param) ->
      sprintf "Unix error: %s - %s(%s)"
      (Unix.error_message enum) fname param
  | e -> Printexc.to_string e

(**************************************************************************)

let plerror level format =
  kprintf (fun s ->
             if !Settings.debug && level  <= !Settings.debuglevel
             then  (
               let tm = Unix.localtime (Unix.time ()) in
               fprintf stdout "%04d-%02d-%02d %02d:%02d:%02d "
                 (tm.Unix.tm_year + 1900) (tm.Unix.tm_mon + 1)
                 tm.Unix.tm_mday (* date *)
                 tm.Unix.tm_hour tm.Unix.tm_min tm.Unix.tm_sec; (* time *)
               output_string stdout s;
               output_string stdout "\n";
               flush stdout;
             ) )
    format

(**************************************************************************)

let perror x = plerror 3 x

let eplerror level e format =
  kprintf (fun s ->
             if !Settings.debug && level  <= !Settings.debuglevel
             then  (
               let tm = Unix.localtime (Unix.time ()) in
               fprintf stdout "%04d-%02d-%02d %02d:%02d:%02d "
                 (tm.Unix.tm_year + 1900) (tm.Unix.tm_mon + 1)
                 tm.Unix.tm_mday (* date *)
                 tm.Unix.tm_hour tm.Unix.tm_min tm.Unix.tm_sec;
               output_string stdout s;
               fprintf stdout ": %s\n" (err_to_string e);
               flush stdout;
             )
          )
    format

let eperror x = eplerror 3 x

(********************************************************************)
(** Setup signals.  In particular, most of the time we want to catch and
  gracefully handle both sigint and sigterm *)

let catch_break = ref false
let handle_interrupt i =
  if !catch_break
  then raise Sys.Break


let () = Sys.set_signal Sys.sigterm (Sys.Signal_handle handle_interrupt)
let () = Sys.set_signal Sys.sigint (Sys.Signal_handle handle_interrupt)
let () = Sys.set_signal Sys.sigpipe Sys.Signal_ignore
let () = Sys.set_signal Sys.sigusr2 Sys.Signal_ignore

let set_catch_break bool =
  catch_break := bool
  (* Sys.catch_break bool; *)

let () = set_catch_break true

(********************************************************************)

let protect ~f ~finally =
  let result = ref None in
  let pfinally () =
    set_catch_break false;
    (try (finally () : unit)
     with ee ->
       set_catch_break true;
       raise ee);
    set_catch_break true;
  in
  try
    result := Some (f ());
    raise Exit
  with
      Exit as e ->
        pfinally ();
        (match !result with Some x -> x | None -> raise e)
    | e ->
        pfinally ();
        raise e

let fprotect ~f ~finally () = protect ~f ~finally

let rec filter_opts optlist = match optlist with
    [] -> []
  | (Some x)::tl -> x::(filter_opts tl)
  | None::tl -> filter_opts tl

let decomment l =
  try
    let pos = String.index l '#' in
    String.sub l ~pos:0 ~len:pos
  with
      Not_found -> l

let rec strip_opt list = match list with
    [] -> []
  | None::tl -> strip_opt tl
  | (Some hd)::tl -> hd::(strip_opt tl)

let apply_opt ~f opt = match opt with
    None -> None
  | Some x -> Some (f x)

(***************************)

type event = | Add of string
             | Delete of string

type timestamp = float
