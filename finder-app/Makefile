# compiler variables
CC := $(CROSS_COMPILE)gcc
CFLAGS := -Wall

# file variables
SRCS := $(wildcard *.c)
OBJS := $(SRCS:.c=.o)
TARGET := writer

# phony targets
.PHONY: all clean

# silent target
.SILENT: clean

# default target
all: $(TARGET)

# object to target rule
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

# source to object rule
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# clean target
clean:
	rm -f $(OBJS)
