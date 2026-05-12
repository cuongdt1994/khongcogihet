#ifndef __SIGNAL_HANDLER_H
#define __SIGNAL_HANDLER_H

#include <signal.h>
#include <cstdlib>

static void int_handler(int sig)
{
    exit(0);
}

static inline void SetupSignalHandler()
{
    signal(SIGINT, int_handler);
    signal(SIGTERM, int_handler);
}

#endif