exception Bug of string
exception Transaction_aborted of string
exception Argument_error of string
exception Unit_test_failure of string
val ( |< ) : ('a, 'b) PMap.Map.t -> 'a -> 'b -> ('a, 'b) PMap.Map.t
val ( |= ) : ('a, 'b) PMap.Map.t -> 'a -> 'b
val ( |! ) : 'a -> ('a -> 'b) -> 'b
val err_to_string : exn -> string
val plerror : int -> ('a, unit, string, unit) format4 -> 'a
val perror : ('a, unit, string, unit) format4 -> 'a
val eplerror : int -> exn -> ('a, unit, string, unit) format4 -> 'a
val eperror : exn -> ('a, unit, string, unit) format4 -> 'a
val catch_break : bool ref
val handle_interrupt : 'a -> unit
val set_catch_break : bool -> unit
val protect : f:(unit -> 'a) -> finally:(unit -> unit) -> 'a
val fprotect : f:(unit -> 'a) -> finally:(unit -> unit) -> unit -> 'a
val filter_opts : 'a option list -> 'a list
val decomment : string -> string
val strip_opt : 'a option list -> 'a list
val apply_opt : f:('a -> 'b) -> 'a option -> 'b option
type event = Add of string | Delete of string
type timestamp = float
