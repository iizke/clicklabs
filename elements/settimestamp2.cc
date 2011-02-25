// -*- c-basic-offset: 4 -*-
/*
 * settimestamp2.{cc,hh} -- set timestamp annotations
 * iizke
 * Douglas S. J. De Couto, Eddie Kohler
 * based on setperfcount.{cc,hh}
 *
 * Copyright (c) 1999-2000 Massachusetts Institute of Technology
 * Copyright (c) 2005 Regents of the University of California
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, subject to the conditions
 * listed in the Click LICENSE file. These conditions include: you must
 * preserve this copyright notice, and you cannot mention the copyright
 * holders in advertising related to the Software without their permission.
 * The Software is provided WITHOUT ANY WARRANTY, EXPRESS OR IMPLIED. This
 * notice is a summary of the Click LICENSE file; the license in that file is
 * legally binding.
 */

#include <click/config.h>
#include "settimestamp2.hh"
#include <click/confparse.hh>
#include <click/packet_anno.hh>
#include <click/error.hh>
CLICK_DECLS

SetTimestamp2::SetTimestamp2()
{
}

SetTimestamp2::~SetTimestamp2()
{
}

int
SetTimestamp2::configure(Vector<String> &conf, ErrorHandler *errh)
{
    bool first = false, delta = false;
    _tv.set_sec(-1);
    _action = ACT_NOW;
    addtime = 0;
    _active = true;
    if (cp_va_kparse(conf, this, errh,
		     "TIMESTAMP", cpkP, cpTimestamp, &_tv,
		     "FIRST", 0, cpBool, &first,
		     "DELTA", 0, cpBool, &delta,
         "ADD", 0, cpDouble, &addtime,
         "ACTIVE", 0, cpBool, &_active,
		     cpEnd) < 0)
	return -1;
    if ((first && delta) || (_tv.sec() >= 0 && delta))
	return errh->error("must specify at most one of %<FIRST%> and %<DELTA%>");
    _action = (delta ? ACT_DELTA : (_tv.sec() < 0 ? ACT_NOW : ACT_TIME) + (first ? ACT_FIRST_NOW : ACT_NOW) );
   return 0;
}

Packet *
SetTimestamp2::simple_action(Packet *p)
{
  if (!_active) {
    return p;
  }
  if (_action == ACT_NOW)
  	p->timestamp_anno().assign_now();
  else if (_action == ACT_TIME)
	  p->timestamp_anno() = _tv;
  else if (_action == ACT_FIRST_NOW)
	  FIRST_TIMESTAMP_ANNO(p).assign_now();
  else if (_action == ACT_FIRST_TIME)
	  FIRST_TIMESTAMP_ANNO(p) = _tv;
  else
	  p->timestamp_anno() -= FIRST_TIMESTAMP_ANNO(p);

  if (addtime > 0) {
    p->timestamp_anno() += (Timestamp)addtime;
    //FIRST_TIMESTAMP_ANNO(p) += (Timestamp)addtime;
    //click_chatter("stt2: addtime %f, timestamp %f \n", addtime, p->timestamp_anno().doubleval());
  }

  return p;
}

enum { H_WADD};
int
SetTimestamp2::change_param(const String &s, Element *e, void *vparam, ErrorHandler *errh)
{
  SetTimestamp2 *stt = (SetTimestamp2 *)e;
  switch ((intptr_t)vparam) {
    case H_WADD: {      // addtime
      double at;
      if (!cp_double(s, &at))
        return errh->error("[add] parameter must be a double");
      if (at < 0)
        return errh->error("[add] parameter must be a positive value");
      stt->addtime = at;
      break;
    }
    default:
      return errh->error("Something goes wrong");
  }
  return 0;
}

void
SetTimestamp2::add_handlers()
{
  add_data_handlers("add", Handler::OP_READ | Handler::CALM, &addtime);
  add_write_handler("add", change_param, (void*)H_WADD);
  add_data_handlers("active", Handler::OP_READ | Handler::OP_WRITE | Handler::CHECKBOX | Handler::CALM, &_active);
}

CLICK_ENDDECLS
EXPORT_ELEMENT(SetTimestamp2)
