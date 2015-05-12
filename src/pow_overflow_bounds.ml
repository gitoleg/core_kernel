(* This file was autogenerated by generate/generate_pow_overflow_bounds.exe *)

(* We have to use Int64.to_int_exn instead of int constants to make
   sure that file can be preprocessed on 32-bit machines. *)

INCLUDE "config.mlh"

IFDEF ARCH_SIXTYFOUR THEN

let overflow_bound_max_int_value : int = Int64.to_int 4611686018427387903L

let int_positive_overflow_bounds : int array =
  [|
    Int64.to_int 4611686018427387903L;
    Int64.to_int 4611686018427387903L;
    Int64.to_int 2147483647L;
    1664510;
    46340;
    5404;
    1290;
    463;
    215;
    118;
    73;
    49;
    35;
    27;
    21;
    17;
    14;
    12;
    10;
    9;
    8;
    7;
    7;
    6;
    5;
    5;
    5;
    4;
    4;
    4;
    4;
    3;
    3;
    3;
    3;
    3;
    3;
    3;
    3;
    3;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    1;
    1;
  |]

ELSE

let overflow_bound_max_int_value : int = 1073741823

let int_positive_overflow_bounds : int array =
  [|
    1073741823;
    1073741823;
    32767;
    1023;
    181;
    63;
    31;
    19;
    13;
    10;
    7;
    6;
    5;
    4;
    4;
    3;
    3;
    3;
    3;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    2;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
  |]

END

let overflow_bound_max_int64_value : int64 = 9223372036854775807L

let int64_positive_overflow_bounds : int64 array =
  [|
    9223372036854775807L;
    9223372036854775807L;
    3037000499L;
    2097151L;
    55108L;
    6208L;
    1448L;
    511L;
    234L;
    127L;
    78L;
    52L;
    38L;
    28L;
    22L;
    18L;
    15L;
    13L;
    11L;
    9L;
    8L;
    7L;
    7L;
    6L;
    6L;
    5L;
    5L;
    5L;
    4L;
    4L;
    4L;
    4L;
    3L;
    3L;
    3L;
    3L;
    3L;
    3L;
    3L;
    3L;
    2L;
    2L;
    2L;
    2L;
    2L;
    2L;
    2L;
    2L;
    2L;
    2L;
    2L;
    2L;
    2L;
    2L;
    2L;
    2L;
    2L;
    2L;
    2L;
    2L;
    2L;
    2L;
    2L;
    1L;
  |]

let int64_negative_overflow_bounds : int64 array =
  [|
    -9223372036854775807L;
    -9223372036854775807L;
    -3037000499L;
    -2097151L;
    -55108L;
    -6208L;
    -1448L;
    -511L;
    -234L;
    -127L;
    -78L;
    -52L;
    -38L;
    -28L;
    -22L;
    -18L;
    -15L;
    -13L;
    -11L;
    -9L;
    -8L;
    -7L;
    -7L;
    -6L;
    -6L;
    -5L;
    -5L;
    -5L;
    -4L;
    -4L;
    -4L;
    -4L;
    -3L;
    -3L;
    -3L;
    -3L;
    -3L;
    -3L;
    -3L;
    -3L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -2L;
    -1L;
  |]
