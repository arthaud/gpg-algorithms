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
        if pubkey.pk_alg = 1 || pubkey.pk_alg = 2 || pubkey.pk_alg = 3 then (* RSA *)
        (
            let keyid, _ = Fingerprint.keyids_from_key ~short:false key in
            let n = parse_modulus packet_pubkey in
            printf "%s %s\n" (String.uppercase (hexdump keyid)) (String.uppercase (hexdump n.mpi_data))
        )
    with
        |Overlong_mpi -> eprintf "warning: error when parsing a GPG key, ignored\n"

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
        printf "usage: ./exportrsa [-h] FILE...\n\n";
        printf "Dump the GPG RSA keys contained in the given .pgp files\n"
    )
    else
        let files = List.tl sys_args in
        List.iter (fun file -> List.iter write_key (Keydump.get_keys file [])) files
