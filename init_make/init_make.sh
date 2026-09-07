#!/usr/bin/env bash

# Create Maefile for C project
function make_c(){
    local target="${1:-test}"
    local lib="${2:-}"


    cat > Makefile << EOF
.RECIPEPREFIX := >

CC       := gcc
AR       := ar

CFLAGS   := -std=c99 -pedantic -Werror -Wall -Wextra -Wvla
CPPFLAGS := -Iinclude
LDFLAGS  :=
LDLIBS   :=

BUILD_DIR := build

TARGET := $target
EOF
    
    if [[ -n "$lib" ]]; then
        cat >> Makefile <<EOF
LIBRARY := \$(BUILD_DIR)/$lib
EOF
    fi
    cat >> Makefile <<'EOF'

# ============================================================
# Sources
# ============================================================

SRC_DIR := src
LIB_DIR := lib

APP_SRCS := $(shell find $(SRC_DIR) -type f -name '*.c')
LIB_SRCS := $(shell find $(LIB_DIR) -type f -name '*.c')

APP_OBJS := $(APP_SRCS:%.c=$(BUILD_DIR)/%.o)
LIB_OBJS := $(LIB_SRCS:%.c=$(BUILD_DIR)/%.o)


DEPS := $(APP_OBJS:.o=.d) $(LIB_OBJS:.o=.d)

# ============================================================
# Default target
# ============================================================

.PHONY: all
all: $(TARGET)

# ============================================================
# Executable
# ============================================================

$(TARGET): $(APP_OBJS) $(LIBRARY)
>$(CC) $(LDFLAGS) $(APP_OBJS) $(LIBRARY) $(LDLIBS) -o $@

# ============================================================
# Object files
# ============================================================

$(BUILD_DIR)/%.o: %.c
>mkdir -p $(@D)
>$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -c $< -o $@

# Automatically generated dependencies
-include $(DEPS)

# ============================================================
# Debug
# ============================================================
 
.PHONY: debug
debug:
>$(MAKE) clean
>$(MAKE) CFLAGS="$(CFLAGS) -g3 -O0" $(TARGET)


# ============================================================
# Address Sanitizer
# ============================================================

.PHONY: asan
asan:
>$(MAKE) clean
>$(MAKE) CFLAGS="$(CFLAGS) -g3 -O0 -fsanitize=address" \
>        LDFLAGS="$(LDFLAGS) -fsanitize=address" $(TARGET)


# ============================================================
# Clean
# ============================================================

.PHONY: clean
clean:
>$(RM) -r $(BUILD_DIR)
>$(RM) $(TARGET)
EOF

    if [[ -n "$lib" ]]; then
        cat >> Makefile <<'EOF'

# ============================================================
# Static library
# ============================================================

.PHONY: lib
lib: $(LIBRARY)

$(LIBRARY): $(LIB_OBJS)
>$(AR) rcs $@ $^

EOF
    fi
}

make_c
