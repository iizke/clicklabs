// token-bucket.click
// Simulate traffic policer and shaper: token bucket

elementclass TokenBucketPolicer {
  RATE $rate, BURST $size |

  // Token bucket
  ps::PullSwitch(1);
  Idle -> [1]ps;
  s::RatedSource(LENGTH 1, LIMIT -1, ACTIVE true, STOP true, RATE $rate)
    -> tokenq::Queue($size)
    -> [0]ps
    -> Script(TYPE PACKET, write ps.switch 1)
    -> Discard;

  // This is controller to control the gate (ps pullswitch)
  sw::Switch(0)
  input 
    -> Script(TYPE PACKET, 
                set t $(tokenq.length), 
                write sw.switch $(if $(gt $t 0) 0 1), 
                write ps.switch $(if $(gt $t 0) 0 1)
                )
    -> sw;

  // Legal packets Go to output 0
  sw[0] -> output;
  // Illegal packets Die in output 1
  sw[1] -> Discard;
}

elementclass TokenBucketShaper {
  SIZE $size, RATE $rate, BURST $burst |
  
  policer::TokenBucketPolicer(RATE $rate, BURST $burst);
  input
    -> red::RED(100, $size, 0.01)
    -> q::Queue($size)
    -> shaper::RatedUnqueue(RATE $rate)
    -> policer
    -> output;

  cal_peak_rate::Script(TYPE ACTIVE, write shaper.rate $(mul $rate $burst));
  autoupdate_changesize::Script(TYPE PASSIVE, 
                                write red.min_thresh $(mul $(q.capacity) 0.5),
                                write red.max_thresh $(mul $(q.capacity) 1.5));
}

elementclass RatedTokenBucketPolicer {
  RATE $rate, BURST $size |

  // Token bucket
  ps::PullSwitch(1);
  Idle -> [1]ps;
  s::RatedSource(LENGTH 1, LIMIT -1, ACTIVE true, STOP true, RATE $rate)
    -> tokenq::Queue($size)
    -> [0]ps
    -> Script(TYPE PACKET, write ps.switch 1)
    -> Discard;

  sw::Switch(0)
  input
    -> Script(TYPE PACKET,
                set t $(tokenq.length),
                write sw.switch $(if $(gt $t 0) 0 1),
                write ps.switch $(if $(gt $t 0) 0 1)
                )
    -> sw;

  // Go on output 0
  sw[0] -> output;
  // Die in output 1
  sw[1] -> Discard;
}

elementclass RatedTokenBucketShaper {
  SIZE $size, RATE $rate, BURST $burst |

  policer::RatedTokenBucketPolicer(RATE $rate, BURST $burst);
  input
    -> red::RED(100, $size, 0.01)
    -> q::Queue($size)
    -> shaper::RatedUnqueue(RATE $rate)
    -> policer
    -> output;

  cal_peak_rate::Script(TYPE ACTIVE, write shaper.rate $(mul $rate $burst));
  autoupdate_changesize::Script(TYPE PASSIVE,
                                write red.min_thresh $(mul $(q.capacity) 0.5),
                                write red.max_thresh $(mul $(q.capacity) 1.5));
}

