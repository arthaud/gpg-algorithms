(***********************************************************************)
(* keydump.ml - Keydump related operations                             *)
(***********************************************************************)

open Common

(*************************************************************)

let rec get_keys_rec nextkey partial =
    match nextkey () with 
        | Some key ->
            (try
                let ckey = Fixkey.canonicalize key in
                get_keys_rec nextkey (ckey::partial)
            with 
                Fixkey.Bad_key -> get_keys_rec nextkey partial
            )
        | None -> partial

let get_keys filename start =
    let cin = new Channel.sys_in_channel (open_in filename) in
    protect
    ~f:(fun () ->
        let nextkey = Key.next_of_channel cin in
        get_keys_rec nextkey start
    )
    ~finally:(fun () -> cin#close)
