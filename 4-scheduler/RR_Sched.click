// RR_Sched.click
// Simulate RR scheduler with at most 10 inputs (flows)

elementclass RRSched {
  SIZE $s |
  rrs::RoundRobinSched;
  input[0] -> q0::Queue($s) -> [0]rrs;
  input[1] -> q1::Queue($s) -> [1]rrs;
  input[2] -> q2::Queue($s) -> [2]rrs;
  input[3] -> q3::Queue($s) -> [3]rrs;
  input[4] -> q4::Queue($s) -> [4]rrs;
  input[5] -> q5::Queue($s) -> [5]rrs;
  input[6] -> q6::Queue($s) -> [6]rrs;
  input[7] -> q7::Queue($s) -> [7]rrs;
  input[8] -> q8::Queue($s) -> [8]rrs;
  input[9] -> q9::Queue($s) -> [9]rrs;
  rrs -> output;
}

Sched::RRSched(SIZE 100);

// Initialize flows
s0::RatedSource(LENGTH 1, RATE 1, ACTIVE true);
s1::RatedSource(LENGTH 1, RATE 3, ACTIVE true);
s2::RatedSource(LENGTH 1, RATE 6, ACTIVE true);
s3::RatedSource(LENGTH 1, RATE 800, ACTIVE false);
s4::RatedSource(LENGTH 1, RATE 100, ACTIVE false);
s5::RatedSource(LENGTH 1, RATE 100, ACTIVE false);
s6::RatedSource(LENGTH 1, RATE 100, ACTIVE false);
s7::RatedSource(LENGTH 1, RATE 100, ACTIVE false);
s8::RatedSource(LENGTH 1, RATE 100, ACTIVE false);
s9::RatedSource(LENGTH 1, RATE 100, ACTIVE false);

s0 -> Paint(0) -> [0]Sched;
s1 -> Paint(1) -> [1]Sched;
s2 -> Paint(2) -> [2]Sched;
s3 -> Paint(3) -> [3]Sched;
s4 -> Paint(4) -> [4]Sched;
s5 -> Paint(5) -> [5]Sched;
s6 -> Paint(6) -> [6]Sched;
s7 -> Paint(7) -> [7]Sched;
s8 -> Paint(8) -> [8]Sched;
s9 -> Paint(9) -> [9]Sched;

Sched
  //Pull-to-Push Converter
  //-> LinkUnqueue(10000us, 10Mbps)
  -> TimedUnqueue(1,1)
  -> SetTimestamp
  -> ps::PaintSwitch;

ps[0] -> ToDump(out0) -> c0::Counter -> Discard;
ps[1] -> ToDump(out1) -> c1::Counter -> Discard;
ps[2] -> ToDump(out2) -> c2::Counter -> Discard;
ps[3] -> c3::Counter -> Discard;
ps[4] -> c4::Counter -> Discard;
ps[5] -> c5::Counter -> Discard;
ps[6] -> c6::Counter -> Discard;
ps[7] -> c7::Counter -> Discard;
ps[8] -> c8::Counter -> Discard;
ps[9] -> c9::Counter -> Discard;

