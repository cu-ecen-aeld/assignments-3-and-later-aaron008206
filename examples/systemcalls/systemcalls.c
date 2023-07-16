#include "systemcalls.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdarg.h>

bool do_system(const char *cmd) {
    int exit_status = system(cmd);

    if (exit_status == -1) {
        return false;
    } else {
        return true;
    }
}

bool do_exec(int count, ...)
{
    va_list args;
    va_start(args, count);
    char * command[count+1];
    int i;
    for(i=0; i<count; i++)
    {
        command[i] = va_arg(args, char *);
    }
    command[count] = NULL;
    va_end(args);

    pid_t child_pid = fork();
    int status;

    switch (child_pid) {
        case -1:
            perror("- failing in process forking.");
            return false;
        case 0:
            execv(command[0], command);
            perror("- execv() failed in child process.");
            exit(1);
        default:
            waitpid(child_pid, &status, 0);
            if (WIFEXITED(status) && WEXITSTATUS(status) == 0) {
                return true;
            } else {
                return false;
            }
    }
}

bool do_exec_redirect(const char *outputfile, int count, ...)
{
    va_list args;
    va_start(args, count);
    char * command[count+1];
    int i;
    for(i=0; i<count; i++)
    {
        command[i] = va_arg(args, char *);
    }
    command[count] = NULL;
    va_end(args);

    pid_t child_pid = fork();
    int output_fd = open(outputfile, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    int status;

    switch (child_pid) {
        case -1:
            perror("- failing in process forking.");
            return false;
        case 0:
            if ((output_fd == -1) || (dup2(output_fd, STDOUT_FILENO) == -1)) {
                perror("- failing in file processing.");
                exit(1);
            }
            close(output_fd);

            execv(command[0], command);
            perror("- execv() failed in child process.");
            exit(1);
        default:
            waitpid(child_pid, &status, 0);
            if (WIFEXITED(status) && WEXITSTATUS(status) == 0) {
                return true;
            } else {
                return false;
            }
    }
}
