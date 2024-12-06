#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <errno.h>

#define HPS_LED_BASE 0xFF200000  // Example base address for LEDs
#define HPS_LED_SPAN 0x20        // Span for the LED region
#define HPS_LED_CONTROL_OFFSET 0 // Offset for LED control register

volatile int keep_running = 1;
int mem_fd = -1;
void *hps_led_addr = NULL;


//
void handle_sigint(int sig) {
    printf("\nCtrl-C detected. Resetting hardware to default state...\n");
    if (hps_led_addr) {
        *((volatile unsigned int *)hps_led_addr) = 0;  // Reset LEDs
        munmap(hps_led_addr, HPS_LED_SPAN);
    }
    if (mem_fd >= 0) close(mem_fd);
    exit(0);
}
// Help message.
// Used for 
void print_help() {
    printf("usage: led_program [-h] [-v] [-p PATTERN TIME [PATTERN TIME ...]] [-f FILE]\n\n");
    printf("Control LED patterns on the HPS using /dev/mem.\n\n");
    printf("options:\n");
    printf("  -h, --help            Show this help message and exit\n");
    printf("  -v, --verbose         Enable verbose output\n");
    printf("  -p, --patterns PATTERN TIME [PATTERN TIME ...]\n");
    printf("                        Specify LED patterns and their display times. Patterns must be\n");
    printf("                        hexadecimal (e.g., 0x0f), and times are in milliseconds (e.g., 1500).\n");
    printf("  -f, --file FILE       Read LED patterns and times from a file. Each line should contain\n");
    printf("                        a pattern and a time separated by a space.\n\n");
    printf("notes:\n");
    printf("  - -p and -f are mutually exclusive.\n");
    printf("  - Each pattern must be followed by a time.\n");
    printf("  - End program with Ctrl-C, Resetting hardware to default state, HPS_LED_patterns will reset to 0\n");

}
void parse_file(const char *filename, int verbose) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("Error opening file");
        exit(1);
    }

    char line[256];
    while (fgets(line, sizeof(line), file)) {
        unsigned int pattern;
        int time;
        if (sscanf(line, "%x %d", &pattern, &time) != 2) {
            fprintf(stderr, "Invalid format in file: %s\n", line);
            fclose(file);
            exit(1);
        }
        if (verbose) {
            printf("LED pattern = %08x, Display time = %d ms\n", pattern, time);
        }
        *((volatile unsigned int *)hps_led_addr) = pattern;
        usleep(time * 1000);
    }

    fclose(file);
}

void parse_patterns(int argc, char **argv, int start_idx, int verbose) {
    for (int i = start_idx; i < argc; i += 2) {
        if (i + 1 >= argc) {
            fprintf(stderr, "Error: Each pattern must be followed by a time value.\n");
            exit(1);
        }

        unsigned int pattern = (unsigned int)strtol(argv[i], NULL, 16);
        int time = atoi(argv[i + 1]);

        if (verbose) {
            printf("LED pattern = %08x, Display time = %d ms\n", pattern, time);
        }
        *((volatile unsigned int *)hps_led_addr) = pattern;
        usleep(time * 1000);
    }
}

int main(int argc, char *argv[]) {
    int verbose = 0;
    int opt;
    char *file = NULL;
    int patterns_start = -1;

    signal(SIGINT, handle_sigint);  // Setup Ctrl-C handler

    // Parse command-line arguments
    while ((opt = getopt(argc, argv, "hvp:f:")) != -1) {
        switch (opt) {
            case 'h':
                print_help();
                return 0;
            case 'v':
                verbose = 1;
                break;
            case 'p':
                if (file) {
                    fprintf(stderr, "Error: -p and -f are mutually exclusive.\n");
                    return 1;
                }
                patterns_start = optind - 1;
                break;
            case 'f':
                if (patterns_start != -1) {
                    fprintf(stderr, "Error: -p and -f are mutually exclusive.\n");
                    return 1;
                }
                file = optarg;
                break;
            default:
                print_help();
                return 1;
        }
    }

    if (patterns_start == -1 && !file) {
        fprintf(stderr, "Error: No valid arguments provided.\n");
        print_help();
        return 1;
    }

    // Map /dev/mem
    mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (mem_fd < 0) {
        perror("Error opening /dev/mem");
        return 1;
    }

    hps_led_addr = mmap(NULL, HPS_LED_SPAN, PORT_WRITE, MAP_SHARED, mem_fd, HPS_LED_BASE);
    if (hps_led_addr == MAP_FAILED) {
        perror("Error mapping /dev/mem");
        close(mem_fd);
        return 1;
    }

    // Process patterns or file
    if (file) {
        parse_file(file, verbose);
    } else {
        parse_patterns(argc, argv, patterns_start, verbose);
    }

    // Cleanup
    munmap(hps_led_addr, HPS_LED_SPAN);
    close(mem_fd);
    return 0;
}
