HOST_ARCH       ?= $(shell uname -m | sed -e s/arm.*/arm/ -e s/aarch64.*/arm64/)
ARCH            ?= $(shell uname -m | sed -e s/arm.*/arm/ -e s/aarch64.*/arm64/)
KERNEL_SRC_DIR  ?= /lib/modules/$(shell uname -r)/build

ifeq ($(ARCH), arm)
 ifneq ($(HOST_ARCH), arm)
   CROSS_COMPILE  ?= arm-linux-gnueabihf-
 endif
endif
ifeq ($(ARCH), arm64)
 ifneq ($(HOST_ARCH), arm64)
   CROSS_COMPILE  ?= aarch64-linux-gnu-
 endif
endif

u-dma-buf-obj           := u-dma-buf.o
obj-$(CONFIG_U_DMA_BUF) += $(u-dma-buf-obj)

ifndef MAKE_TARGET
  KERNEL_VERSION ?= $(shell awk '/^VERSION/{print $$3}' $(KERNEL_SRC_DIR)/Makefile)
  KERNEL_VERSION_LT_5 = $(shell echo $(KERNEL_VERSION) | awk '{print (int($$1) < 5)}')
  ifeq ($(KERNEL_VERSION_LT_5), 1)
    MAKE_TARGET ?= modules
  else
    MAKE_TARGET ?= u-dma-buf.ko
  endif
endif

all:
	make -C $(KERNEL_SRC_DIR) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) M=$(PWD) obj-m=$(u-dma-buf-obj) $(MAKE_TARGET)

clean:
	make -C $(KERNEL_SRC_DIR) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) M=$(PWD) clean

