/*
 * Mike's Function
 * vim: set tabstop=4 expandtab autoindent smartindent:
 * author: Jean-Yves Eckert <jean-yves.eckert@f-secure.com>
 * date: 20/04/2011
 * copyright: All rights reserved
 */

#include <string.h>
#include "postgres.h"
#include "fmgr.h"

#ifndef NATSORT_PADDING
#define NATSORT_PADDING 8
#endif

/* declaration */
int     __natsort_asm_pad_size(int size, char* str);
void    __natsort_asm_pad(int size, char* str, char* output);
Datum   __natsort_asm(PG_FUNCTION_ARGS);

/* exportation */
PG_FUNCTION_INFO_V1(__natsort_asm);

/**
 * __natsort left pad sequences of numbers inside input
 * with zeros in order to make natural sorting.
 */
Datum __natsort_asm(PG_FUNCTION_ARGS)
{
    int32 size, result_size;
    char* input;
    char* output;
    text* t             = (text*)(0);
    text* result        = (text*)(0);

    t       = (text *) PG_GETARG_TEXT_P(0);
    size    = VARSIZE(t) - VARHDRSZ;
    input   = VARDATA(t);

    /*
     * compute size of output
     */
    result_size = VARHDRSZ + __natsort_asm_pad_size(size, input);
    result = (text *) palloc(result_size);
    SET_VARSIZE(result, result_size);
    output = VARDATA(result);

    /*
     * compute output result
     */
    __natsort_asm_pad(size, input, output);

    PG_RETURN_TEXT_P(result);
}
