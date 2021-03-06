(** This module defines interfaces used in [Core.Std.Set].  This module uses the same
    organizational approach as [Core_map_intf].  See the documentation in core_map.mli for
    a description of the approach.

    This module defines module types
    [{Creators,Accessors}{0,1,2,_generic,_with_comparator}].  It uses check functors to
    ensure that each module types is an instance of the corresponding [_generic] one.

    We must treat [Creators] and [Accessors] separately, because we sometimes need to
    choose different instantiations of their [options].  In particular, [Set] itself
    matches [Creators2_with_comparator] but [Accessors2] (without comparator).
*)
(*
    CRs and comments about [Set] functions do not belong in this file.  They belong next
    to the appropriate function in core_set.mli.
*)

open T

module Binable = Binable0

module type Elt = sig
  type t [@@deriving compare, sexp]
end

module type Elt_binable = sig
  type t [@@deriving bin_io, compare, sexp]
end

module Without_comparator = Core_map_intf.Without_comparator
module With_comparator    = Core_map_intf.With_comparator

module Map = Core_map

module Continue_or_stop          = Container_intf.Continue_or_stop
module Finished_or_stopped_early = Container_intf.Finished_or_stopped_early

module Merge_to_sequence_element = Sequence.Merge_with_duplicates_element

module type Accessors_generic = sig

  include Container.Generic_phantom

  type ('a, 'cmp) tree

  (** The [options] type is used to make [Accessors_generic] flexible as to whether a
      comparator is required to be passed to certain functions. *)
  type ('a, 'cmp, 'z) options

  type 'cmp cmp

  val invariants
    : ('a, 'cmp,
       ('a, 'cmp) t -> bool
    ) options

  (** override [Container]'s [mem] *)
  val mem : ('a, 'cmp, ('a, 'cmp) t -> 'a elt -> bool) options
  val add
    : ('a, 'cmp,
       ('a, 'cmp) t -> 'a elt -> ('a, 'cmp) t
    ) options
  val remove
    : ('a, 'cmp,
       ('a, 'cmp) t -> 'a elt -> ('a, 'cmp) t
    ) options
  val union
    : ('a, 'cmp,
       ('a, 'cmp) t -> ('a, 'cmp) t -> ('a, 'cmp) t
    ) options
  val inter
    : ('a, 'cmp,
       ('a, 'cmp) t -> ('a, 'cmp) t -> ('a, 'cmp) t
    ) options
  val diff
    : ('a, 'cmp,
       ('a, 'cmp) t -> ('a, 'cmp) t -> ('a, 'cmp) t
    ) options
  val symmetric_diff
    : ('a, 'cmp,
       ('a, 'cmp) t -> ('a, 'cmp) t
       -> ('a elt, 'a elt) Either.t Sequence.t
      ) options
  val compare_direct
    : ('a, 'cmp,
       ('a, 'cmp) t -> ('a, 'cmp) t -> int
    ) options
  val equal
    : ('a, 'cmp,
       ('a, 'cmp) t -> ('a, 'cmp) t -> bool
    ) options
  val subset
    : ('a, 'cmp,
       ('a, 'cmp) t -> ('a, 'cmp) t -> bool
    ) options
  val fold_until
    :  ('a, _) t
    -> init:'b
    -> f:('b -> 'a elt -> ('b, 'stop) Continue_or_stop.t)
    -> ('b, 'stop) Finished_or_stopped_early.t
  val fold_right
    :  ('a, _) t
    -> init:'b
    -> f:('a elt -> 'b -> 'b)
    -> 'b
  val iter2
    :  ('a, 'cmp,
        ('a, 'cmp) t
        -> ('a, 'cmp) t
        -> f:([ `Left of 'a elt | `Right of 'a elt | `Both of 'a elt * 'a elt ] -> unit)
        -> unit
    ) options
  val filter
    :  ('a, 'cmp,
        ('a, 'cmp) t -> f:('a elt -> bool) -> ('a, 'cmp) t
    ) options
  val partition_tf
    :  ('a, 'cmp,
        ('a, 'cmp) t
        -> f:('a elt -> bool)
        -> ('a, 'cmp) t * ('a, 'cmp) t
    ) options

  val elements : ('a, _) t -> 'a elt list

  val min_elt     : ('a, _) t -> 'a elt option
  val min_elt_exn : ('a, _) t -> 'a elt
  val max_elt     : ('a, _) t -> 'a elt option
  val max_elt_exn : ('a, _) t -> 'a elt
  val choose      : ('a, _) t -> 'a elt option
  val choose_exn  : ('a, _) t -> 'a elt

  val split
    : ('a, 'cmp,
       ('a, 'cmp) t
       -> 'a elt
       -> ('a, 'cmp) t * 'a elt option * ('a, 'cmp) t
    ) options

  val group_by
    : ('a, 'cmp,
       ('a, 'cmp) t
       -> equiv:('a elt -> 'a elt -> bool)
       -> ('a, 'cmp) t list
    ) options

  val find_exn : ('a, _) t -> f:('a elt -> bool) -> 'a elt
  val find_index : ('a, _) t -> int -> 'a elt option
  val remove_index
    : ('a, 'cmp,
       ('a, 'cmp) t -> int -> ('a, 'cmp) t
    ) options

  val to_tree : ('a, 'cmp) t -> ('a elt, 'cmp) tree

  val to_sequence
    : ('a, 'cmp,
       ?order:[ `Increasing | `Decreasing ]
       -> ?greater_or_equal_to:'a elt
       -> ?less_or_equal_to:'a elt
       -> ('a, 'cmp) t
       -> 'a elt Sequence.t
      ) options

  val merge_to_sequence
    : ('a, 'cmp,
       ?order:[ `Increasing | `Decreasing ]
       -> ?greater_or_equal_to:'a elt
       -> ?less_or_equal_to:'a elt
       -> ('a, 'cmp) t
       -> ('a, 'cmp) t
       -> 'a elt Merge_to_sequence_element.t Sequence.t
      ) options

  val to_map
    : ('a, 'cmp,
       ('a, 'cmp) t -> f:('a elt -> 'b) -> ('a elt, 'b, 'cmp cmp) Map.t
    ) options

  val obs : 'a elt Quickcheck.obs -> ('a, 'cmp) t Quickcheck.obs

  val shrinker
    : ('a, 'cmp,
       'a elt Quickcheck.shr -> ('a, 'cmp) t Quickcheck.shr
      ) options
end

module type Accessors0 = sig
  include Container.S0
  type tree
  type comparator_witness
  val invariants     : t -> bool
  val mem            : t -> elt -> bool
  val add            : t -> elt -> t
  val remove         : t -> elt -> t
  val union          : t -> t -> t
  val inter          : t -> t -> t
  val diff           : t -> t -> t
  val symmetric_diff : t -> t -> (elt, elt) Either.t Sequence.t
  val compare_direct : t -> t -> int
  val equal          : t -> t -> bool
  val subset         : t -> t -> bool
  val fold_until
    : t
    -> init:'b
    -> f:('b -> elt -> ('b, 'stop) Continue_or_stop.t)
    -> ('b, 'stop) Finished_or_stopped_early.t
  val fold_right     : t -> init:'b -> f:(elt -> 'b -> 'b) -> 'b
  val iter2
    :  t -> t -> f:([ `Left of elt | `Right of elt | `Both of elt * elt ] -> unit) -> unit
  val filter         : t -> f:(elt -> bool) -> t
  val partition_tf   : t -> f:(elt -> bool) -> t * t
  val elements       : t -> elt list
  val min_elt        : t -> elt option
  val min_elt_exn    : t -> elt
  val max_elt        : t -> elt option
  val max_elt_exn    : t -> elt
  val choose         : t -> elt option
  val choose_exn     : t -> elt
  val split          : t -> elt -> t * elt option * t
  val group_by       : t -> equiv:(elt -> elt -> bool) -> t list
  val find_exn       : t -> f:(elt -> bool) -> elt
  val find_index     : t -> int -> elt option
  val remove_index   : t -> int -> t
  val to_tree        : t -> tree
  val to_sequence
    :  ?order:[ `Increasing | `Decreasing ]
    -> ?greater_or_equal_to:elt
    -> ?less_or_equal_to:elt
    -> t
    -> elt Sequence.t
  val merge_to_sequence
    :  ?order:[ `Increasing | `Decreasing ]
    -> ?greater_or_equal_to:elt
    -> ?less_or_equal_to:elt
    -> t
    -> t
    -> elt Merge_to_sequence_element.t Sequence.t
  val to_map         : t -> f:(elt -> 'data) -> (elt, 'data, comparator_witness) Map.t
  val obs : elt Quickcheck.obs -> t Quickcheck.obs
  val shrinker : elt Quickcheck.shr -> t Quickcheck.shr
end

module type Accessors1 = sig
  include Container.S1
  type 'a tree
  type comparator_witness
  val invariants     : _ t -> bool
  val mem            : 'a t -> 'a -> bool
  val add            : 'a t -> 'a -> 'a t
  val remove         : 'a t -> 'a -> 'a t
  val union          : 'a t -> 'a t -> 'a t
  val inter          : 'a t -> 'a t -> 'a t
  val diff           : 'a t -> 'a t -> 'a t
  val symmetric_diff : 'a t -> 'a t -> ('a, 'a) Either.t Sequence.t
  val compare_direct : 'a t -> 'a t -> int
  val equal          : 'a t -> 'a t -> bool
  val subset         : 'a t -> 'a t -> bool
  val fold_until
    : 'a t
    -> init:'b
    -> f:('b -> 'a -> ('b, 'stop) Continue_or_stop.t)
    -> ('b, 'stop) Finished_or_stopped_early.t
  val fold_right     :  'a t -> init:'b -> f:('a -> 'b -> 'b) -> 'b
  val iter2
    : 'a t -> 'a t -> f:([ `Left of 'a | `Right of 'a | `Both of 'a * 'a ] -> unit) -> unit
  val filter         : 'a t -> f:('a -> bool) -> 'a t
  val partition_tf   : 'a t -> f:('a -> bool) -> 'a t * 'a t
  val elements       : 'a t -> 'a list
  val min_elt        : 'a t -> 'a option
  val min_elt_exn    : 'a t -> 'a
  val max_elt        : 'a t -> 'a option
  val max_elt_exn    : 'a t -> 'a
  val choose         : 'a t -> 'a option
  val choose_exn     : 'a t -> 'a
  val split          : 'a t -> 'a -> 'a t * 'a option * 'a t
  val group_by       : 'a t -> equiv:('a -> 'a -> bool) -> 'a t list
  val find_exn       : 'a t -> f:('a -> bool) -> 'a
  val find_index     : 'a t -> int -> 'a option
  val remove_index   : 'a t -> int -> 'a t
  val to_tree        : 'a t -> 'a tree
  val to_sequence
    :  ?order:[ `Increasing | `Decreasing ]
    -> ?greater_or_equal_to:'a
    -> ?less_or_equal_to:'a
    -> 'a t
    -> 'a Sequence.t
  val merge_to_sequence
    :  ?order:[ `Increasing | `Decreasing ]
    -> ?greater_or_equal_to:'a
    -> ?less_or_equal_to:'a
    -> 'a t
    -> 'a t
    -> 'a Merge_to_sequence_element.t Sequence.t
  val to_map         : 'a t -> f:('a -> 'b) -> ('a, 'b, comparator_witness) Map.t
  val obs : 'a Quickcheck.obs -> 'a t Quickcheck.obs
  val shrinker : 'a Quickcheck.shr -> 'a t Quickcheck.shr
end

module type Accessors2 = sig
  include Container.S1_phantom_invariant
  type ('a, 'cmp) tree
  val invariants     : (_, _) t -> bool
  val mem            : ('a, _) t -> 'a -> bool
  val add            : ('a, 'cmp) t -> 'a -> ('a, 'cmp) t
  val remove         : ('a, 'cmp) t -> 'a -> ('a, 'cmp) t
  val union          : ('a, 'cmp) t -> ('a, 'cmp) t -> ('a, 'cmp) t
  val inter          : ('a, 'cmp) t -> ('a, 'cmp) t -> ('a, 'cmp) t
  val diff           : ('a, 'cmp) t -> ('a, 'cmp) t -> ('a, 'cmp) t
  val symmetric_diff : ('a, 'cmp) t -> ('a, 'cmp) t -> ('a, 'a) Either.t Sequence.t
  val compare_direct : ('a, 'cmp) t -> ('a, 'cmp) t -> int
  val equal          : ('a, 'cmp) t -> ('a, 'cmp) t -> bool
  val subset         : ('a, 'cmp) t -> ('a, 'cmp) t -> bool
  val fold_until
    : ('a, _) t
    -> init:'b
    -> f:('b -> 'a -> ('b, 'stop) Continue_or_stop.t)
    -> ('b, 'stop) Finished_or_stopped_early.t

  val fold_right     : ('a, _) t -> init:'b -> f:('a -> 'b -> 'b) -> 'b
  val iter2
    :  ('a, 'cmp) t
    -> ('a, 'cmp) t -> f:([ `Left of 'a | `Right of 'a | `Both of 'a * 'a ] -> unit)
    -> unit
  val filter         : ('a, 'cmp) t -> f:('a -> bool) -> ('a, 'cmp) t
  val partition_tf   : ('a, 'cmp) t -> f:('a -> bool) -> ('a, 'cmp) t * ('a, 'cmp) t
  val elements       : ('a, _) t -> 'a list
  val min_elt        : ('a, _) t -> 'a option
  val min_elt_exn    : ('a, _) t -> 'a
  val max_elt        : ('a, _) t -> 'a option
  val max_elt_exn    : ('a, _) t -> 'a
  val choose         : ('a, _) t -> 'a option
  val choose_exn     : ('a, _) t -> 'a
  val split          : ('a, 'cmp) t -> 'a -> ('a, 'cmp) t * 'a option * ('a, 'cmp) t
  val group_by       : ('a, 'cmp) t -> equiv:('a -> 'a -> bool) -> ('a, 'cmp) t list
  val find_exn       : ('a, _) t -> f:('a -> bool) -> 'a
  val find_index     : ('a, _) t -> int -> 'a option
  val remove_index   : ('a, 'cmp) t -> int -> ('a, 'cmp) t
  val to_tree        : ('a, 'cmp) t -> ('a, 'cmp) tree
  val to_sequence
    :  ?order:[ `Increasing | `Decreasing ]
    -> ?greater_or_equal_to:'a
    -> ?less_or_equal_to:'a
    -> ('a, 'cmp) t
    -> 'a Sequence.t
  val merge_to_sequence
    :  ?order:[ `Increasing | `Decreasing ]
    -> ?greater_or_equal_to:'a
    -> ?less_or_equal_to:'a
    -> ('a, 'cmp) t
    -> ('a, 'cmp) t
    -> 'a Merge_to_sequence_element.t Sequence.t
  val to_map         : ('a, 'cmp) t -> f:('a -> 'b) -> ('a, 'b, 'cmp) Map.t
  val obs : 'a Quickcheck.obs -> ('a, 'cmp) t Quickcheck.obs
  val shrinker : 'a Quickcheck.shr -> ('a, 'cmp) t Quickcheck.shr
end

module type Accessors2_with_comparator = sig
  include Container.S1_phantom_invariant
  type ('a, 'cmp) tree
  val invariants     : comparator:('a, 'cmp) Comparator.t -> ('a, 'cmp) t -> bool
  val mem            : comparator:('a, 'cmp) Comparator.t -> ('a, 'cmp) t -> 'a -> bool
  val add
    : comparator:('a, 'cmp) Comparator.t -> ('a, 'cmp) t -> 'a -> ('a, 'cmp) t
  val remove
    : comparator:('a, 'cmp) Comparator.t -> ('a, 'cmp) t -> 'a -> ('a, 'cmp) t
  val union
    : comparator:('a, 'cmp) Comparator.t -> ('a, 'cmp) t -> ('a, 'cmp) t -> ('a, 'cmp) t
  val inter
    : comparator:('a, 'cmp) Comparator.t -> ('a, 'cmp) t -> ('a, 'cmp) t -> ('a, 'cmp) t
  val diff
    : comparator:('a, 'cmp) Comparator.t -> ('a, 'cmp) t -> ('a, 'cmp) t -> ('a, 'cmp) t
  val symmetric_diff
    : comparator:('a, 'cmp) Comparator.t -> ('a, 'cmp) t -> ('a, 'cmp) t
    -> ('a, 'a) Either.t Sequence.t
  val compare_direct
    : comparator:('a, 'cmp) Comparator.t -> ('a, 'cmp) t -> ('a, 'cmp) t -> int
  val equal
    : comparator:('a, 'cmp) Comparator.t -> ('a, 'cmp) t -> ('a, 'cmp) t -> bool
  val subset
    : comparator:('a, 'cmp) Comparator.t -> ('a, 'cmp) t -> ('a, 'cmp) t -> bool
  val fold_until
    :  ('a, _) t
    -> init:'accum
    -> f:('accum -> 'a -> ('accum, 'stop) Continue_or_stop.t)
    -> ('accum, 'stop) Finished_or_stopped_early.t

  val fold_right : ('a, _) t -> init:'accum -> f:('a -> 'accum -> 'accum) -> 'accum
  val iter2
    :  comparator:('a, 'cmp) Comparator.t
    -> ('a, 'cmp) t
    -> ('a, 'cmp) t
    -> f:([ `Left of 'a | `Right of 'a | `Both of 'a * 'a ] -> unit)
    -> unit
  val filter
    : comparator:('a, 'cmp) Comparator.t -> ('a, 'cmp) t -> f:('a -> bool) -> ('a, 'cmp) t
  val partition_tf
    : comparator:('a, 'cmp) Comparator.t
    -> ('a, 'cmp) t -> f:('a -> bool) -> ('a, 'cmp) t * ('a, 'cmp) t
  val elements       : ('a, _) t -> 'a list
  val min_elt        : ('a, _) t -> 'a option
  val min_elt_exn    : ('a, _) t -> 'a
  val max_elt        : ('a, _) t -> 'a option
  val max_elt_exn    : ('a, _) t -> 'a
  val choose         : ('a, _) t -> 'a option
  val choose_exn     : ('a, _) t -> 'a
  val split
    : comparator:('a, 'cmp) Comparator.t
    -> ('a, 'cmp) t -> 'a -> ('a, 'cmp) t * 'a option * ('a, 'cmp) t
  val group_by
    : comparator:('a, 'cmp) Comparator.t
    -> ('a, 'cmp) t -> equiv:('a -> 'a -> bool) -> ('a, 'cmp) t list
  val find_exn       : ('a, _) t -> f:('a -> bool) -> 'a
  val find_index     : ('a, _) t -> int -> 'a option
  val remove_index
    : comparator:('a, 'cmp) Comparator.t -> ('a, 'cmp) t -> int -> ('a, 'cmp) t
  val to_tree        : ('a, 'cmp) t -> ('a, 'cmp) tree
  val to_sequence
    :  comparator:('a, 'cmp) Comparator.t
    -> ?order:[ `Increasing | `Decreasing ]
    -> ?greater_or_equal_to:'a
    -> ?less_or_equal_to:'a
    -> ('a, 'cmp) t
    -> 'a Sequence.t
  val merge_to_sequence
    :  comparator:('a, 'cmp) Comparator.t
    -> ?order:[ `Increasing | `Decreasing ]
    -> ?greater_or_equal_to:'a
    -> ?less_or_equal_to:'a
    -> ('a, 'cmp) t
    -> ('a, 'cmp) t
    -> 'a Merge_to_sequence_element.t Sequence.t
  val to_map
    :  comparator:('a, 'cmp) Comparator.t
    -> ('a, 'cmp) t
    -> f:('a -> 'b)
    -> ('a, 'b, 'cmp) Map.t
  val obs : 'a Quickcheck.obs -> ('a, 'cmp) t Quickcheck.obs
  val shrinker
    :  comparator:('a, 'cmp) Comparator.t
    -> 'a Quickcheck.shr
    -> ('a, 'cmp) t Quickcheck.shr
end

(** Consistency checks (same as in [Container]). *)
module Check_accessors (T : T2) (Tree : T2) (Elt : T1) (Cmp : T1) (Options : T3)
  (M : Accessors_generic
     with type ('a, 'b, 'c) options := ('a, 'b, 'c) Options.t
     with type ('a, 'b) t           := ('a, 'b) T.t
     with type ('a, 'b) tree        := ('a, 'b) Tree.t
     with type 'a elt               := 'a Elt.t
     with type 'cmp cmp             := 'cmp Cmp.t)
  = struct end

module Check_accessors0 (M : Accessors0) =
  Check_accessors
    (struct type ('a, 'b) t = M.t end)
    (struct type ('a, 'b) t = M.tree end)
    (struct type 'a t = M.elt end)
    (struct type 'a t = M.comparator_witness end)
    (Without_comparator)
    (M)

module Check_accessors1 (M : Accessors1) =
  Check_accessors
    (struct type ('a, 'b) t = 'a M.t end)
    (struct type ('a, 'b) t = 'a M.tree end)
    (struct type 'a t = 'a end)
    (struct type 'a t = M.comparator_witness end)
    (Without_comparator)
    (M)

module Check_accessors2 (M : Accessors2) =
  Check_accessors
    (struct type ('a, 'b) t = ('a, 'b) M.t end)
    (struct type ('a, 'b) t = ('a, 'b) M.tree end)
    (struct type 'a t = 'a end)
    (struct type 'a t = 'a end)
    (Without_comparator)
    (M)

module Check_accessors2_with_comparator (M : Accessors2_with_comparator) =
  Check_accessors
    (struct type ('a, 'b) t = ('a, 'b) M.t end)
    (struct type ('a, 'b) t = ('a, 'b) M.tree end)
    (struct type 'a t = 'a end)
    (struct type 'a t = 'a end)
    (With_comparator)
    (M)

module type Creators_generic = sig
  type ('a, 'cmp) t
  type ('a, 'cmp) set
  type ('a, 'cmp) tree
  type 'a elt
  type ('a, 'cmp, 'z) options
  type 'cmp cmp

  val empty : ('a, 'cmp, ('a, 'cmp) t) options
  val singleton : ('a, 'cmp, 'a elt -> ('a, 'cmp) t) options
  val union_list
    :  ('a, 'cmp,
        ('a, 'cmp) t list -> ('a, 'cmp) t
    ) options
  val of_list  : ('a, 'cmp, 'a elt list  -> ('a, 'cmp) t) options
  val of_array : ('a, 'cmp, 'a elt array -> ('a, 'cmp) t) options

  val of_sorted_array : ('a, 'cmp, 'a elt array -> ('a, 'cmp) t Or_error.t) options

  val of_sorted_array_unchecked : ('a, 'cmp, 'a elt array -> ('a, 'cmp) t) options

  val of_hash_set     : ('a, 'cmp,  'a elt     Hash_set.t     -> ('a, 'cmp) t) options
  val of_hashtbl_keys : ('a, 'cmp, ('a elt, _) Core_hashtbl.t -> ('a, 'cmp) t) options

  val stable_dedup_list : ('a, _, 'a elt list -> 'a elt list) options

  (** The types of [map] and [filter_map] are subtle.  The input set, [('a, _) set],
      reflects the fact that these functions take a set of *any* type, with any
      comparator, while the output set, [('b, 'cmp) t], reflects that the output set has
      the particular ['cmp] of the creation function.  The comparator can come in one of
      three ways, depending on which set module is used

      - [Set.map] -- comparator comes as an argument
      - [Set.Poly.map] -- comparator is polymorphic comparison
      - [Foo.Set.map] -- comparator is [Foo.comparator] *)
  val map
    : ('b, 'cmp, ('a, _) set -> f:('a -> 'b elt       ) -> ('b, 'cmp) t
    ) options
  val filter_map
    : ('b, 'cmp, ('a, _) set -> f:('a -> 'b elt option) -> ('b, 'cmp) t
    ) options

  val of_tree
    : ('a, 'cmp,
       ('a elt, 'cmp) tree -> ('a, 'cmp) t
    ) options

  (** never requires a comparator because it can get one from the input [Map.t] *)
  val of_map_keys : ('a elt, _, 'cmp cmp) Map.t -> ('a, 'cmp) t

  val gen
    : ('a, 'cmp,
       'a elt Quickcheck.Generator.t
       -> ('a, 'cmp) t Quickcheck.Generator.t
      ) options
end

module type Creators0 = sig
  type ('a, 'cmp) set
  type t
  type tree
  type elt
  type comparator_witness
  val empty                     : t
  val singleton                 : elt -> t
  val union_list                : t list -> t
  val of_list                   : elt list -> t
  val of_hash_set               : elt Hash_set.t  -> t
  val of_hashtbl_keys           : (elt, _) Core_hashtbl.t -> t
  val of_array                  : elt array -> t
  val of_sorted_array           : elt array -> t Or_error.t
  val of_sorted_array_unchecked : elt array -> t
  val stable_dedup_list         : elt list -> elt list
  val map                       : ('a, _) set -> f:('a -> elt       ) -> t
  val filter_map                : ('a, _) set -> f:('a -> elt option) -> t
  val of_tree                   : tree -> t
  val of_map_keys               : (elt, _, comparator_witness) Map.t -> t
  val gen                       : elt Quickcheck.Generator.t -> t Quickcheck.Generator.t
end

module type Creators1 = sig
  type ('a, 'cmp) set
  type 'a t
  type 'a tree
  type comparator_witness
  val empty                     : 'a t
  val singleton                 : 'a -> 'a t
  val union_list                : 'a t list -> 'a t
  val of_list                   : 'a list -> 'a t
  val of_hash_set               : 'a Hash_set.t  -> 'a t
  val of_hashtbl_keys           : ('a, _) Core_hashtbl.t -> 'a t
  val of_array                  : 'a array -> 'a t
  val of_sorted_array           : 'a array -> 'a t Or_error.t
  val of_sorted_array_unchecked : 'a array -> 'a t
  val stable_dedup_list         : 'a list -> 'a list
  val map                       : ('a, _) set -> f:('a -> 'b       ) -> 'b t
  val filter_map                : ('a, _) set -> f:('a -> 'b option) -> 'b t
  val of_tree                   : 'a tree -> 'a t
  val of_map_keys               : ('a, _, comparator_witness) Map.t -> 'a t
  val gen                       : 'a Quickcheck.Generator.t -> 'a t Quickcheck.Generator.t
end

module type Creators2 = sig
  type ('a, 'cmp) set
  type ('a, 'cmp) t
  type ('a, 'cmp) tree
  val empty                     : ('a, 'cmp) t
  val singleton                 : 'a -> ('a, 'cmp) t
  val union_list                : ('a, 'cmp) t list -> ('a, 'cmp) t
  val of_list                   : 'a list -> ('a, 'cmp) t
  val of_hash_set               : 'a Hash_set.t  -> ('a, 'cmp) t
  val of_hashtbl_keys           : ('a, _) Core_hashtbl.t -> ('a, 'cmp) t
  val of_array                  : 'a array -> ('a, 'cmp) t
  val of_sorted_array           : 'a array -> ('a, 'cmp) t Or_error.t
  val of_sorted_array_unchecked : 'a array -> ('a, 'cmp) t
  val stable_dedup_list         : 'a list -> 'a list
  val map                       : ('a, _) set -> f:('a -> 'b       ) -> ('b, 'cmp) t
  val filter_map                : ('a, _) set -> f:('a -> 'b option) -> ('b, 'cmp) t
  val of_tree                   : ('a, 'cmp) tree -> ('a, 'cmp) t
  val of_map_keys               : ('a, _, 'cmp) Map.t -> ('a, 'cmp) t
  val gen
    :  'a Quickcheck.Generator.t
    -> ('a, 'cmp) t Quickcheck.Generator.t
end

module type Creators2_with_comparator = sig
  type ('a, 'cmp) set
  type ('a, 'cmp) t
  type ('a, 'cmp) tree
  val empty                     : comparator:('a, 'cmp) Comparator.t -> ('a, 'cmp) t
  val singleton                 : comparator:('a, 'cmp) Comparator.t -> 'a -> ('a, 'cmp) t
  val union_list                : comparator:('a, 'cmp) Comparator.t -> ('a, 'cmp) t list
    -> ('a, 'cmp) t
  val of_list                   : comparator:('a, 'cmp) Comparator.t -> 'a list
    -> ('a, 'cmp) t
  val of_hash_set               : comparator:('a, 'cmp) Comparator.t -> 'a Hash_set.t
    -> ('a, 'cmp) t
  val of_hashtbl_keys           : comparator:('a, 'cmp) Comparator.t
    -> ('a, _) Core_hashtbl.t -> ('a, 'cmp) t
  val of_array                  : comparator:('a, 'cmp) Comparator.t -> 'a array
    -> ('a, 'cmp) t
  val of_sorted_array           : comparator:('a, 'cmp) Comparator.t -> 'a array
    -> ('a, 'cmp) t Or_error.t
  val of_sorted_array_unchecked : comparator:('a, 'cmp) Comparator.t -> 'a array
    -> ('a, 'cmp) t
  val stable_dedup_list         : comparator:('a, 'cmp) Comparator.t -> 'a list -> 'a list
  val map                       : comparator:('b, 'cmp) Comparator.t -> ('a, _) set
    -> f:('a -> 'b       ) -> ('b, 'cmp) t
  val filter_map                : comparator:('b, 'cmp) Comparator.t -> ('a, _) set
    -> f:('a -> 'b option) -> ('b, 'cmp) t
  val of_tree                   : comparator:('a, 'cmp) Comparator.t
    -> ('a, 'cmp) tree -> ('a, 'cmp) t

  val of_map_keys : ('a, _, 'cmp) Map.t -> ('a, 'cmp) t

  val gen
    :  comparator:('a, 'cmp) Comparator.t
    -> 'a Quickcheck.Generator.t
    -> ('a, 'cmp) t Quickcheck.Generator.t
end

module Check_creators (T : T2) (Tree : T2) (Elt : T1) (Cmp : T1) (Options : T3)
  (M : Creators_generic
     with type ('a, 'b, 'c) options := ('a, 'b, 'c) Options.t
     with type ('a, 'b) t           := ('a, 'b) T.t
     with type ('a, 'b) tree        := ('a, 'b) Tree.t
     with type 'a elt               := 'a Elt.t
     with type 'cmp cmp             := 'cmp Cmp.t)
  = struct end

module Check_creators0 (M : Creators0) =
  Check_creators
    (struct type ('a, 'b) t = M.t end)
    (struct type ('a, 'b) t = M.tree end)
    (struct type 'a t = M.elt end)
    (struct type 'cmp t = M.comparator_witness end)
    (Without_comparator)
    (M)

module Check_creators1 (M : Creators1) =
  Check_creators
    (struct type ('a, 'b) t = 'a M.t end)
    (struct type ('a, 'b) t = 'a M.tree end)
    (struct type 'a t = 'a end)
    (struct type 'cmp t = M.comparator_witness end)
    (Without_comparator)
    (M)

module Check_creators2 (M : Creators2) =
  Check_creators
    (struct type ('a, 'b) t = ('a, 'b) M.t end)
    (struct type ('a, 'b) t = ('a, 'b) M.tree end)
    (struct type 'a t = 'a end)
    (struct type 'cmp t = 'cmp end)
    (Without_comparator)
    (M)

module Check_creators2_with_comparator (M : Creators2_with_comparator) =
  Check_creators
    (struct type ('a, 'b) t = ('a, 'b) M.t end)
    (struct type ('a, 'b) t = ('a, 'b) M.tree end)
    (struct type 'a t = 'a end)
    (struct type 'cmp t = 'cmp end)
    (With_comparator)
    (M)

module type Creators_and_accessors_generic = sig
  include Accessors_generic
  include Creators_generic
    with type ('a, 'b, 'c) options := ('a, 'b, 'c) options
    with type ('a, 'b) t           := ('a, 'b) t
    with type ('a, 'b) tree        := ('a, 'b) tree
    with type 'a elt               := 'a elt
    with type 'cmp cmp             := 'cmp cmp
end

module type Creators_and_accessors0 = sig
  include Accessors0
  include Creators0
    with type t    := t
    with type tree := tree
    with type elt  := elt
    with type comparator_witness := comparator_witness
end

module type Creators_and_accessors1 = sig
  include Accessors1
  include Creators1
    with type 'a t    := 'a t
    with type 'a tree := 'a tree
    with type comparator_witness := comparator_witness
end

module type Creators_and_accessors2 = sig
  include Accessors2
  include Creators2
    with type ('a, 'b) t    := ('a, 'b) t
    with type ('a, 'b) tree := ('a, 'b) tree
end

module type Creators_and_accessors2_with_comparator = sig
  include Accessors2_with_comparator
  include Creators2_with_comparator
    with type ('a, 'b) t    := ('a, 'b) t
    with type ('a, 'b) tree := ('a, 'b) tree
end

module type S0 = sig
  type ('a, 'cmp) set
  type ('a, 'cmp) tree

  module Elt : sig
    type t [@@deriving sexp]
    include Comparator.S with type t := t
  end

  module Tree : sig
    type t = (Elt.t, Elt.comparator_witness) tree [@@deriving compare, sexp]

    include Creators_and_accessors0
      with type ('a, 'b) set := ('a, 'b) tree
      with type t            := t
      with type tree         := t
      with type elt          := Elt.t
      with type comparator_witness := Elt.comparator_witness
  end

  type t = (Elt.t, Elt.comparator_witness) set [@@deriving compare, sexp]

  include Creators_and_accessors0
    with type ('a, 'b) set := ('a, 'b) set
    with type t            := t
    with type tree         := Tree.t
    with type elt          := Elt.t
    with type comparator_witness := Elt.comparator_witness
end

module type S0_binable = sig
  include S0
  include Binable.S with type t := t
end
