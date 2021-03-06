#
# Component makefile.
#

override APP_MODULES = $(_APP_MODULES)
override APP_CONF_SCHEMA = $(_APP_CONF_SCHEMA)
override APP_EXTRA_SRCS = $(_APP_EXTRA_SRCS)
override APP_FS_PATH = $(_APP_FS_PATH)
override BUILD_DIR = $(_BUILD_DIR)
override FW_DIR := $(_FW_DIR)
override GEN_DIR := $(_GEN_DIR)
override MGOS_PATH = $(_MGOS_PATH)

MGOS_ENABLE_ATCA ?= 1
MGOS_ENABLE_ATCA_SERVICE ?= 1
MGOS_ENABLE_CONFIG_SERVICE ?= 1
MGOS_ENABLE_CONSOLE ?= 0
MGOS_ENABLE_DNS_SD ?= 0
MGOS_ENABLE_FILESYSTEM_SERVICE ?= 1
MGOS_ENABLE_I2C ?= 1
# Use bitbang I2C for now.
MGOS_ENABLE_I2C_GPIO ?= 1
MGOS_ENABLE_JS ?= 0
MGOS_ENABLE_MQTT ?= 1
MGOS_ENABLE_RPC ?= 1
MGOS_ENABLE_RPC_CHANNEL_HTTP ?= 1
MGOS_ENABLE_RPC_CHANNEL_UART ?= 1
MGOS_ENABLE_UPDATER ?= 0
MGOS_ENABLE_UPDATER_POST ?= 0
MGOS_ENABLE_UPDATER_RPC ?= 0
MGOS_ENABLE_WIFI ?= 1

MGOS_DEBUG_UART ?= 0

MGOS_SRC_PATH = $(MGOS_PATH)/fw/src

SYS_CONFIG_C = $(GEN_DIR)/sys_config.c
SYS_CONFIG_DEFAULTS_JSON = $(GEN_DIR)/sys_config_defaults.json
SYS_CONFIG_SCHEMA_JSON = $(GEN_DIR)/sys_config_schema.json
SYS_RO_VARS_C = $(GEN_DIR)/sys_ro_vars.c
SYS_RO_VARS_SCHEMA_JSON = $(GEN_DIR)/sys_ro_vars_schema.json
SYS_CONF_SCHEMA =

COMPONENT_EXTRA_INCLUDES = $(MGOS_PATH) $(MGOS_ESP_PATH)/include $(SPIFFS_PATH) $(GEN_DIR)

MGOS_SRCS = mgos_config.c mgos_gpio.c mgos_init.c mgos_mongoose.c \
            mgos_sys_config.c $(notdir $(SYS_CONFIG_C)) $(notdir $(SYS_RO_VARS_C)) \
            mgos_timers_mongoose.c mgos_uart.c mgos_utils.c \
            esp32_console.c esp32_crypto.c esp32_fs.c esp32_gpio.c esp32_hal.c \
            esp32_main.c esp32_uart.c

include $(MGOS_PATH)/fw/common.mk
include $(MGOS_PATH)/fw/src/features.mk

SYS_CONF_SCHEMA += $(MGOS_ESP_PATH)/src/esp32_config.yaml

ifeq "$(MGOS_ENABLE_I2C)" "1"
  SYS_CONF_SCHEMA += $(MGOS_ESP_PATH)/src/esp32_i2c_config.yaml
endif
ifeq "$(MGOS_ENABLE_WIFI)" "1"
  MGOS_SRCS += esp32_wifi.c
  SYS_CONF_SCHEMA += $(MGOS_ESP_PATH)/src/esp32_wifi_config.yaml
endif

include $(MGOS_PATH)/fw/src/sys_config.mk

VPATH += $(MGOS_ESP_PATH)/src $(MGOS_PATH)/common
MGOS_SRCS += cs_crc32.c cs_dbg.c cs_file.c cs_rbuf.c json_utils.c
ifeq "$(MGOS_ENABLE_RPC)" "1"
  VPATH += $(MGOS_PATH)/common/mg_rpc
endif

VPATH += $(MGOS_PATH)/fw/src

VPATH += $(MGOS_PATH)/frozen
MGOS_SRCS += frozen.c

VPATH += $(MGOS_PATH)/mongoose
MGOS_SRCS += mongoose.c

VPATH += $(GEN_DIR)

VPATH += $(APP_MODULES)

APP_SRCS := $(notdir $(foreach m,$(APP_MODULES),$(wildcard $(m)/*.c))) $(APP_EXTRA_SRCS)

COMPONENT_OBJS = $(addsuffix .o,$(basename $(APP_SRCS) $(MGOS_SRCS)))
CFLAGS += $(MGOS_FEATURES) -DMGOS_MAX_NUM_UARTS=3 \
          -DMGOS_DEBUG_UART=$(MGOS_DEBUG_UART) \
          -DMGOS_NUM_GPIO=40 \
          -DMG_ENABLE_FILESYSTEM \
          -DMG_ENABLE_SSL -DMG_SSL_IF=MG_SSL_IF_MBEDTLS \
          -DMG_ENABLE_HTTP_STREAMING_MULTIPART \
          -DCS_ENABLE_SPIFFS -DMG_ENABLE_DIRECTORY_LISTING
COMPONENT_ADD_LDFLAGS := -Wl,--whole-archive -lsrc -Wl,--no-whole-archive

libsrc.a: $(GEN_DIR)/sys_config.o

./%.o: %.c $(SYS_CONFIG_C) $(SYS_RO_VARS_C)
	$(summary) CC $@
	$(CC) $(CFLAGS) $(CPPFLAGS) \
	  $(addprefix -I ,$(COMPONENT_INCLUDES)) \
	  $(addprefix -I ,$(COMPONENT_EXTRA_INCLUDES)) \
	  -c $< -o $@
