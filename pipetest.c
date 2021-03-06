#include "types.h"
#include "stat.h"
#include "user.h"

/*
For this problem you need to add a new system call to the xv6 kernel and 
write a new xv6 user program to demonstrate that it works.

The system call you are going to add is called 

int pipe_count(int fd)

This system call will return the number of bytes currently in a pipe pointed to by fd. 
The fd value can be either the read end or the write end of the pipe.

In addition, if fd is not a valid pipe, you need to return -1.

Write a new user program, pipetest, that tests your pipe_count() system call.

Your test should invoke pipe_count() in the following situations:
The pipe is empty
The pipe is full
The pipe is in between empty and full
The fd is not a valid pipe

*/


int
main(int argc, char *argv[])
{
  int fd[2];
  int count;

  pipe(fd);

  count = pipe_count(fd[1]);
  printf(1, "EMPTY PIPE: %d\n", count);

  if (write(fd[1], "writing to the pipe", 19) < 0) {
    printf(1, "can't write pipe\n");
    exit();
  }

  count = pipe_count(fd[1]);
  printf(1, "Between empty and full pipe: %d\n", count);

  if (write(fd[1], "writing to the pipe with enough characters so that the pipe is full, which is going to be 512 minus what I have already written into the pipe which is 19. So that leaves us with 493 characters that I need to write here in order for me to fill the pipe. I am going to keep rambling on until I can reach the end of the pipe, I am actually dreading having to count all these characters. I hope I don't lose count on the way. It is almost midnight so I am trying to finish this project! Omgggggggg", 493) < 0) {
    printf(1, "can't write pipe\n");
    exit();
  }

  count = pipe_count(fd[1]);
  printf(1, "FULL PIPE: %d\n", count);

  count = pipe_count(13);
  printf(1, "INVALID PIPE: %d\n", count);

 
  exit();
}
