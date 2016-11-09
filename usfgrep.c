/* usfgrep - a simple version of grep that can search one or more files */

#include "types.h"
#include "stat.h"
#include "user.h"

int fd;

// method that takes the argument string given and looks for a match with the line extracted from the file
void string_match(char *each_line, char *arg_file, char *arg_string, int string_count, int line_counter) {

	int comp;
	int z;

        for (z = 0; z < strlen(each_line); z++) {

          comp = strncmp(each_line + z, arg_string, string_count);
          
        
          if (comp == 0) {
            printf(1,"%s [%d]:%s\n", arg_file, line_counter, each_line);
            break;
          }
          
        }

}

// method that takes in a file and reads it byte by byte and saving the contents line by line
void file_contents(int fd, int string_count, char *arg_string, char *arg_file) {

	
	int bytes_read;
	char each_line[512];
	char t;
	int line_byte_count = 0;
	int line_counter = 0;
	int i = 0;
	
	// check to see if file can be opened
    if (fd < 0) {														
      printf(1,"Cannot open file");
        exit();
    }

    // goes through the file character at a time, checks if char read is > 0
    while ((bytes_read = read(fd , &t, 1)) > 0) {						

    	// counter for every single byte
    	line_byte_count++;													
    	
    	// check to see if the next bit read is a new line character or a terminating character
    	if (t == '\n' || t == '\0') {

    		// a check to see if the file is bigger than 511
    		if (line_byte_count > 511) {											
                  printf(1, "The line is too long");
    			exit();												
    		}

    		// set the line_byte_count to 0 because we have reached the end of the line
    		line_byte_count = 0;

    		// add the count of lines in file
	    	line_counter++;

	    	// adding null terminating character at the end of the line read in
	    	each_line[i++] = '\0';

	    	string_match(each_line, arg_file, arg_string, string_count, line_counter);
	    	
	    	// memset sets all bytes in my char array to null terminating character               			
	    	memset(each_line, '\0', 512);				
	    	
	    	// resetting i to 0 for index of eachLine char array
	    	i = 0;													
	    	
	    }

	    // else means that the next character read != a newline or null terminating character
	    else {

	    	// adding in the byte read to the end of my character array (each_line)															
	    	each_line[i++] = t;											
	    }
    }
}

int main(int argc, char *argv[])  {

    if (argc < 3) {
      printf(1, "Insufficient arguments.\n");
      printf(1, "usage: usfgrep <string> <file1> [<file2> ...]\n");
      printf(1,"\n");
      exit();
    }

    // need the count of the string from the command line argument
    int length = strlen(argv[1]);    					

    char *arg_string;
    arg_string = malloc(length);

    // gets the string from the command line argument
    arg_string = argv[1];         						

    char *arg_file;
 
    int i;
    for (i = 2; i < argc; i++) {

    	// open the file and save it to an int file descriptor
    	fd = open(argv[i], 0);
    	arg_file = malloc(strlen(argv[i]));	

    	// save file name to the variable we malloced for					
    	arg_file = argv[i];										
    	file_contents(fd, length, arg_string, arg_file);			
    	close(fd);												
    }
    
    // return 0;
    exit();
    
}




