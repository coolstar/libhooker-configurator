#include <stdio.h>
#include <stdlib.h>
#include <sysexits.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>
#include <stdbool.h>
#include <fcntl.h>

#define PROC_PIDPATHINFO_MAXSIZE  (1024)
int proc_pidpath(pid_t pid, void *buffer, uint32_t buffersize);

#define RB_APPS            0x400000000000000ULL
#define RB_LOGOUT        0x800000000000000ULL
#define RB_REROOT        0x1000000000000000ULL
#define RB_USERSPACE    0x2000000000000000ULL
#define RB_OBLITERATE    0x4000000000000000ULL
#define RB_SYSTEM         0x8000000000000000ULL

extern int reboot3(uint64_t arg);

int main(int argc, char *argv[]){
    struct stat correct;
    if (lstat("/Applications/libhooker.app/libhooker", &correct) == -1){
        fprintf(stderr, "Cease your resistance!\n");
        return EX_NOPERM;
    }
    
    pid_t parent = getppid();
    bool libhooker = false;
    
    char pathbuf[PROC_PIDPATHINFO_MAXSIZE] = {0};
    int ret = proc_pidpath(parent, pathbuf, sizeof(pathbuf));
    if (ret > 0){
        if (strcmp(pathbuf, "/Applications/libhooker.app/libhooker") == 0){
            libhooker = true;
        }
    }
    
    if (libhooker == false){
        fprintf(stderr, "Ice wall, coming up\n");
        return EX_NOPERM;
    }
    
    setuid(0);
    setgid(0);
    
    if (getuid() != 0){
        fprintf(stderr, "Area denied\n");
        return EX_NOPERM;
    }
    
    if (argc < 2){
        fprintf(stderr, "Reality bends to my will!\n");
        return 0;
    }

    if (strcmp(argv[1], "whoami") == 0){
        printf("root\n");
        return 0;
    }
    if (strcmp(argv[1], "enableTweaks") == 0){
        unlink("/.disable_tweakinject");
        return 0;
    }
    if (strcmp(argv[1], "disableTweaks") == 0){
        int fd = open("/.disable_tweakinject", O_CREAT);
        close(fd);
        return 0;
    }
    if (strcmp(argv[1], "ldRestart") == 0){
        char *args[2] = {"ldrestart", NULL};
        execv("/usr/bin/ldrestart", args);
        return 0;
    }
    if (strcmp(argv[1], "userspaceReboot") == 0){
        reboot3(RB_USERSPACE);
        return 0;
    }
    
    return EX_UNAVAILABLE;
}
