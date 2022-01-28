# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 240,
  locals_without_parens: [
    fragment: 1,
    dag: 1,
    defdag: 1,
    as: 1,
    let: 1,
    ~>: 2,
    operator_filter: :*,
    edge_filter: :*,
    name: :*,
    name_filter: :*,
    splitter: :*,
    applied: :*,
    merged: :*,
    edge: :*,
    operator: :*,
    edge_handler: :*,
    op_handler: :*,
    name_handler: :*,
    handlers: :*,
    branches: :*,
    proceed: :*,
    edge_proceed: :*,
    op_proceed: :*,
    name_proceed: :*,
    next: :*,
    tick: :*,
    complete: :*,
    error: :*,
    base: :*,
    propagate: :*,
    initialize: :*,
    initialize_source: :*,
    initialize_sink: :*,
    pull: :*,
    handle_meta: :*,
    handle_meta_src: :*,
    meta: :*,
    meta_src: :*,
    init_src: :*,
    init_opr: :*,
    init_snk: :*,
    pullbase: :*,
    pulleffects: :*,
    decrypt: :*,
    mymeta: :*,
    others: :*,
    init_op: :*,
    default: :*,
    src_default: :*,
    opr_default: :*,
    snk_default: :*,
    forward_demand: :*,
    demand_src: :*,
    tick_src: :*,
    next_snk: :*,
    opr_next: :*,
    mapper: :*,
    op: :*,
    log_next: :*,
    not_next: :*,
    source_tick: :*,
    opr_outgoing: :*,
    opr_complete: :*,
    rest: :*,
    incoming: :*,
    ticks: :*,
    export: :*,
    rest?: :*,
    tick?: :*,
    rest: :*,
    completes: :*,
    complete_after_effects: :*,
    complete_before_effects: :*,
    do_effects: :*,
    outgoings: :*,
    incomings: :*,
    opr_done: :*,
    next?: :*,
    rests: :*,
    nexts: :*,
    rest: :*,
    complete?: :*,
    export_completes: :*,
    meta?: :*,
    metas: :*,

  ]
]
