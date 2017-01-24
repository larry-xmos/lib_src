// Copyright (c) 2017, XMOS Ltd, All rights reserved
#include <xs1.h>
#include <xclib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "src.h"

static int pseudo_random(unsigned &x)
{
    crc32(x, -1, 0xEB31D82E);
    return (int)x;
}

int main()
{
    unsigned x = 1;

    int32_t data_debug[72];
    memset(data_debug, 0, sizeof(data_debug));

    int32_t data[24];
    memset(data, 0, sizeof(data));

    for (unsigned s=0;s<64;s++)
    {

        int32_t d = pseudo_random(x);

        int32_t sample = src_us3_voice_input_sample(data, src_ff3v_fir_coefs[2], d);

        for (unsigned i=72-1;i>0;i--)
        {
            data_debug[i] = data_debug[i-1];
        }
        data_debug[0] = d;

        int64_t sum_debug = 0;
        for (unsigned i=0;i<72;i++)
        {
            sum_debug += (int64_t)src_ff3v_fir_coefs_debug[i]*(int64_t)data_debug[i];
        }
        sum_debug >>= 31;
        sum_debug = (int32_t)(((int64_t)sum_debug * (int64_t)src_ff3v_fir_comp )>>src_ff3v_fir_comp_q);

        if ((int32_t)sample != (int32_t)sum_debug)
        {
            printf("Error\n");
            return 1;
        }

        for(unsigned r=1;r<3;r++) {
            int32_t sample = src_us3_voice_get_next_sample(data, src_ff3v_fir_coefs[2-r]);
            for (unsigned i=72-1;i>0;i--)
            {
                data_debug[i] = data_debug[i-1];
            }
            data_debug[0] = 0;

            int64_t sum_debug = 0;
            for (unsigned i=0;i<72;i++)
            {
                sum_debug += (int64_t)src_ff3v_fir_coefs_debug[i]*(int64_t)data_debug[i];
            }
            sum_debug >>= 31;
            sum_debug = (int32_t)(((int64_t)sum_debug * (int64_t)src_ff3v_fir_comp )>>src_ff3v_fir_comp_q);

            if ((int32_t)sample != (int32_t)sum_debug)
            {
                printf("Error\n");
                return 1;
            }
        }

    }
    printf("Success\n");
    return 0;
}
