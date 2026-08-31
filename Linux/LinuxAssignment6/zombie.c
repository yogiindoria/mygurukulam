#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
    pid_t pid = fork();

    if (pid < 0) {
        perror("fork failed");
        return 1;
    }

    if (pid == 0) {
        // Child process
        printf("Child: PID = %d\n", getpid());
        exit(0);
    } else {
        // Parent process
        printf("Parent: PID = %d\n", getpid());
        printf("Child PID = %d\n", pid);

        // Parent stays alive but doesn't call wait()
        sleep(60);
    }

    return 0;
}
