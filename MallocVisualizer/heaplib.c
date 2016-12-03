#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include <assert.h>
#include "MallocVisualizer-Bridging-Header.h"

/* You must implement these functions according to the specification
 * given in heaplib.h. You can define any types you like to this file.
 *
 * Student 1 Name:
 * Student 1 NetID:
 * Student 2 Name:
 * Student 2 NetID:
 *
 * Include a description of your approach here.
 *
 */

#define ADD_BYTES(base_addr, num_bytes) (((char *)(base_addr)) + (num_bytes))

int hl_init(void *heap_ptr, unsigned int heap_size) {
    return FAILURE;
}

void *hl_alloc(void *heap_ptr, unsigned int payload_size) {
    return NULL;
}

void hl_release(void *heap_ptr, void *payload_ptr) {
    
}

void *hl_resize(void *heap_ptr, void *payload_ptr, unsigned int new_size) {
    return NULL;
}

