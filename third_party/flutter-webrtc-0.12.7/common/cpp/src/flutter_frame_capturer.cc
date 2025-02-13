#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS
#endif

#include "flutter_frame_capturer.h"
#include <stdio.h>
#include <stdlib.h>
#include "svpng.hpp"

namespace flutter_webrtc_plugin {

FlutterFrameCapturer::FlutterFrameCapturer(RTCVideoTrack* track,
                                           std::string path) {
  track_ = track;
  path_ = path;
}

void FlutterFrameCapturer::OnFrame(scoped_refptr<RTCVideoFrame> frame) {
  if (frame_ != nullptr) {
    return;
  }

  frame_ = frame.get()->Copy();
  catch_frame_ = true;
}

void FlutterFrameCapturer::CaptureFrame(
    std::unique_ptr<MethodResultProxy> result) {
  mutex_.lock();
  // Here init catch_frame_ flag
  catch_frame_ = false;

  track_->AddRenderer(this);
  // Here waiting for catch_frame_ is set to true
  while(!catch_frame_){}
  // Here unlock the mutex
  mutex_.unlock();

  mutex_.lock();
  track_->RemoveRenderer(this);

  std::vector<uint8_t> value = SaveFrame();
  mutex_.unlock();

  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  
  result_ptr->Success(EncodableValue(value));
}

std::vector<uint8_t> FlutterFrameCapturer::SaveFrame() {
  if (frame_ == nullptr) {
    return std::vector<uint8_t>();
  }

  int width = frame_.get()->width();
  int height = frame_.get()->height();
  int bytes_per_pixel = 4;
  int total_bytes = width * height * bytes_per_pixel;
  uint8_t* pixels = new uint8_t[total_bytes];

  frame_.get()->ConvertToARGB(RTCVideoFrame::Type::kABGR, pixels,
                              /* unused */ -1, width, height);

  std::vector<uint8_t> pixelVector(pixels, pixels + total_bytes);
  delete[] pixels;

  return pixelVector;



  // FILE* file = fopen(path_.c_str(), "wb");
  // if (!file) {
  //   return false;
  // }

  // svpng(file, width, height, pixels, 1);
  // fclose(file);
  // return true;
}

}  // namespace flutter_webrtc_plugin