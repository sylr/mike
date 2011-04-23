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
Datum  __natsort(PG_FUNCTION_ARGS);

/* exportation */
PG_FUNCTION_INFO_V1(__natsort);

/**
 * __natsort left pad sequences of numbers inside input
 * with zeros in order to make natural sorting.
 */
Datum __natsort(PG_FUNCTION_ARGS)
{
    int32 i, n, oPtr, size;
    char c;
    char* input;
    char* output;
    int32 iPtr          = 0;
    int32 state         = 0;
    int32 counter       = 0;
    int32 result_size   = VARHDRSZ;
    text* t             = (text*)(0);
    text* result        = (text*)(0);

    t       = (text *) PG_GETARG_TEXT_P(0);
    size    = VARSIZE(t) - VARHDRSZ;
    input   = VARDATA(t);

    /*
     * compute size of output
     */
    while (iPtr < size)
    {
        c = input[iPtr++];

        if (state) // NUM state
        {
            if ((c >= '0') && (c  <= '9'))
            {
                counter++;
            }
            else
            {
                state = 0;
                result_size++;

                if (counter < NATSORT_PADDING)
                {
                    result_size += NATSORT_PADDING;
                }
                else
                {
                    result_size += counter;
                }
            }
        }
        else // non NUM state
        {
            if ((c >= '0') && (c  <= '9'))
            {
                counter = state = 1;
            }
            else
            {
                result_size++;
            }
        }
    }

    if (state)
    {
        if (counter < NATSORT_PADDING)
        {
            result_size += NATSORT_PADDING;
        }
        else
        {
            result_size += counter;
        }
    }

    result = (text *) palloc(result_size);
    SET_VARSIZE(result, result_size);
    output = VARDATA(result);

    iPtr = oPtr = state = 0;

    /*
     * compute output result
     */
    while (iPtr < size)
    {
        c = input[iPtr++];

        if (state) // NUM state
        {
            if ((c >= '0') && (c <= '9'))
            {
                counter++;
            }
            else
            {
                state = 0;

                if (counter < NATSORT_PADDING)
                {
                    n = NATSORT_PADDING - counter;

                    for (i = 0; i < n; i++)
                    {
                        output[oPtr++] = '0';
                    }

                    for (i = 0; i < counter; i++)
                    {
                        output[oPtr++] = input[iPtr - 1 - counter + i];
                    }
                }
                else
                {
                    for (i = 0; i < counter; i++)
                    {
                        output[oPtr++] = input[iPtr - 1 - counter + i];
                    }
                }

                output[oPtr++] = c;
            }
        }
        else // non NUM state
        {
            if ((c >= '0') && (c <= '9'))
            {
                counter = state = 1;
            }
            else
            {
                output[oPtr++] = c;
            }
        }
    }

    if (state)
    {
        if (counter < NATSORT_PADDING)
        {
            n = NATSORT_PADDING - counter;

            for (i = 0; i < n; i++)
            {
                output[oPtr++] = '0';
            }

            for (i = 0; i < counter; i++)
            {
                output[oPtr++] = input[size - counter + i];
            }
        }
        else
        {
            for (i = 0; i < counter; i++)
            {
                output[oPtr++] = input[size - counter + i];
            }
        }
    }

    PG_RETURN_TEXT_P(result);
}
