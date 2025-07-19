#include <stdio.h>
#include <stdint.h>

int main() {
    
    /*
     * 8 addressible mem locations
     */
    // change to test
    int8_t mem_upper_in = 0b00010000;
    int8_t mem_lower_out = 0b10000000;

    int8_t mem_upper_out = 0;
    int8_t mem_lower_in = 0;
    
    /*
     * 8 registers
     */
    // exponent bias == 15
    //                 + 6 max exponent
    //                 + 1 sign bit
    const int8_t c_reg_exp_bias = 15;
 
    const int8_t c_reg_sign_mask = 0b10000000;

    // implied register
    int8_t reg_imp;

    int8_t reg_upper;
    int8_t reg_lower;
    int8_t reg_exp = 6;    // max exponent
    int8_t reg_sign_mask = c_reg_sign_mask;
    int8_t reg_gen;
    
    /*
     * function 1: fixed to float
     */

    // grab sign bit
    reg_imp = mem_upper_in;
    mem_upper_out = reg_imp & reg_sign_mask;
    // sign bit not leading 1
    reg_imp = reg_imp & ~reg_sign_mask;

    // find leading 1 in upper 8 bits
    // this can be replaced with 8 if-else checks
    while (reg_sign_mask)
    {
        if (reg_imp & reg_sign_mask)
        {
            break;
        }
        reg_exp--;
        reg_gen = 1;
        reg_sign_mask >> reg_gen;
    }

    // no 1s in upper 8 bits
    reg_gen = 0;
    if (reg_sign_mask == reg_gen)
    {
        // find leading 1 in lower 8 bits
        reg_sign_mask = c_reg_sign_mask;
        reg_imp = mem_lower_in;
        
        // this can be replaced with 8 if-else checks
        reg_gen = 0;
        while (reg_sign_mask > reg_gen)
        {
            if (reg_imp & reg_sign_mask)
            {
                break;
            }
            reg_exp--;
            reg_gen = 1;
            reg_sign_mask >> reg_gen;
            reg_gen = 0;
        }

        // zero val
        reg_gen = 0;
        if (c_reg_sign_mask == reg_gen)
        {
            return 0;
        }
        // exponent should be set now
    }

    // store exponent
    reg_imp = reg_exp;
    reg_imp = reg_imp + c_reg_exp_bias; // add bias
    reg_gen = mem_upper_out;            // grab sign bit
    reg_imp = reg_imp | reg_gen;        // OR together sign bit and exp+bias
    mem_upper_out = reg_imp;            // store

    // change exponent for hidden 1
    reg_gen = 2;
    reg_exp = reg_exp - reg_gen;
    
    reg_gen = 0;
    if (reg_exp == reg_gen) // no shift
    {
        reg_imp = mem_upper_in;
        mem_upper_out = reg_imp;
        reg_imp = mem_lower_in;
        mem_lower_out = reg_imp;
    }
    reg_gen = 0;
    if (reg_exp > reg_gen)  // right shift
    {
        reg_upper = mem_upper_in;
        reg_lower = mem_lower_in;

        // build lower
        reg_lower >> reg_exp;
        // calculate left shift upper
        reg_gen = 7;
        reg_imp = 1;
        reg_gen = reg_gen + reg_imp;    // reg_gen == 8
        reg_gen = reg_gen - reg_exp;
        // catch shift from upper
        reg_upper << reg_gen;
        reg_lower = reg_lower | reg_upper;  // lower 8 bits complete

        // build upper
        reg_upper = mem_upper_in;
        reg_upper >> reg_exp;
        // hide leading 1
        reg_sign_mask = c_reg_sign_mask;
        reg_gen = 5;
        reg_sign_mask >> reg_gen;
        reg_upper = reg_upper & ~reg_sign_mask;
        //
        reg_imp = mem_upper_out;
        reg_upper = reg_upper | reg_imp;

        // store answer
        mem_lower_out = reg_lower;
        mem_lower_out = reg_lower;
    }
    reg_gen = 0;
    if (reg_exp < reg_gen)  // left shift
    {
        // reg_exp = absolute_value(reg_exp)
        reg_imp = reg_exp;
        reg_exp = reg_exp - reg_imp;
        reg_exp = reg_exp - reg_imp;


    }
    
    return 0;
}
