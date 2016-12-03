#ifndef HEAPLIB_H
#define HEAPLIB_H

#define ALIGNMENT 8
#define MIN_HEAP_SIZE 1024

#define SUCCESS 1
#define FAILURE 0

/* Sets up a new heap. 'heapptr' that points to a chunk of memory
 * that was -- allocated prior to this call -- which we will refer to
 * as the heap of size 'heap_size' bytes.  Returns 0 if setup fails,
 * nonzero if success.
 */
int hl_init(void *heapptr, unsigned int heap_size);


/* Allocates a block of memory of the given size from the heap starting
 * at 'heapptr'. Returns a pointer to the payload on success; returns
 * 0 if the allocator cannot satisfy the request.
 */
void *hl_alloc(void *heapptr, unsigned int payload_size);


/* Releases the block of previously allocated memory pointed to by
 * payload_ptr. NOP if payload_ptr == 0.
 */
void hl_release(void *heapptr, void *payload_ptr);


/* Changes the size of the payload pointed to by payload_ptr,
 * returning a pointer to the new payload, or 0 if the request cannot
 * be satisfied. The contents of the payload should be preserved (even
 * if the location of the payload changes).  If payload_ptr == 0,
 * function should behave like hl_alloc().
 */
void *hl_resize(void *heapptr, void *payload_ptr, unsigned int new_size);

#endif /*HEAPLIB_H*/
