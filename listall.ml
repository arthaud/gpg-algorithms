open Printf
open Packet
open Common
open ParsePGP

(* hexdump : string -> string *)
let hexdump bytes =
    let result = ref "" in
    String.iter (fun c -> result := !result ^ sprintf "%02x" (int_of_char c)) bytes;
    !result

(* write_key : key -> unit *)
let write_key key =
    try
        let packet_pubkey = List.hd (List.filter (fun packet -> packet.packet_type = Public_Key_Packet) key) in
        let pubkey = parse_pubkey_info packet_pubkey in
        let algo = pk_alg_to_ident pubkey.pk_alg in
        let keyid, _ = Fingerprint.keyids_from_key ~short:false key in
        let uids = List.filter (fun packet -> packet.packet_type = User_ID_Packet) key in
        printf "pub   %4d%s/%s\n" pubkey.pk_keylen algo (String.uppercase (hexdump keyid));
        List.iter (fun packet -> printf "uid         %s\n" packet.packet_body) uids;
    with
        |Overlong_mpi -> printf "Error: exception Overlong_mpi\n"

(* sys_args : string list *)
let sys_args =
    let args = ref [] in
    for i = 0 to Array.length Sys.argv - 1 do
        args := Sys.argv.(i)::(!args)
    done;
    List.rev !args

let _ =
    if List.length sys_args < 2 || (List.length sys_args = 2 && (Sys.argv.(1) = "-h" || Sys.argv.(1) = "--help")) then
    (
        printf "usage: ./listall [-h] FILE...\n\n";
        printf "List the GPG keys contained in the given .gpg files.\n"
    )
    else
    (
        let files = List.tl sys_args in
        List.iter (fun file -> List.iter write_key (Keydump.get_keys file [])) files
    )
