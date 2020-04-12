BUILD_CONFIG:=Debug
CROSS_COMPILE:=/home/nicolas/work/siema/vendors/ST/Distribution-Package/openstlinux-20-02-19/build-openstlinuxweston-stm32mp1/tmp-glibc/sysroots-components/x86_64/gcc-arm-none-eabi-native/usr/share/gcc-arm-none-eabi/bin/arm-none-eabi-
BIN_NAME:=blinky
CPU_TYPE:=M4
PROJECT_DIR:=./Projects/STM32MP157C-DK2/Siema/BLINKY/blinky/


CC := $(CROSS_COMPILE)gcc
LD := $(CROSS_COMPILE)ld
AS := $(CROSS_COMPILE)ar
STRIP := $(CROSS_COMPILE)strip
OBJCOPY := $(CROSS_COMPILE)objcopy
SIZE := $(CROSS_COMPILE)size

ifeq ($(CPU_TYPE),M4)
COMMONFLAGS += -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16
endif
ifeq ($(CPU_TYPE),A7)
COMMONFLAGS += -mcpu=cortex-a7 -mthumb -mfloat-abi=hard -mfpu=neon-vfpv4
endif

# Project settings
PROJ_DIR  := $(PROJECT_DIR)
PROJ_NAME := $(BIN_NAME)

# Output
OUT	  := $(PROJ_DIR)/out
BUILD_OUT := $(OUT)/$(BUILD_CONFIG)

# Bin
TESTELF := $(BUILD_OUT)/$(PROJ_NAME).elf
TESTBIN := $(BUILD_OUT)/$(PROJ_NAME).bin

# CFLAGS rules
CFLAGS	+= $(COMMONFLAGS)
CFLAGS	+= -Os
CFLAGS	+= -Wall -fmessage-length=0 -ffunction-sections -c -fmessage-length=0 -MMD -MP
#CFLAGS	+= -Wno-unused-function
#CFLAGS	+= -Wno-unused-variable
CFLAGS	+= -g3
#CFLAGS += -g
#CFLAGS += -Werror

# LDFLAGS rules
LDFLAGS	+= $(COMMONFLAGS)
LDFLAGS	+= -specs=nosys.specs -specs=nano.specs
LDFLAGS	+= -Wl,-Map=$(BUILD_OUT)/output.map -Wl,--gc-sections -lm
#LDFLAGS	+= -D__MEM_START__=0x2ffc2000 -D__MEM_END__=0x2fff3000 -D__MEM_SIZE__=0x31000
#debug LINKER
#LDFLAGS += -Wl,--verbose

all: $(TESTBIN)

# Get config code from the project to compile (source, cflags, ldflags, ldlibs)
include $(PROJ_DIR)/config.in

# Build rule
define c-compilation-rule
$1: $2 $(LDSCRIPT)
	@echo $2 \< $1
	@mkdir -pv `dirname $1`
	$(CC) $(CFLAGS) -c $2 -o $1
COBJ+=$1
endef

# generate a compilation rule for each source file
$(foreach r,$(CSRC), $(eval $(call c-compilation-rule,$(BUILD_OUT)/$(r).o,$(r))))

# Include dep files
#DEPS= $(foreach file,$(CSRC),$(file).d)
#-include $(DEPS)

# Build elf output
$(TESTELF): $(COBJ)
	@echo link $@
	$(CC)  $(LDFLAGS) -o $@.sym $^ $(LDLIBS) -T$(LDSCRIPT)
	@cp $@.sym $@
	@$(STRIP) -g $@
	@$(SIZE) $@

# Build bin output
$(TESTBIN): $(TESTELF)
	@$(OBJCOPY) -O binary $(TESTELF) $(TESTBIN)

clean:
	rm -rf $(OUT)



