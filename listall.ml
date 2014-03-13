open Printf
open Packet
open Common
open ParsePGP

(* read keys from file *)
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

(* hexdump : string -> string *)
let hexdump bytes =
    let result = ref "" in
    String.iter (fun c -> result := !result ^ sprintf "%x" (int_of_char c)) bytes;
    !result

(* extract_modulus : key -> mpi *)
let extract_modulus packet =
    let cin = new Channel.string_in_channel packet.packet_body 0 in
    let version = cin#read_byte in
    match version with
        | 2 | 3 ->
            cin#skip 7;
            ParsePGP.read_mpi cin
        | 4 ->
            cin#skip 4;
            let algorithm = cin#read_byte in
            let mpi = match algorithm with
                | 18 -> {mpi_bits = 0; mpi_data = ""}
                | 19 ->
                        let length = cin#read_int_size 1 in
                        cin#skip length;
                        ParsePGP.read_mpi cin
                | _ ->  ParsePGP.read_mpi cin
            in
            mpi
        |_ -> failwith (sprintf "Unexpected pubkey version: %d" version)

(* write_key : key -> unit *)
let write_key key =
    try
        let packet_pubkey = List.hd (List.filter (fun packet -> packet.packet_type = Public_Key_Packet) key) in
        let pubkey = parse_pubkey_info packet_pubkey in
        let algo = pk_alg_to_ident pubkey.pk_alg in
        let keyid, _ = Fingerprint.keyids_from_key ~short:false key in
        let n = extract_modulus packet_pubkey in
        print_string "##########################################\n";
        List.iter print_packet key;
        printf "pub  %4d%s 0x%s\n" pubkey.pk_keylen algo (hexdump keyid);
        printf "n (%d) = 0x%s\n" n.mpi_bits (hexdump n.mpi_data)
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
    match List.tl sys_args with
    |[] -> printf "usage: ./listall <file>\n"
    |file::q ->
            printf "reading %s\n" file;
            List.iter write_key (get_keys file [])
