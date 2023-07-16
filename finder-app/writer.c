#include <stdio.h>
#include <string.h>
#include <libgen.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <syslog.h>
#include <stdlib.h>

#define LOG_OPEN         openlog("writer", LOG_PID, LOG_USER)
#define LOG_CLOSE        closelog()
#define LOG_INFO_DEXIST  do { syslog(LOG_INFO, "[info](uid:%d) directory exist.", getuid()); puts("[info] Directory already exists."); } while (0)
#define LOG_INFO_DCREAT  do { syslog(LOG_INFO, "[info](uid:%d) directory created.", getuid()); puts("[info] Directory created."); } while (0)
#define LOG_DEBUG_FWRITE do { syslog(LOG_INFO, "[info](uid:%d) file writing success. - Writing %s to %s", getuid(), str_, file_); puts("[info] File writing success."); } while (0)
#define LOG_INFO_PENDS   syslog(LOG_INFO, "[info](uid:%d) program 'writer' ends.", getuid())
#define LOG_ERR_FWRITE   do { syslog(LOG_DEBUG, "[info](uid:%d) file writing failed.", getuid()); puts("[error] File writing failed."); } while (0)
#define LOG_ERR_DCHAGE   do { syslog(LOG_DEBUG, "[info](uid:%d) directory change failed.", getuid()); puts("[error] Changing to directory failed."); } while (0)
#define LOG_ERR_SYNTAX   do { syslog(LOG_DEBUG, "[error](uid:%d) file execution syntax error.", getuid()); puts("[error] Syntax error: ./execution_file [absolute path] [string to write]\n"); } while (0)
#define LOG_ERR_FORMAT   do { syslog(LOG_DEBUG, "[error](uid:%d) path format error.", getuid()); puts("[error] Syntax error: parameter #1 is not a file name in absolute path format.\n"); } while (0)

char* _dir;
char* _file;
char* _str;

int argument_check(int argumentCount, char* arguments[]);
int directory_writing(char* dir_);
int file_writing(char* dir_, char* file_, char* str_);

int main(int argc, char* argv[]) {
    LOG_OPEN;

    if (argument_check(argc, argv) == 1) {
        LOG_CLOSE;
        return 1;
    } else {
        char* _file = basename(argv[1]);
        char* _dir = dirname(argv[1]);
        char* _str = argv[2];

        directory_writing(_dir);
        file_writing(_dir, _file, _str);
        LOG_CLOSE;
        return 0;
    }
}

int argument_check(int argumentCount, char* arguments[]) {
    if (argumentCount != 3) {
        LOG_ERR_SYNTAX;
        return 1;
    }
    return 0;
}

int directory_writing(char* dir_) {
    struct stat st;
    if (stat(dir_, &st) == 0) {
        if (S_ISDIR(st.st_mode)) {
            LOG_INFO_DEXIST;
        } else {
            LOG_ERR_FORMAT;
            return 1;
        }
    } else {
        if (mkdir(dir_, 0777) == 0) {
            LOG_INFO_DCREAT;
        } else {
            LOG_ERR_FORMAT;
            return 1;
        }
    }
    return 0;
}

int file_writing(char* dir_, char* file_, char* str_) {
    char path[1024];

    if (chdir(dir_) == 0) {
        FILE* file = fopen(file_, "w");
        if (file != NULL) {
            fputs(strcat(str_, "\n"), file);
            fclose(file);
            chdir(getcwd(path, 1024));
            LOG_DEBUG_FWRITE;
            return 0;
        } else {
            LOG_ERR_FWRITE;
            return 1;
        }
    } else {
        LOG_ERR_DCHAGE;
        return 1;
    }
}
