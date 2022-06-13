#!/bin/bash
#假设 pili-rtc-core 和 pili-rtc-ios-kit 处于同一目录下
cp ../../pili-rtc-core/build/out/libqnrtc.a          ../../pili-rtc-ios-kit/QNRTCKit/QNRTCKit/Vendor/qnrtc

cp ../../pili-rtc-core/inc/qn_common_def.h           ../../pili-rtc-ios-kit/QNRTCKit/QNRTCKit/Vendor/qnrtc
cp ../../pili-rtc-core/inc/qn_error_code.h           ../../pili-rtc-ios-kit/QNRTCKit/QNRTCKit/Vendor/qnrtc
cp ../../pili-rtc-core/inc/qn_rtc_client_interface.h ../../pili-rtc-ios-kit/QNRTCKit/QNRTCKit/Vendor/qnrtc
#cp ../../pili-rtc-core/inc/qn_rtc_interface.h        ../../pili-rtc-ios-kit/QNRTCKit/QNRTCKit/Vendor/qnrtc
cp ../../pili-rtc-core/inc/qn_track_interface.h      ../../pili-rtc-ios-kit/QNRTCKit/QNRTCKit/Vendor/qnrtc

#cp ../../pili-rtc-core/src/sdk/ios/native/render/opengl/QNVideoGLView.h      ../../pili-rtc-ios-kit/QNRTCKit/QNRTCKit/Vendor/qnrtc



