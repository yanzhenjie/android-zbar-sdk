MY_LOCAL_PATH := $(call my-dir)

# libiconv
include $(CLEAR_VARS)
LOCAL_PATH := $(MY_LOCAL_PATH)
LOCAL_MODULE := libiconv
LOCAL_CFLAGS := \
    -Wno-multichar \
    -D_ANDROID \
    -DLIBDIR="c" \
    -DBUILDING_LIBICONV \
    -DBUILDING_LIBCHARSET \
    -DIN_LIBRARY

LOCAL_SRC_FILES := \
	libiconv-1.15/lib/iconv.c \
	libiconv-1.15/libcharset/lib/localcharset.c \
	libiconv-1.15/lib/relocatable.c

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/libiconv-1.15/include \
	$(LOCAL_PATH)/libiconv-1.15/libcharset \
	$(LOCAL_PATH)/libiconv-1.15/libcharset/include

include $(BUILD_SHARED_LIBRARY)

LOCAL_LDLIBS := -llog -lcharset

# -----------------------------------------------------

# libzbar
include $(CLEAR_VARS)
LOCAL_PATH := $(MY_LOCAL_PATH)
LOCAL_MODULE := zbar
LOCAL_SRC_FILES := \
			zbarjni.c \
			zbar/img_scanner.c \
			zbar/decoder.c \
			zbar/image.c \
			zbar/symbol.c \
			zbar/convert.c \
			zbar/config.c \
			zbar/scanner.c \
			zbar/error.c \
			zbar/refcnt.c \
			zbar/video.c \
			zbar/video/null.c \
			zbar/decoder/code128.c \
			zbar/decoder/code39.c \
			zbar/decoder/code93.c \
			zbar/decoder/codabar.c \
			zbar/decoder/databar.c \
			zbar/decoder/ean.c \
			zbar/decoder/i25.c \
			zbar/decoder/qr_finder.c \
			zbar/qrcode/bch15_5.c \
			zbar/qrcode/binarize.c \
			zbar/qrcode/isaac.c \
			zbar/qrcode/qrdec.c \
			zbar/qrcode/qrdectxt.c \
			zbar/qrcode/rs.c \
			zbar/qrcode/util.c

LOCAL_C_INCLUDES := \
			$(LOCAL_PATH)/include \
			$(LOCAL_PATH)/zbar \
			$(LOCAL_PATH)/libiconv-1.15/include

LOCAL_SHARED_LIBRARIES := libiconv

include $(BUILD_SHARED_LIBRARY)